/**
 * POST /api/v1/auth/register
 *
 * Register a new user
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { apiRateLimiter } from "@/lib/rate_limiter";
import { getClientIp } from "@/utils/helpers";
import { ApiResponse, ApiError, ErrorCode } from "@/types/global";
import { validateRegister } from "@/modules/auth/auth.validator";
import { register } from "@/modules/auth/auth.service";
import { RegisterResponse } from "@/modules/auth/auth.types";
import { logger } from "@/lib/logger";

export const POST = errorHandler(async (request: NextRequest) => {
	// Rate limiting
	const clientIp = getClientIp(request.headers);
	const rateLimitResult = await apiRateLimiter.checkLimit(clientIp);

	if (!rateLimitResult.allowed) {
		const error: ApiError = {
			success: false,
			error: {
				code: ErrorCode.RATE_LIMIT_EXCEEDED,
				message: "Too many requests. Please try again later.",
			},
		};
		return NextResponse.json(error, {
			status: 429,
			headers: {
				"X-RateLimit-Remaining": rateLimitResult.remaining.toString(),
				"X-RateLimit-Reset": rateLimitResult.resetAt.toISOString(),
			},
		});
	}

	// Parse request body
	const body = await request.json();

	// Validate request
	const validatedData = validateRegister(body);

	// Register user
	const result = await register(validatedData);

	logger.info("User registration successful", {
		userId: result.user.id,
		email: result.user.email,
	});

	// Return response
	const response: ApiResponse<RegisterResponse> = {
		success: true,
		data: result,
		message: "Registration successful",
	};

	return NextResponse.json(response, { status: 201 });
});
