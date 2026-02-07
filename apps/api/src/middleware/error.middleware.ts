/**
 * Error Handler Middleware
 *
 * Wraps route handlers to catch errors and return standardized error responses
 */

import { NextRequest, NextResponse } from "next/server";
import { Prisma } from "@prisma/client";
import { logger } from "@/lib/logger";
import { ApiError, ErrorCode } from "@/types/global";

/**
 * Custom application errors
 */
export class AppError extends Error {
	constructor(
		public code: ErrorCode,
		message: string,
		public statusCode: number = 400,
		public details?: any,
	) {
		super(message);
		this.name = "AppError";
	}
}

/**
 * Validation error
 */
export class ValidationError extends AppError {
	constructor(
		message: string,
		public field?: string,
		details?: any,
	) {
		super(ErrorCode.VALIDATION_ERROR, message, 400, details);
		this.name = "ValidationError";
	}
}

/**
 * Not found error
 */
export class NotFoundError extends AppError {
	constructor(resource: string) {
		super(ErrorCode.RESOURCE_NOT_FOUND, `${resource} not found`, 404);
		this.name = "NotFoundError";
	}
}

/**
 * Unauthorized error
 */
export class UnauthorizedError extends AppError {
	constructor(message: string = "Unauthorized") {
		super(ErrorCode.UNAUTHORIZED, message, 401);
		this.name = "UnauthorizedError";
	}
}

/**
 * Forbidden error
 */
export class ForbiddenError extends AppError {
	constructor(message: string = "Forbidden") {
		super(ErrorCode.FORBIDDEN, message, 403);
		this.name = "ForbiddenError";
	}
}

/**
 * Convert various error types to standardized API error response
 */
function errorToApiError(error: any): { error: ApiError; statusCode: number } {
	// App errors (our custom errors)
	if (error instanceof AppError) {
		const apiError: ApiError = {
			success: false,
			error: {
				code: error.code,
				message: error.message,
				details: error.details,
			},
		};

		if (error instanceof ValidationError && error.field) {
			apiError.error.field = error.field;
		}

		return { error: apiError, statusCode: error.statusCode };
	}

	// Prisma errors
	if (error instanceof Prisma.PrismaClientKnownRequestError) {
		// Unique constraint violation
		if (error.code === "P2002") {
			const target = (error.meta?.target as string[]) || [];
			const field = target[0] || "field";
			return {
				error: {
					success: false,
					error: {
						code: ErrorCode.RESOURCE_ALREADY_EXISTS,
						message: `A record with this ${field} already exists`,
						field,
						details: error.meta,
					},
				},
				statusCode: 409,
			};
		}

		// Foreign key constraint violation
		if (error.code === "P2003") {
			return {
				error: {
					success: false,
					error: {
						code: ErrorCode.BAD_REQUEST,
						message: "Invalid reference to related resource",
						details: error.meta,
					},
				},
				statusCode: 400,
			};
		}

		// Record not found
		if (error.code === "P2025") {
			return {
				error: {
					success: false,
					error: {
						code: ErrorCode.RESOURCE_NOT_FOUND,
						message: "Resource not found",
					},
				},
				statusCode: 404,
			};
		}
	}

	// Prisma validation errors
	if (error instanceof Prisma.PrismaClientValidationError) {
		return {
			error: {
				success: false,
				error: {
					code: ErrorCode.VALIDATION_ERROR,
					message: "Invalid data provided",
					details: error.message,
				},
			},
			statusCode: 400,
		};
	}

	// Default internal server error
	return {
		error: {
			success: false,
			error: {
				code: ErrorCode.INTERNAL_SERVER_ERROR,
				message: "An unexpected error occurred",
				details:
					process.env.NODE_ENV === "development" ? error.message : undefined,
			},
		},
		statusCode: 500,
	};
}

/**
 * Error handler wrapper for route handlers
 *
 * Usage:
 * export const GET = errorHandler(async (request) => {
 *   // Your handler code
 *   throw new NotFoundError('User');
 * });
 */
export function errorHandler<T extends any[]>(
	handler: (request: NextRequest, ...args: T) => Promise<NextResponse>,
) {
	return async (request: NextRequest, ...args: T): Promise<NextResponse> => {
		try {
			return await handler(request, ...args);
		} catch (error) {
			// Log error
			logger.error("Route handler error:", error, {
				context: `${request.method} ${request.nextUrl.pathname}`,
			});

			// Convert to API error and return
			const { error: apiError, statusCode } = errorToApiError(error);
			return NextResponse.json(apiError, { status: statusCode });
		}
	};
}

/**
 * Async error wrapper for non-route async functions
 * Re-throws AppError, wraps others in AppError
 */
export async function catchAsync<T>(
	fn: () => Promise<T>,
	errorMessage: string = "Operation failed",
): Promise<T> {
	try {
		return await fn();
	} catch (error) {
		if (error instanceof AppError) {
			throw error;
		}
		logger.error(errorMessage, error);
		throw new AppError(
			ErrorCode.INTERNAL_SERVER_ERROR,
			errorMessage,
			500,
			error,
		);
	}
}
