import { NextRequest, NextResponse } from "next/server";
import { authenticate } from "@/middleware/auth.middleware";
import {
	toggleProductLike,
	getProductLikeStats,
} from "@/modules/product-likes/product-likes.service";
import { handleError } from "@/middleware/error.middleware";

/**
 * GET /api/v1/products/:id/like
 * Get like stats for a product
 */
export async function GET(
	req: NextRequest,
	{ params }: { params: { id: string } },
) {
	try {
		const user = await authenticate(req, { required: false });
		const stats = await getProductLikeStats(params.id, user?.userId);

		return NextResponse.json({ data: stats });
	} catch (error: any) {
		return handleError(error);
	}
}

/**
 * POST /api/v1/products/:id/like
 * Toggle like on a product (add or remove)
 */
export async function POST(
	req: NextRequest,
	{ params }: { params: { id: string } },
) {
	try {
		const user = await authenticate(req, { required: true });
		const result = await toggleProductLike(user!.userId, params.id);

		return NextResponse.json({
			data: result,
			message: result.liked ? "Product liked" : "Like removed",
		});
	} catch (error: any) {
		return handleError(error);
	}
}
