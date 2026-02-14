/**
 * Authentication Middleware
 *
 * Verifies JWT tokens and attaches user context to request
 */

import { NextRequest, NextResponse } from "next/server";
import jwt from "jsonwebtoken";
import { env } from "@/lib/env";
import { logger } from "@/lib/logger";
import { JWTPayload, ApiError, ErrorCode } from "@/types/global";

/**
 * Extract token from Authorization header
 */
function extractToken(request: NextRequest): string | null {
	const authHeader = request.headers.get("authorization");

	if (!authHeader) {
		return null;
	}

	const parts = authHeader.split(" ");

	if (parts.length !== 2 || parts[0] !== "Bearer") {
		return null;
	}

	return parts[1];
}

/**
 * Verify JWT token
 */
function verifyToken(token: string): JWTPayload | null {
	try {
		const decoded = jwt.verify(token, env.JWT_SECRET) as JWTPayload;
		return decoded;
	} catch (error) {
		if (error instanceof jwt.TokenExpiredError) {
			logger.warn("Token expired", { error: error.message });
			return null;
		}
		if (error instanceof jwt.JsonWebTokenError) {
			logger.warn("Invalid token", { error: error.message });
			return null;
		}
		logger.error("Token verification error", error);
		return null;
	}
}

/**
 * Authentication middleware
 *
 * Usage in route handler:
 * const authResult = await requireAuth(request);
 * if (!authResult.authorized) return authResult.response;
 * const { userId, role } = authResult.user;
 */
export async function requireAuth(
	request: NextRequest,
): Promise<
	| { authorized: true; user: JWTPayload }
	| { authorized: false; response: NextResponse }
> {
	const token = extractToken(request);

	if (!token) {
		const error: ApiError = {
			success: false,
			error: {
				code: ErrorCode.UNAUTHORIZED,
				message: "Authentication required. Please provide a valid token.",
			},
		};
		return {
			authorized: false,
			response: NextResponse.json(error, { status: 401 }),
		};
	}

	const payload = verifyToken(token);

	if (!payload) {
		const error: ApiError = {
			success: false,
			error: {
				code: ErrorCode.TOKEN_INVALID,
				message: "Invalid or expired token. Please login again.",
			},
		};
		return {
			authorized: false,
			response: NextResponse.json(error, { status: 401 }),
		};
	}

	return {
		authorized: true,
		user: payload,
	};
}

/**
 * Optional authentication middleware
 *
 * Returns user if authenticated, null otherwise
 * Does not block request if not authenticated
 */
export async function optionalAuth(
	request: NextRequest,
): Promise<JWTPayload | null> {
	const token = extractToken(request);

	if (!token) {
		return null;
	}

	return verifyToken(token);
}

/**
 * Flexible authentication middleware with options
 *
 * @param request - The Next.js request object
 * @param options - Authentication options
 * @returns The authenticated user or null if not required
 */
export async function authenticate(
	request: NextRequest,
	options: { required?: boolean; adminOnly?: boolean } = {},
): Promise<JWTPayload | null> {
	const { required = false, adminOnly = false } = options;

	const token = extractToken(request);

	if (!token) {
		if (required) {
			throw new Error("Authentication required. Please provide a valid token.");
		}
		return null;
	}

	const payload = verifyToken(token);

	if (!payload) {
		if (required) {
			throw new Error("Invalid or expired token. Please login again.");
		}
		return null;
	}

	// Check admin role if required
	if (adminOnly && payload.role !== "ADMIN") {
		throw new Error("Admin access required.");
	}

	return payload;
}
