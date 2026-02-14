import { NextRequest, NextResponse } from "next/server";
import { authenticate } from "@/middleware/auth.middleware";
import { getUserLikes } from "@/modules/product-likes/product-likes.service";
import { handleError } from "@/middleware/error.middleware";

/**
 * GET /api/v1/me/likes
 * Get all products liked by current user
 */
export async function GET(req: NextRequest) {
	try {
		const user = await authenticate(req, { required: true });
		const likes = await getUserLikes(user!.userId);

		return NextResponse.json({ data: likes });
	} catch (error: any) {
		return handleError(error);
	}
}
