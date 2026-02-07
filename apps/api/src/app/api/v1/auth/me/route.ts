/**
 * GET /api/v1/auth/me
 *
 * Get current authenticated user
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { requireAuth } from "@/middleware/auth.middleware";
import { ApiResponse } from "@/types/global";
import { getCurrentUser } from "@/modules/auth/auth.service";
import { UserResponse } from "@/modules/auth/auth.types";

export const GET = errorHandler(async (request: NextRequest) => {
	// Verify authentication
	const authResult = await requireAuth(request);
	if (!authResult.authorized) {
		return authResult.response;
	}

	const { userId } = authResult.user;

	// Get user
	const user = await getCurrentUser(userId);

	// Return response
	const response: ApiResponse<UserResponse> = {
		success: true,
		data: user,
	};

	return NextResponse.json(response, { status: 200 });
});
