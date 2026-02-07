/**
 * POST /api/v1/auth/login
 *
 * Login user
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { authRateLimiter } from "@/lib/rate_limiter";
import { getClientIp } from "@/utils/helpers";
import { ApiResponse, ApiError, ErrorCode } from "@/types/global";
import { validateLogin } from "@/modules/auth/auth.validator";
import { login } from "@/modules/auth/auth.service";
import { LoginResponse } from "@/modules/auth/auth.types";
import { logger } from "@/lib/logger";

export const POST = errorHandler(async (request: NextRequest) => {
	// Rate limiting (stricter for login)
	const clientIp = getClientIp(request.headers);
	const rateLimitResult = await authRateLimiter.checkLimit(clientIp);

	if (!rateLimitResult.allowed) {
		const error: ApiError = {
			success: false,
			error: {
				code: ErrorCode.RATE_LIMIT_EXCEEDED,
				message: "Too many login attempts. Please try again later.",
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
	const validatedData = validateLogin(body);

	// Login user
	const result = await login(validatedData);

	logger.info("User login successful", {
		userId: result.user.id,
		email: result.user.email,
	});

	// Return response
	const response: ApiResponse<LoginResponse> = {
		success: true,
		data: result,
		message: "Login successful",
	};

	return NextResponse.json(response, { status: 200 });
});
