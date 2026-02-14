/**
 * PUT /api/v1/auth/fcm-token
 * 
 * Update user's FCM token for push notifications
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler, ValidationError } from "@/middleware/error.middleware";
import { requireAuth } from "@/middleware/auth.middleware";
import { ApiResponse } from "@/types/global";
import { updateFcmToken } from "@/modules/auth/auth.service";

export const PUT = errorHandler(async (request: NextRequest) => {
    // Verify authentication
    const authResult = await requireAuth(request);
    if (!authResult.authorized) return authResult.response;

    const body = await request.json();
    const fcmToken = body?.fcmToken;

    if (!fcmToken || typeof fcmToken !== "string") {
        throw new ValidationError("FCM token is required", "fcmToken");
    }

    // Update FCM token for the authenticated user
    await updateFcmToken(authResult.user.userId, fcmToken);

    const response: ApiResponse<null> = {
        success: true,
        data: null,
        message: "FCM token updated successfully",
    };

    return NextResponse.json(response, { status: 200 });
});
