/**
 * GET /api/v1/admin/orders
 */

import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/middleware/admin.middleware";
import { errorHandler, ValidationError } from "@/middleware/error.middleware";
import { ApiResponse } from "@/types/global";
import {
	createPaginationMeta,
	getPaginationFromUrl,
	parsePaginationParams,
} from "@/utils/pagination";
import { findAllOrders } from "@/modules/orders/orders.repo";
import { prisma } from "@/lib/prisma";
import { OrderStatus, Prisma } from "@prisma/client";

export const GET = errorHandler(async (request: NextRequest) => {
	const adminResult = await requireAdmin(request);
	if (!adminResult.authorized) return adminResult.response;

	const url = new URL(request.url);
	const { page, limit, skip } = parsePaginationParams(
		getPaginationFromUrl(url),
	);

	const statusParam = url.searchParams.get("status");
	let status: OrderStatus | undefined;
	if (statusParam) {
		if (!(statusParam in OrderStatus)) {
			throw new ValidationError("Invalid order status", "status");
		}
		status = statusParam as OrderStatus;
	}

	const dateParam = url.searchParams.get("date");
	let dateFrom: Date | undefined;
	let dateTo: Date | undefined;
	if (dateParam) {
		const parsed = new Date(dateParam);
		if (Number.isNaN(parsed.getTime())) {
			throw new ValidationError("Invalid date", "date");
		}
		dateFrom = new Date(parsed);
		dateFrom.setUTCHours(0, 0, 0, 0);
		dateTo = new Date(parsed);
		dateTo.setUTCHours(23, 59, 59, 999);
	}

	const where: Prisma.OrderWhereInput = {
		status,
		createdAt:
			dateFrom || dateTo
				? {
						gte: dateFrom,
						lte: dateTo,
					}
				: undefined,
	};

	const [orders, total] = await Promise.all([
		findAllOrders(
			{ skip, take: limit },
			{
				status,
				dateFrom,
				dateTo,
			},
		),
		prisma.order.count({ where }),
	]);

	const response: ApiResponse<typeof orders> = {
		success: true,
		data: orders,
		pagination: createPaginationMeta(page, limit, total),
	};

	return NextResponse.json(response, { status: 200 });
});
