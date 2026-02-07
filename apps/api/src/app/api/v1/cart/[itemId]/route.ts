/**
 * PATCH /api/v1/cart/:itemId
 * DELETE /api/v1/cart/:itemId
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler, NotFoundError } from "@/middleware/error.middleware";
import { requireAuth } from "@/middleware/auth.middleware";
import { ApiResponse } from "@/types/global";
import { prisma } from "@/lib/prisma";
import { validateUpdateCartItem } from "@/modules/cart/cart.validator";
import { updateCartItem, removeFromCart } from "@/modules/cart/cart.repo";

export const PATCH = errorHandler(
	async (request: NextRequest, { params }: { params: { itemId: string } }) => {
		const authResult = await requireAuth(request);
		if (!authResult.authorized) return authResult.response;

		const existing = await prisma.cartItem.findFirst({
			where: { id: params.itemId, userId: authResult.user.userId },
		});

		if (!existing) throw new NotFoundError("Cart item");

		const body = await request.json();
		const payload = validateUpdateCartItem(body);

		const updated = await updateCartItem(params.itemId, payload.quantity);

		const response: ApiResponse<typeof updated> = {
			success: true,
			data: updated,
			message: "Cart item updated",
		};

		return NextResponse.json(response, { status: 200 });
	},
);

export const DELETE = errorHandler(
	async (request: NextRequest, { params }: { params: { itemId: string } }) => {
		const authResult = await requireAuth(request);
		if (!authResult.authorized) return authResult.response;

		const existing = await prisma.cartItem.findFirst({
			where: { id: params.itemId, userId: authResult.user.userId },
		});

		if (!existing) throw new NotFoundError("Cart item");

		await removeFromCart(params.itemId);

		const response: ApiResponse<{ removed: boolean }> = {
			success: true,
			data: { removed: true },
			message: "Cart item removed",
		};

		return NextResponse.json(response, { status: 200 });
	},
);
