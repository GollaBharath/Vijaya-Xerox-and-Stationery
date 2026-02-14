/**
 * Orders Service
 */

import { prisma } from "@/lib/prisma";
import { AppError, NotFoundError } from "@/middleware/error.middleware";
import { ErrorCode } from "@/types/global";
import { getCartItems } from "@/modules/cart/cart.repo";
import { Order, CheckoutResponse } from "./orders.types";
import { findOrderById, cancelOrder } from "./orders.repo";
import { OrderStatus, Prisma } from "@prisma/client";
import { sendOrderNotificationToAdmins } from "@/modules/notifications/notifications.service";

export async function checkoutCart(
	userId: string,
	address: Record<string, unknown>,
): Promise<CheckoutResponse> {
	const cartItems = await getCartItems(userId);

	if (cartItems.length === 0) {
		throw new AppError(ErrorCode.BAD_REQUEST, "Cart is empty", 400);
	}

	// Validate stock and active products
	for (const item of cartItems) {
		const variant = item.variant;
		if (!variant || !variant.product || !variant.product.isActive) {
			throw new NotFoundError("Product variant");
		}
		if (variant.stock < item.quantity) {
			throw new AppError(
				ErrorCode.INSUFFICIENT_STOCK,
				"Insufficient stock for one or more items",
				400,
			);
		}
	}

	const orderItems = cartItems.map((item) => ({
		productVariantId: item.productVariantId,
		quantity: item.quantity,
		priceSnapshot: item.variant?.price ?? 0,
	}));

	const totalPrice = orderItems.reduce(
		(sum, item) => sum + item.priceSnapshot * item.quantity,
		0,
	);

	const order = await prisma.$transaction(async (tx) => {
		// Create order + items
		const created = await tx.order.create({
			data: {
				userId,
				totalPrice,
				addressSnapshot: address as Prisma.InputJsonValue,
				items: {
					createMany: {
						data: orderItems,
					},
				},
			},
			include: {
				items: {
					include: { productVariant: { include: { product: true } } },
				},
			},
		});

		// Decrement stock
		for (const item of orderItems) {
			await tx.productVariant.update({
				where: { id: item.productVariantId },
				data: { stock: { decrement: item.quantity } },
			});
		}

		// Clear cart
		await tx.cartItem.deleteMany({ where: { userId } });

		return created;
	});

	// Send notification to admins (async, don't wait for completion)
	sendOrderNotificationToAdmins({
		orderId: order.id,
		totalPrice: order.totalPrice,
		customerName: cartItems[0]?.user?.name || "Customer",
		itemCount: order.items?.length || 0,
	}).catch((error: any) => {
		// Already logged in notification service, just catch to prevent unhandled rejection
	});

	return { order: createOrderToResponse(order) };
}

function createOrderToResponse(order: any): Order {
	return {
		id: order.id,
		userId: order.userId,
		status: order.status,
		totalPrice: order.totalPrice,
		paymentStatus: order.paymentStatus,
		addressSnapshot: order.addressSnapshot ?? null,
		createdAt: order.createdAt.toISOString(),
		updatedAt: order.updatedAt.toISOString(),
		items: order.items
			? order.items.map((i: any) => ({
				id: i.id,
				orderId: i.orderId,
				productVariantId: i.productVariantId,
				quantity: i.quantity,
				priceSnapshot: i.priceSnapshot,
				createdAt: i.createdAt.toISOString(),
				productVariant: i.productVariant
					? {
						id: i.productVariant.id,
						productId: i.productVariant.productId,
						variantType: i.productVariant.variantType,
						price: i.productVariant.price,
						stock: i.productVariant.stock,
						sku: i.productVariant.sku,
						product: i.productVariant.product
							? {
								id: i.productVariant.product.id,
								title: i.productVariant.product.title,
								basePrice: i.productVariant.product.basePrice,
								isActive: i.productVariant.product.isActive,
							}
							: undefined,
					}
					: undefined,
			}))
			: undefined,
	};
}

export async function getOrderDetails(orderId: string): Promise<Order> {
	const order = await findOrderById(orderId);
	if (!order) throw new NotFoundError("Order");
	return order;
}

export async function cancelOrderByUser(orderId: string): Promise<Order> {
	const order = await findOrderById(orderId);
	if (!order) throw new NotFoundError("Order");

	if (order.status === OrderStatus.DELIVERED) {
		throw new AppError(ErrorCode.BAD_REQUEST, "Order already delivered", 400);
	}

	return cancelOrder(orderId);
}
