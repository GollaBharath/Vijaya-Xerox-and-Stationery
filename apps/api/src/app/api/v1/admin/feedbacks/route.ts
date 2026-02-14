import { NextRequest, NextResponse } from "next/server";
import { authenticate } from "@/middleware/auth.middleware";
import { listAllFeedbacks } from "@/modules/order-feedback/order-feedback.service";
import { handleError } from "@/middleware/error.middleware";

/**
 * GET /api/v1/admin/feedbacks
 * List all customer feedbacks (admin only)
 */
export async function GET(req: NextRequest) {
	try {
		await authenticate(req, { required: true, adminOnly: true });

		const { searchParams } = new URL(req.url);
		const page = parseInt(searchParams.get("page") || "1");
		const limit = parseInt(searchParams.get("limit") || "20");

		const result = await listAllFeedbacks(page, limit);

		return NextResponse.json({
			data: result.feedbacks,
			pagination: result.pagination,
		});
	} catch (error: any) {
		return handleError(error);
	}
}
