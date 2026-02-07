/**
 * POST /api/v1/orders/:id/cancel (auth)
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler, NotFoundError } from "@/middleware/error.middleware";
import { requireAuth } from "@/middleware/auth.middleware";
import { ApiResponse } from "@/types/global";
import { cancelOrderByUser } from "@/modules/orders/orders.service";
import { findOrderById } from "@/modules/orders/orders.repo";

export const POST = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const authResult = await requireAuth(request);
		if (!authResult.authorized) return authResult.response;

		const order = await findOrderById(params.id);
		if (!order || order.userId !== authResult.user.userId) {
			throw new NotFoundError("Order");
		}

		const cancelled = await cancelOrderByUser(params.id);

		const response: ApiResponse<typeof cancelled> = {
			success: true,
			data: cancelled,
			message: "Order cancelled",
		};

		return NextResponse.json(response, { status: 200 });
	},
);
