import { AppError, NotFoundError } from "@/middleware/error.middleware";
import { ErrorCode } from "@/types/global";
import * as repo from "./order-feedback.repo";
import { FeedbackResponse } from "./order-feedback.types";

function toFeedbackResponse(feedback: any): FeedbackResponse {
	return {
		id: feedback.id,
		orderId: feedback.orderId,
		userId: feedback.userId,
		userName: feedback.user?.name || "Unknown",
		rating: feedback.rating,
		comment: feedback.comment,
		createdAt: feedback.createdAt.toISOString(),
		updatedAt: feedback.updatedAt.toISOString(),
		order: feedback.order
			? {
					id: feedback.order.id,
					totalPrice: feedback.order.totalPrice,
					itemCount: feedback.order.items?.length || 0,
					createdAt: feedback.order.createdAt.toISOString(),
				}
			: undefined,
	};
}

export async function submitFeedback(
	orderId: string,
	userId: string,
	rating: number,
	comment?: string,
) {
	// Validate rating
	if (rating < 1 || rating > 5) {
		throw new AppError(
			ErrorCode.BAD_REQUEST,
			"Rating must be between 1 and 5",
			400,
		);
	}

	// Check if user owns the order
	const isOwner = await repo.isOrderOwnedByUser(orderId, userId);
	if (!isOwner) {
		throw new AppError(
			ErrorCode.FORBIDDEN,
			"You can only submit feedback for your own orders",
			403,
		);
	}

	// Check if order is delivered
	const isDelivered = await repo.isOrderDelivered(orderId);
	if (!isDelivered) {
		throw new AppError(
			ErrorCode.BAD_REQUEST,
			"Feedback can only be submitted for delivered orders",
			400,
		);
	}

	// Check if feedback already exists
	const existingFeedback = await repo.getFeedbackByOrderId(orderId);
	if (existingFeedback) {
		throw new AppError(
			ErrorCode.BAD_REQUEST,
			"Feedback already submitted for this order",
			400,
		);
	}

	// Create feedback
	const feedback = await repo.createFeedback(orderId, userId, rating, comment);
	return toFeedbackResponse(feedback);
}

export async function getFeedbackForOrder(orderId: string) {
	const feedback = await repo.getFeedbackByOrderId(orderId);
	if (!feedback) {
		throw new NotFoundError("Feedback not found for this order");
	}
	return toFeedbackResponse(feedback);
}

export async function listAllFeedbacks(page: number = 1, limit: number = 20) {
	const result = await repo.getAllFeedbacks(page, limit);
	return {
		feedbacks: result.feedbacks.map(toFeedbackResponse),
		pagination: {
			page,
			limit,
			total: result.total,
			pages: result.pages,
		},
	};
}

export async function getFeedbackStatistics() {
	return await repo.getFeedbackStats();
}
