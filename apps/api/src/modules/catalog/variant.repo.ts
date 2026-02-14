/**
 * Product Variant Repository
 */

import { prisma } from "@/lib/prisma";
import { ProductVariant } from "./catalog.types";

function toVariant(entity: any): ProductVariant {
	return {
		id: entity.id,
		productId: entity.productId,
		variantType: entity.variantType,
		price: entity.price,
		stock: entity.stock,
		sku: entity.sku,
		createdAt: entity.createdAt.toISOString(),
		updatedAt: entity.updatedAt.toISOString(),
	};
}

export async function findVariantById(
	id: string,
): Promise<ProductVariant | null> {
	const variant = await prisma.productVariant.findUnique({
		where: { id },
	});
	return variant ? toVariant(variant) : null;
}

export async function findVariantsByProduct(
	productId: string,
): Promise<ProductVariant[]> {
	const variants = await prisma.productVariant.findMany({
		where: { productId },
		orderBy: { createdAt: "desc" },
	});

	return variants.map(toVariant);
}

export async function createVariant(data: {
	productId: string;
	variantType: "COLOR" | "BW" | "DEFAULT";
	price: number;
	stock: boolean;
	sku: string;
}): Promise<ProductVariant> {
	const variant = await prisma.productVariant.create({
		data: {
			productId: data.productId,
			variantType: data.variantType,
			price: data.price,
			stock: data.stock,
			sku: data.sku,
		},
	});

	return toVariant(variant);
}

export async function updateVariant(
	id: string,
	data: { price?: number; stock?: boolean },
): Promise<ProductVariant> {
	const variant = await prisma.productVariant.update({
		where: { id },
		data: {
			price: data.price,
			stock: data.stock,
		},
	});

	return toVariant(variant);
}

export async function checkStock(variantId: string): Promise<boolean> {
	const variant = await prisma.productVariant.findUnique({
		where: { id: variantId },
		select: { stock: true },
	});

	if (!variant) return false;
	return variant.stock;
}
