/**
 * Cart Repository
 */

import { prisma } from "@/lib/prisma";
import { logger } from "@/lib/logger";
import { CartItem, CartResponse } from "./cart.types";

function toCartItem(entity: any): CartItem {
	return {
		id: entity.id,
		userId: entity.userId,
		productVariantId: entity.productVariantId,
		quantity: entity.quantity,
		createdAt: entity.createdAt.toISOString(),
		updatedAt: entity.updatedAt.toISOString(),
		variant: entity.productVariant
			? {
				id: entity.productVariant.id,
				productId: entity.productVariant.productId,
				variantType: entity.productVariant.variantType,
				price: entity.productVariant.price,
				stock: entity.productVariant.stock,
				sku: entity.productVariant.sku,
				product: entity.productVariant.product
					? {
						id: entity.productVariant.product.id,
						title: entity.productVariant.product.title,
						basePrice: entity.productVariant.product.basePrice,
						isActive: entity.productVariant.product.isActive,
					}
					: undefined,
			}
			: undefined,
	};
}

export async function getCartItems(
	userId: string,
	pagination?: { skip: number; take: number },
): Promise<CartItem[]> {
	const items = await prisma.cartItem.findMany({
		where: { userId },
		include: {
			user: true,
			productVariant: {
				include: { product: true },
			},
		},
		orderBy: { createdAt: "desc" },
		skip: pagination?.skip,
		take: pagination?.take,
	});

	return items.map(toCartItem);
}

export async function getCartByUserId(userId: string): Promise<CartResponse> {
	const items = await getCartItems(userId);
	const total = items.reduce(
		(sum, item) => sum + (item.variant?.price ?? 0) * item.quantity,
		0,
	);

	return { items, total };
}

export async function addToCart(
	userId: string,
	productVariantId: string,
	quantity: number,
): Promise<CartItem> {
	logger.info("Adding to cart", { userId, productVariantId, quantity });

	const item = await prisma.cartItem.upsert({
		where: {
			userId_productVariantId: {
				userId,
				productVariantId,
			},
		},
		update: {
			quantity: { increment: quantity },
		},
		create: {
			userId,
			productVariantId,
			quantity,
		},
		include: {
			productVariant: {
				include: { product: true },
			},
		},
	});

	return toCartItem(item);
}

export async function updateCartItem(
	cartItemId: string,
	quantity: number,
): Promise<CartItem> {
	const item = await prisma.cartItem.update({
		where: { id: cartItemId },
		data: { quantity },
		include: {
			productVariant: {
				include: { product: true },
			},
		},
	});

	return toCartItem(item);
}

export async function removeFromCart(cartItemId: string): Promise<void> {
	await prisma.cartItem.delete({
		where: { id: cartItemId },
	});
}

export async function clearCart(userId: string): Promise<void> {
	await prisma.cartItem.deleteMany({
		where: { userId },
	});
}

export async function getCartTotal(userId: string): Promise<number> {
	const items = await prisma.cartItem.findMany({
		where: { userId },
		select: {
			quantity: true,
			productVariant: { select: { price: true } },
		},
	});

	return items.reduce(
		(sum, item) => sum + item.quantity * item.productVariant.price,
		0,
	);
}
