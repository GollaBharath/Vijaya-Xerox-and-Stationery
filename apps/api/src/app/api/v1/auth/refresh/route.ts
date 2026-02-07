/**
 * POST /api/v1/auth/refresh
 *
 * Refresh access token using refresh token
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { ApiResponse } from "@/types/global";
import { validateRefreshToken } from "@/modules/auth/auth.validator";
import { refreshAccessToken } from "@/modules/auth/auth.service";
import { AuthTokens } from "@/modules/auth/auth.types";
import { logger } from "@/lib/logger";

export const POST = errorHandler(async (request: NextRequest) => {
	// Parse request body
	const body = await request.json();

	// Validate request
	const refreshToken = validateRefreshToken(body);

	// Refresh access token
	const tokens = await refreshAccessToken(refreshToken);

	logger.info("Access token refreshed");

	// Return response
	const response: ApiResponse<AuthTokens> = {
		success: true,
		data: tokens,
		message: "Token refreshed successfully",
	};

	return NextResponse.json(response, { status: 200 });
});
