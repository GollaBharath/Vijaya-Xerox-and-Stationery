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
import { sendOrderStatusNotificationToUser } from "@/modules/notifications/notifications.service";

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

		// Check if status is a valid OrderStatus enum value
		const validStatuses = Object.values(OrderStatus);
		if (!validStatuses.includes(status as OrderStatus)) {
			throw new ValidationError(
				`Invalid order status. Must be one of: ${validStatuses.join(", ")}`,
				"status"
			);
		}

		const updated = await updateOrderStatus(params.id, status as OrderStatus);

		// Send notification to user (async, don't wait for completion)
		sendOrderStatusNotificationToUser({
			orderId: updated.id,
			status: updated.status,
			userId: updated.userId,
		}).catch((error: any) => {
			// Already logged in notification service, just catch to prevent unhandled rejection
		});

		const response: ApiResponse<typeof updated> = {
			success: true,
			data: updated,
			message: "Order status updated",
		};

		return NextResponse.json(response, { status: 200 });
	},
);
