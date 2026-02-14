import { prisma } from "@/lib/prisma";
import { OrderStatus } from "@prisma/client";

/**
 * Create feedback for an order
 */
export async function createFeedback(
	orderId: string,
	userId: string,
	rating: number,
	comment?: string,
) {
	return await prisma.orderFeedback.create({
		data: {
			orderId,
			userId,
			rating,
			comment,
		},
		include: {
			user: {
				select: {
					id: true,
					name: true,
					email: true,
				},
			},
			order: {
				select: {
					id: true,
					totalPrice: true,
					createdAt: true,
					items: {
						select: {
							id: true,
						},
					},
				},
			},
		},
	});
}

/**
 * Get feedback by order ID
 */
export async function getFeedbackByOrderId(orderId: string) {
	return await prisma.orderFeedback.findUnique({
		where: { orderId },
		include: {
			user: {
				select: {
					id: true,
					name: true,
					email: true,
				},
			},
			order: {
				select: {
					id: true,
					totalPrice: true,
					createdAt: true,
					items: {
						select: {
							id: true,
						},
					},
				},
			},
		},
	});
}

/**
 * Check if user owns the order
 */
export async function isOrderOwnedByUser(
	orderId: string,
	userId: string,
): Promise<boolean> {
	const order = await prisma.order.findUnique({
		where: { id: orderId, userId },
		select: { id: true },
	});
	return order !== null;
}

/**
 * Check if order is delivered
 */
export async function isOrderDelivered(orderId: string): Promise<boolean> {
	const order = await prisma.order.findUnique({
		where: { id: orderId },
		select: { status: true },
	});
	return order?.status === OrderStatus.DELIVERED;
}

/**
 * Get all feedbacks with pagination (admin)
 */
export async function getAllFeedbacks(page: number = 1, limit: number = 20) {
	const skip = (page - 1) * limit;

	const [feedbacks, total] = await Promise.all([
		prisma.orderFeedback.findMany({
			skip,
			take: limit,
			orderBy: { createdAt: "desc" },
			include: {
				user: {
					select: {
						id: true,
						name: true,
						email: true,
					},
				},
				order: {
					select: {
						id: true,
						totalPrice: true,
						createdAt: true,
						items: {
							select: {
								id: true,
							},
						},
					},
				},
			},
		}),
		prisma.orderFeedback.count(),
	]);

	return {
		feedbacks,
		total,
		pages: Math.ceil(total / limit),
	};
}

/**
 * Get feedback statistics
 */
export async function getFeedbackStats() {
	const [total, avgRating, ratingDistribution] = await Promise.all([
		prisma.orderFeedback.count(),
		prisma.orderFeedback.aggregate({
			_avg: { rating: true },
		}),
		prisma.orderFeedback.groupBy({
			by: ["rating"],
			_count: { rating: true },
		}),
	]);

	return {
		totalFeedbacks: total,
		averageRating: avgRating._avg.rating || 0,
		ratingDistribution: ratingDistribution.reduce(
			(
				acc: Record<number, number>,
				item: { rating: number; _count: { rating: number } },
			) => {
				acc[item.rating] = item._count.rating;
				return acc;
			},
			{} as Record<number, number>,
		),
	};
}
