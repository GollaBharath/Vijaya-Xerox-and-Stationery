/**
 * Admin Authorization Middleware
 *
 * Verifies that the authenticated user has admin role
 */

import { NextRequest, NextResponse } from "next/server";
import { requireAuth } from "./auth.middleware";
import { ApiError, ErrorCode } from "@/types/global";

/**
 * Admin authorization middleware
 *
 * Checks both authentication and admin role
 *
 * Usage in route handler:
 * const adminResult = await requireAdmin(request);
 * if (!adminResult.authorized) return adminResult.response;
 * const { userId } = adminResult.user;
 */
export async function requireAdmin(
	request: NextRequest,
): Promise<
	| { authorized: true; user: { userId: string; role: "ADMIN" } }
	| { authorized: false; response: NextResponse }
> {
	// First check authentication
	const authResult = await requireAuth(request);

	if (!authResult.authorized) {
		return authResult;
	}

	// Then check admin role
	if (authResult.user.role !== "ADMIN") {
		const error: ApiError = {
			success: false,
			error: {
				code: ErrorCode.FORBIDDEN,
				message: "Access denied. Admin privileges required.",
			},
		};
		return {
			authorized: false,
			response: NextResponse.json(error, { status: 403 }),
		};
	}

	return {
		authorized: true,
		user: {
			userId: authResult.user.userId,
			role: "ADMIN",
		},
	};
}
