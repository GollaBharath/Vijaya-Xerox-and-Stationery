/**
 * GET /api/v1/me/profile
 * PATCH /api/v1/me/profile
 *
 * User profile management endpoint
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { requireAuth } from "@/middleware/auth.middleware";
import { ApiResponse } from "@/types/global";
import { getProfile, updateProfile } from "@/modules/profile/profile.service";
import { validateUpdateProfile } from "@/modules/profile/profile.validator";
import { ProfileResponse } from "@/modules/profile/profile.types";

/**
 * GET /api/v1/me/profile
 * Get current user's profile
 */
export const GET = errorHandler(async (request: NextRequest) => {
	const authResult = await requireAuth(request);
	if (!authResult.authorized) return authResult.response;

	const result = await getProfile(authResult.user.userId);

	const response: ApiResponse<ProfileResponse> = {
		success: true,
		data: result,
	};

	return NextResponse.json(response, { status: 200 });
});

/**
 * PATCH /api/v1/me/profile
 * Update current user's profile
 */
export const PATCH = errorHandler(async (request: NextRequest) => {
	const authResult = await requireAuth(request);
	if (!authResult.authorized) return authResult.response;

	const body = await request.json();
	const payload = validateUpdateProfile(body);

	const result = await updateProfile(authResult.user.userId, payload);

	const response: ApiResponse<ProfileResponse> = {
		success: true,
		data: result,
		message: "Profile updated successfully",
	};

	return NextResponse.json(response, { status: 200 });
});
