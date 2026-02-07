/**
 * GET /api/v1/orders/:id (auth)
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler, NotFoundError } from "@/middleware/error.middleware";
import { requireAuth } from "@/middleware/auth.middleware";
import { ApiResponse } from "@/types/global";
import { getOrderDetails } from "@/modules/orders/orders.service";

export const GET = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const authResult = await requireAuth(request);
		if (!authResult.authorized) return authResult.response;

		const order = await getOrderDetails(params.id);
		if (order.userId !== authResult.user.userId) {
			throw new NotFoundError("Order");
		}

		const response: ApiResponse<typeof order> = {
			success: true,
			data: order,
		};

		return NextResponse.json(response, { status: 200 });
	},
);
