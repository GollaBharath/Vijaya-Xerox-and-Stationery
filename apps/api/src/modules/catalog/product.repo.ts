/**
 * Product Repository
 */

import { prisma } from "@/lib/prisma";
import { deleteFile } from "@/lib/file_storage";
import {
	Product,
	ProductFilterOptions,
	ProductWithVariants,
} from "./catalog.types";

function toProduct(entity: any): Product {
	return {
		id: entity.id,
		title: entity.title,
		description: entity.description ?? null,
		isbn: entity.isbn ?? null,
		basePrice: entity.basePrice,
		subjectId: entity.subjectId,
		imageUrl: entity.imageUrl ?? null,
		pdfUrl: entity.pdfUrl ?? null,
		previewUrl: entity.previewUrl ?? null,
		fileType: entity.fileType ?? "NONE",
		isActive: entity.isActive,
		createdAt: entity.createdAt.toISOString(),
		updatedAt: entity.updatedAt.toISOString(),
	};
}

export async function findProductById(id: string): Promise<Product | null> {
	const product = await prisma.product.findUnique({
		where: { id },
	});
	return product ? toProduct(product) : null;
}

export async function findProductsByCategory(
	categoryId: string,
	pagination: { skip: number; take: number },
): Promise<ProductWithVariants[]> {
	const products = await prisma.product.findMany({
		where: {
			isActive: true,
			categories: { some: { categoryId } },
		},
		include: { variants: true },
		skip: pagination.skip,
		take: pagination.take,
		orderBy: { createdAt: "desc" },
	});

	return products.map((p) => ({
		...toProduct(p),
		variants: p.variants.map((v) => ({
			id: v.id,
			productId: v.productId,
			variantType: v.variantType,
			price: v.price,
			stock: v.stock,
			sku: v.sku,
			createdAt: v.createdAt.toISOString(),
			updatedAt: v.updatedAt.toISOString(),
		})),
	}));
}

export async function findProductsBySubject(
	subjectId: string,
	pagination: { skip: number; take: number },
): Promise<ProductWithVariants[]> {
	const products = await prisma.product.findMany({
		where: { isActive: true, subjectId },
		include: { variants: true },
		skip: pagination.skip,
		take: pagination.take,
		orderBy: { createdAt: "desc" },
	});

	return products.map((p) => ({
		...toProduct(p),
		variants: p.variants.map((v) => ({
			id: v.id,
			productId: v.productId,
			variantType: v.variantType,
			price: v.price,
			stock: v.stock,
			sku: v.sku,
			createdAt: v.createdAt.toISOString(),
			updatedAt: v.updatedAt.toISOString(),
		})),
	}));
}

export async function findAllProducts(
	pagination: { skip: number; take: number },
	filters: ProductFilterOptions = {},
): Promise<ProductWithVariants[]> {
	console.log("[Product Repo] Filters received:", filters);

	const whereClause = {
		isActive: filters.isActive ?? undefined,
		subjectId: filters.subjectId ?? undefined,
		title: filters.search
			? { contains: filters.search, mode: "insensitive" as const }
			: undefined,
		categories: filters.categoryId
			? { some: { categoryId: filters.categoryId } }
			: undefined,
	};

	console.log(
		"[Product Repo] Where clause:",
		JSON.stringify(whereClause, null, 2),
	);

	const products = await prisma.product.findMany({
		where: whereClause,
		include: { variants: true },
		skip: pagination.skip,
		take: pagination.take,
		orderBy: { createdAt: "desc" },
	});

	console.log(`[Product Repo] Found ${products.length} products`);
	if (products.length > 0) {
		console.log("[Product Repo] First product isActive:", products[0].isActive);
		console.log(
			"[Product Repo] First product variants:",
			products[0].variants.length,
		);
	}

	return products.map((p) => ({
		...toProduct(p),
		variants: p.variants.map((v) => ({
			id: v.id,
			productId: v.productId,
			variantType: v.variantType,
			price: v.price,
			stock: v.stock,
			sku: v.sku,
			createdAt: v.createdAt.toISOString(),
			updatedAt: v.updatedAt.toISOString(),
		})),
	}));
}

