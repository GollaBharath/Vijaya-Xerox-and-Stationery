/**
 * Orders Repository
 */

import { prisma } from "@/lib/prisma";
import { Order, OrderFilterOptions, OrderItem } from "./orders.types";
import { OrderStatus, PaymentStatus, Prisma } from "@prisma/client";

function toOrder(entity: any): Order {
	return {
		id: entity.id,
		userId: entity.userId,
		status: entity.status,
		totalPrice: entity.totalPrice,
		paymentStatus: entity.paymentStatus,
		addressSnapshot: entity.addressSnapshot ?? null,
		createdAt: entity.createdAt.toISOString(),
		updatedAt: entity.updatedAt.toISOString(),
		items: entity.items
			? entity.items.map((i: any) => toOrderItem(i))
			: undefined,
	};
}

function toOrderItem(entity: any): OrderItem {
	return {
		id: entity.id,
		orderId: entity.orderId,
		productVariantId: entity.productVariantId,
		quantity: entity.quantity,
		priceSnapshot: entity.priceSnapshot,
		createdAt: entity.createdAt.toISOString(),
		productVariant: entity.productVariant
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

export async function findOrderById(id: string): Promise<Order | null> {
	const order = await prisma.order.findUnique({
		where: { id },
		include: {
			items: {
				include: { productVariant: { include: { product: true } } },
			},
		},
	});
	return order ? toOrder(order) : null;
}

export async function findOrdersByUserId(
	userId: string,
	pagination: { skip: number; take: number },
): Promise<Order[]> {
	const orders = await prisma.order.findMany({
		where: { userId },
		skip: pagination.skip,
		take: pagination.take,
		orderBy: { createdAt: "desc" },
	});

	return orders.map(toOrder);
}

export async function findAllOrders(
	pagination: { skip: number; take: number },
	filters: OrderFilterOptions = {},
): Promise<Order[]> {
	const orders = await prisma.order.findMany({
		where: {
			status: filters.status ?? undefined,
			paymentStatus: filters.paymentStatus ?? undefined,
			userId: filters.userId ?? undefined,
			createdAt:
				filters.dateFrom || filters.dateTo
					? {
							gte: filters.dateFrom ?? undefined,
							lte: filters.dateTo ?? undefined,
						}
					: undefined,
		},
		skip: pagination.skip,
		take: pagination.take,
		orderBy: { createdAt: "desc" },
	});

	return orders.map(toOrder);
}

export async function createOrder(data: {
	userId: string;
	orderItems: Array<{
		productVariantId: string;
		quantity: number;
		priceSnapshot: number;
	}>;
	addressSnapshot: Record<string, unknown>;
	totalPrice: number;
}): Promise<Order> {
	const order = await prisma.order.create({
		data: {
			userId: data.userId,
			totalPrice: data.totalPrice,
			addressSnapshot: data.addressSnapshot as Prisma.InputJsonValue,
			items: {
				createMany: {
					data: data.orderItems.map((item) => ({
						productVariantId: item.productVariantId,
						quantity: item.quantity,
						priceSnapshot: item.priceSnapshot,
					})),
				},
			},
		},
		include: {
			items: {
				include: { productVariant: { include: { product: true } } },
			},
		},
	});

	return toOrder(order);
}

export async function updateOrderStatus(
	id: string,
	status: OrderStatus,
): Promise<Order> {
	const order = await prisma.order.update({
		where: { id },
		data: { status },
	});
	return toOrder(order);
}

export async function updatePaymentStatus(
	id: string,
	paymentStatus: PaymentStatus,
): Promise<Order> {
	const order = await prisma.order.update({
		where: { id },
		data: { paymentStatus },
	});
	return toOrder(order);
}

export async function cancelOrder(id: string): Promise<Order> {
	const order = await prisma.order.update({
		where: { id },
		data: { status: OrderStatus.CANCELLED },
	});
	return toOrder(order);
}
