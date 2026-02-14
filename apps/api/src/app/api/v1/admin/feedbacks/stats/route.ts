import { NextRequest, NextResponse } from "next/server";
import { authenticate } from "@/middleware/auth.middleware";
import { getFeedbackStatistics } from "@/modules/order-feedback/order-feedback.service";
import { handleError } from "@/middleware/error.middleware";

/**
 * GET /api/v1/admin/feedbacks/stats
 * Get feedback statistics (admin only)
 */
export async function GET(req: NextRequest) {
	try {
		await authenticate(req, { required: true, adminOnly: true });
		const stats = await getFeedbackStatistics();
		return NextResponse.json({ data: stats });
	} catch (error: any) {
		return handleError(error);
	}
}
