/**
 * Catalog Module Type Definitions
 */

import { VariantType } from "@prisma/client";

export interface Category {
	id: string;
	name: string;
	parentId: string | null;
	metadata?: Record<string, unknown> | null;
	isActive: boolean;
	createdAt: string;
	updatedAt: string;
	children?: Category[];
}

export interface Product {
	id: string;
	title: string;
	description?: string | null;
	isbn?: string | null;
	basePrice: number;
	subjectId: string;
	imageUrl?: string | null;
	pdfUrl?: string | null;
	fileType: "IMAGE" | "PDF" | "NONE";
	isActive: boolean;
	createdAt: string;
	updatedAt: string;
}

export interface ProductVariant {
	id: string;
	productId: string;
	variantType: VariantType;
	price: number;
	stock: number;
	sku: string;
	createdAt: string;
	updatedAt: string;
}

export interface CategoryTreeResponse {
	categories: Category[];
}

export interface ProductWithVariants extends Product {
	variants: ProductVariant[];
}

export interface ProductFilterOptions {
	search?: string;
	isActive?: boolean;
	subjectId?: string;
	categoryId?: string;
}
