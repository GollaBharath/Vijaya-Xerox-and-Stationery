/**
 * GET /api/v1/orders (auth)
 * POST /api/v1/orders (auth)
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { requireAuth } from "@/middleware/auth.middleware";
import { ApiResponse } from "@/types/global";
import {
	getPaginationFromUrl,
	parsePaginationParams,
	createPaginationMeta,
} from "@/utils/pagination";
import { prisma } from "@/lib/prisma";
import { validateCheckout } from "@/modules/orders/orders.validator";
import { checkoutCart } from "@/modules/orders/orders.service";
import { findOrdersByUserId } from "@/modules/orders/orders.repo";

export const GET = errorHandler(async (request: NextRequest) => {
	const authResult = await requireAuth(request);
	if (!authResult.authorized) return authResult.response;

	const url = new URL(request.url);
	const { page, limit, skip } = parsePaginationParams(
		getPaginationFromUrl(url),
	);

	const orders = await findOrdersByUserId(authResult.user.userId, {
		skip,
		take: limit,
	});
	const total = await prisma.order.count({
		where: { userId: authResult.user.userId },
	});

	const response: ApiResponse<typeof orders> = {
		success: true,
		data: orders,
		pagination: createPaginationMeta(page, limit, total),
	};

	return NextResponse.json(response, { status: 200 });
});

export const POST = errorHandler(async (request: NextRequest) => {
	const authResult = await requireAuth(request);
	if (!authResult.authorized) return authResult.response;

	const body = await request.json();
	const payload = validateCheckout(body);

	const result = await checkoutCart(authResult.user.userId, payload.address);

	const response: ApiResponse<typeof result> = {
		success: true,
		data: result,
		message: "Order created successfully",
	};

	return NextResponse.json(response, { status: 201 });
});
