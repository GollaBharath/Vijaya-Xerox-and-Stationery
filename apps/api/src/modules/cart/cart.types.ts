/**
 * Cart Module Type Definitions
 */

import { VariantType } from "@prisma/client";

export interface CartItemProduct {
	id: string;
	title: string;
	basePrice: number;
	isActive: boolean;
	imageUrl?: string | null;
	fileType?: string;
}

export interface CartItemVariant {
	id: string;
	productId: string;
	variantType: VariantType;
	price: number;
	stock: number;
	sku: string;
	product?: CartItemProduct;
}

export interface CartItem {
	id: string;
	userId: string;
	productVariantId: string;
	quantity: number;
	createdAt: string;
	updatedAt: string;
	variant?: CartItemVariant;
}

export interface CartResponse {
	items: CartItem[];
	total: number;
}
