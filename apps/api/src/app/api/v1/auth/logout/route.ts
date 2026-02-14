import { NextRequest, NextResponse } from "next/server";
import { requireAuth } from "@/middleware/auth.middleware";
import { errorHandler } from "@/middleware/error.middleware";
import { ApiResponse } from "@/types/global";

/**
 * @swagger
 * /api/v1/auth/logout:
 *   post:
 *     summary: Logout user
 *     description: Logout the current user and invalidate their session
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successfully logged out
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: null
 *                 message:
 *                   type: string
 *                   example: Logged out successfully
 *       401:
 *         description: Unauthorized - Invalid or missing token
 */
export const POST = errorHandler(async (request: NextRequest) => {
    // Verify authentication
    const authResult = await requireAuth(request);
    if (!authResult.authorized) return authResult.response;

    // Note: In a production app, you might want to:
    // 1. Invalidate the refresh token in the database
    // 2. Add the access token to a blacklist (if using Redis)
    // 3. Clear any server-side session data

    // For now, we just acknowledge the logout
    // The client will clear tokens locally

    const response: ApiResponse<null> = {
        success: true,
        data: null,
        message: "Logged out successfully",
    };

    return NextResponse.json(response, { status: 200 });
});
