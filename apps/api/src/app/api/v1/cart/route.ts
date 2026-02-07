/**
 * GET /api/v1/cart
 * POST /api/v1/cart (auth)
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler, NotFoundError } from "@/middleware/error.middleware";
import { requireAuth } from "@/middleware/auth.middleware";
import { ApiResponse } from "@/types/global";
import {
	getPaginationFromUrl,
	parsePaginationParams,
	createPaginationMeta,
} from "@/utils/pagination";
import { prisma } from "@/lib/prisma";
import { validateAddToCart } from "@/modules/cart/cart.validator";
import {
	addToCart,
	getCartItems,
	getCartTotal,
} from "@/modules/cart/cart.repo";

export const GET = errorHandler(async (request: NextRequest) => {
	const authResult = await requireAuth(request);
	if (!authResult.authorized) return authResult.response;

	const url = new URL(request.url);
	const { page, limit, skip } = parsePaginationParams(
		getPaginationFromUrl(url),
	);

	const items = await getCartItems(authResult.user.userId, {
		skip,
		take: limit,
	});
	const total = await getCartTotal(authResult.user.userId);
	const count = await prisma.cartItem.count({
		where: { userId: authResult.user.userId },
	});

	const response: ApiResponse<{ items: typeof items; total: number }> = {
		success: true,
		data: { items, total },
		pagination: createPaginationMeta(page, limit, count),
	};

	return NextResponse.json(response, { status: 200 });
});

export const POST = errorHandler(async (request: NextRequest) => {
	const authResult = await requireAuth(request);
	if (!authResult.authorized) return authResult.response;

	const body = await request.json();
	const payload = validateAddToCart(body);

	const variant = await prisma.productVariant.findUnique({
		where: { id: payload.productVariantId },
		include: { product: true },
	});

	if (!variant || !variant.product.isActive) {
		throw new NotFoundError("Product variant");
	}

	const item = await addToCart(
		authResult.user.userId,
		payload.productVariantId,
		payload.quantity,
	);

	const response: ApiResponse<typeof item> = {
		success: true,
		data: item,
		message: "Item added to cart",
	};

	return NextResponse.json(response, { status: 201 });
});
