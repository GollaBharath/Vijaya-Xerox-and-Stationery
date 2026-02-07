/**
 * Orders Module Type Definitions
 */

import { OrderStatus, PaymentStatus, VariantType } from "@prisma/client";

export interface OrderItem {
	id: string;
	orderId: string;
	productVariantId: string;
	quantity: number;
	priceSnapshot: number;
	createdAt: string;
	productVariant?: {
		id: string;
		productId: string;
		variantType: VariantType;
		price: number;
		stock: number;
		sku: string;
		product?: {
			id: string;
			title: string;
			basePrice: number;
			isActive: boolean;
		};
	};
}

export interface Order {
	id: string;
	userId: string;
	status: OrderStatus;
	totalPrice: number;
	paymentStatus: PaymentStatus;
	addressSnapshot?: Record<string, unknown> | null;
	createdAt: string;
	updatedAt: string;
	items?: OrderItem[];
}

export interface OrderListResponse {
	orders: Order[];
}

export interface OrderFilterOptions {
	status?: OrderStatus;
	paymentStatus?: PaymentStatus;
	userId?: string;
}

export interface CheckoutRequest {
	address: Record<string, unknown>;
}

export interface CheckoutResponse {
	order: Order;
}
