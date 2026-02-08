/**
 * GET /api/v1/admin/orders/:id
 * PATCH /api/v1/admin/orders/:id
 */

import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/middleware/admin.middleware";
import {
	errorHandler,
	NotFoundError,
	ValidationError,
} from "@/middleware/error.middleware";
import { ApiResponse } from "@/types/global";
import { findOrderById, updateOrderStatus } from "@/modules/orders/orders.repo";
import { OrderStatus } from "@prisma/client";

export const GET = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const order = await findOrderById(params.id);
		if (!order) throw new NotFoundError("Order");

		const response: ApiResponse<typeof order> = {
			success: true,
			data: order,
		};

		return NextResponse.json(response, { status: 200 });
	},
);

export const PATCH = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const body = await request.json();
		const status = body?.status;

		if (!status || typeof status !== "string") {
			throw new ValidationError("Order status is required", "status");
		}
		if (!(status in OrderStatus)) {
			throw new ValidationError("Invalid order status", "status");
		}

		const updated = await updateOrderStatus(params.id, status as OrderStatus);

		const response: ApiResponse<typeof updated> = {
			success: true,
			data: updated,
			message: "Order status updated",
		};

		return NextResponse.json(response, { status: 200 });
	},
);
