import { NextRequest, NextResponse } from "next/server";
import { authenticate } from "@/middleware/auth.middleware";
import {
	submitFeedback,
	getFeedbackForOrder,
} from "@/modules/order-feedback/order-feedback.service";
import { handleError } from "@/middleware/error.middleware";
import { z } from "zod";

const feedbackSchema = z.object({
	rating: z.number().min(1).max(5),
	comment: z.string().optional(),
});

/**
 * GET /api/v1/orders/:id/feedback
 * Get feedback for an order (if exists)
 */
export async function GET(
	req: NextRequest,
	{ params }: { params: { id: string } },
) {
	try {
		await authenticate(req, { required: true });
		const feedback = await getFeedbackForOrder(params.id);
		return NextResponse.json({ data: feedback });
	} catch (error: any) {
		return handleError(error);
	}
}

/**
 * POST /api/v1/orders/:id/feedback
 * Submit feedback for an order
 */
export async function POST(
	req: NextRequest,
	{ params }: { params: { id: string } },
) {
	try {
		const user = await authenticate(req, { required: true });
		const body = await req.json();

		const validatedData = feedbackSchema.parse(body);

		const feedback = await submitFeedback(
			params.id,
			user!.userId,
			validatedData.rating,
			validatedData.comment,
		);

		return NextResponse.json(
			{
				data: feedback,
				message: "Feedback submitted successfully",
			},
			{ status: 201 },
		);
	} catch (error: any) {
		return handleError(error);
	}
}
