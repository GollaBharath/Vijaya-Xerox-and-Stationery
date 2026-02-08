/**
 * POST /api/v1/admin/orders/:id/cancel
 */

import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/middleware/admin.middleware";
import {
	errorHandler,
	NotFoundError,
	ValidationError,
} from "@/middleware/error.middleware";
import { ApiResponse } from "@/types/global";
import { cancelOrder, findOrderById } from "@/modules/orders/orders.repo";
import { OrderStatus } from "@prisma/client";

export const POST = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const order = await findOrderById(params.id);
		if (!order) throw new NotFoundError("Order");

		if (order.status === OrderStatus.DELIVERED) {
			throw new ValidationError("Order already delivered", "status");
		}

		const cancelled = await cancelOrder(params.id);

		const response: ApiResponse<typeof cancelled> = {
			success: true,
			data: cancelled,
			message: "Order cancelled",
		};

		return NextResponse.json(response, { status: 200 });
	},
);