export async function createProduct(data: {
	title: string;
	description?: string | null;
	isbn?: string | null;
	basePrice: number;
	subjectId: string;
	imageUrl?: string | null;
	pdfUrl?: string | null;
	previewUrl?: string | null;
	fileType?: "IMAGE" | "PDF" | "NONE";
	categoryIds?: string[];
}): Promise<Product> {
	const product = await prisma.product.create({
		data: {
			title: data.title,
			description: data.description ?? null,
			isbn: data.isbn ?? null,
			basePrice: data.basePrice,
			subjectId: data.subjectId,
			imageUrl: data.imageUrl ?? null,
			pdfUrl: data.pdfUrl ?? null,
			previewUrl: data.previewUrl ?? null,
			fileType: data.fileType ?? "NONE",
			categories: data.categoryIds?.length
				? {
					createMany: {
						data: data.categoryIds.map((categoryId) => ({
							categoryId,
						})),
					},
				}
				: undefined,
		},
	});

	// Auto-create default variant
	await prisma.productVariant.create({
		data: {
			productId: product.id,
			variantType: "DEFAULT",
			price: data.basePrice,
			stock: true,
			sku: `${product.id}-DEFAULT`,
		},
	});

	return toProduct(product);
}

export async function updateProduct(
	id: string,
	data: {
		title?: string;
		description?: string | null;
		isbn?: string | null;
		basePrice?: number;
		subjectId?: string;
		imageUrl?: string | null;
		pdfUrl?: string | null;
		previewUrl?: string | null;
		fileType?: "IMAGE" | "PDF" | "NONE";
		isActive?: boolean;
		categoryIds?: string[];
	},
): Promise<Product> {
	const product = await prisma.product.update({
		where: { id },
		data: {
			title: data.title,
			description: data.description ?? undefined,
			isbn: data.isbn ?? undefined,
			basePrice: data.basePrice,
			subjectId: data.subjectId,
			imageUrl: data.imageUrl ?? undefined,
			pdfUrl: data.pdfUrl ?? undefined,
			previewUrl: data.previewUrl ?? undefined,
			fileType: data.fileType ?? undefined,
			isActive: data.isActive,
			categories: data.categoryIds
				? {
					deleteMany: {},
					createMany: {
						data: data.categoryIds.map((categoryId) => ({
							categoryId,
						})),
					},
				}
				: undefined,
		},
	});

	return toProduct(product);
}

export async function deleteProduct(id: string): Promise<Product> {
	// Get product before deleting to return it
	const product = await prisma.product.findUnique({ where: { id } });

	if (!product) {
		throw new Error("Product not found");
	}

	// Delete associated files
	await deleteProductFiles(id);

	// Delete the product permanently
	await prisma.product.delete({
		where: { id },
	});

	return toProduct(product);
}

export async function getProductWithVariants(
	id: string,
): Promise<ProductWithVariants | null> {
	const product = await prisma.product.findUnique({
		where: { id },
		include: { variants: true },
	});

	if (!product) return null;

	return {
		...toProduct(product),
		variants: product.variants.map((v) => ({
			id: v.id,
			productId: v.productId,
			variantType: v.variantType,
			price: v.price,
			stock: v.stock,
			sku: v.sku,
			createdAt: v.createdAt.toISOString(),
			updatedAt: v.updatedAt.toISOString(),
		})),
	};
}

export async function deleteProductFiles(id: string): Promise<boolean> {
	try {
		const product = await prisma.product.findUnique({
			where: { id },
			select: { imageUrl: true, pdfUrl: true, previewUrl: true },
		});

		if (!product) return false;

		if (product.imageUrl) {
			deleteFile(product.imageUrl);
		}

		if (product.pdfUrl) {
			deleteFile(product.pdfUrl);
		}

		if (product.previewUrl) {
			deleteFile(product.previewUrl);
		}

		// Clear file URLs from database
		await prisma.product.update({
			where: { id },
			data: {
				imageUrl: null,
				pdfUrl: null,
				previewUrl: null,
				fileType: "NONE",
			},
		});

		return true;
	} catch (error) {
		console.error("Error deleting product files:", error);
		return false;
	}
}
