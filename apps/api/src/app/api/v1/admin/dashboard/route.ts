/**
 * GET /api/v1/admin/dashboard
 */

import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/middleware/admin.middleware";
import { errorHandler } from "@/middleware/error.middleware";
import { ApiResponse } from "@/types/global";
import { prisma } from "@/lib/prisma";
import { PaymentStatus } from "@prisma/client";

export const GET = errorHandler(async (request: NextRequest) => {
	const adminResult = await requireAdmin(request);
	if (!adminResult.authorized) return adminResult.response;

	const [totalUsers, totalOrders, revenueResult, recentOrders] =
		await Promise.all([
			prisma.user.count(),
			prisma.order.count(),
			prisma.order.aggregate({
				_sum: { totalPrice: true },
				where: { paymentStatus: PaymentStatus.COMPLETED },
			}),
			prisma.order.findMany({
				take: 5,
				orderBy: { createdAt: "desc" },
				include: { user: true },
			}),
		]);

	const response: ApiResponse<{
		totalUsers: number;
		totalOrders: number;
		totalRevenue: number;
		recentOrders: Array<{
			id: string;
			userId: string;
			userName: string;
			totalPrice: number;
			status: string;
			paymentStatus: string;
			createdAt: string;
		}>;
	}> = {
		success: true,
		data: {
			totalUsers,
			totalOrders,
			totalRevenue: revenueResult._sum.totalPrice ?? 0,
			recentOrders: recentOrders.map((o) => ({
				id: o.id,
				userId: o.userId,
				userName: o.user.name,
				totalPrice: o.totalPrice,
				status: o.status,
				paymentStatus: o.paymentStatus,
				createdAt: o.createdAt.toISOString(),
			})),
		},
	};

	return NextResponse.json(response, { status: 200 });
});
