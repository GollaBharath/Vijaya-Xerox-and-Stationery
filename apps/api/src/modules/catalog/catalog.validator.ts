/**
 * Catalog Module Validators
 */

import {
	validateRequired,
	validateStringLength,
	validatePositiveNumber,
	validateNonNegativeNumber,
	validateEnum,
	validateISBN,
	sanitizeString,
} from "@/utils/validators";
import { ValidationError } from "@/middleware/error.middleware";
import { VariantType } from "@prisma/client";

export interface CreateCategoryInput {
	name: string;
	parentId?: string | null;
	metadata?: Record<string, unknown> | null;
}

export interface UpdateCategoryInput {
	name?: string;
	parentId?: string | null;
	metadata?: Record<string, unknown> | null;
	isActive?: boolean;
}

export interface CreateProductInput {
	title: string;
	description?: string | null;
	isbn?: string | null;
	basePrice: number;
	subjectId: string;
	categoryIds?: string[];
}

export interface UpdateProductInput {
	title?: string;
	description?: string | null;
	isbn?: string | null;
	basePrice?: number;
	subjectId?: string;
	isActive?: boolean;
	categoryIds?: string[];
}

export interface CreateVariantInput {
	productId: string;
	variantType: VariantType;
	price: number;
	stock: number;
	sku: string;
}

export interface UpdateVariantInput {
	price?: number;
	stock?: number;
}

export function validateCreateCategory(data: any): CreateCategoryInput {
	validateRequired(data, ["name"]);

	const name = sanitizeString(String(data.name));
	validateStringLength(name, "name", 2, 100);

	return {
		name,
		parentId: data.parentId ?? null,
		metadata: data.metadata ?? null,
	};
}

export function validateUpdateCategory(data: any): UpdateCategoryInput {
	const update: UpdateCategoryInput = {};

	if (data.name !== undefined) {
		const name = sanitizeString(String(data.name));
		validateStringLength(name, "name", 2, 100);
		update.name = name;
	}

	if (data.parentId !== undefined) {
		update.parentId = data.parentId ?? null;
	}

	if (data.metadata !== undefined) {
		update.metadata = data.metadata ?? null;
	}

	if (data.isActive !== undefined) {
		if (typeof data.isActive !== "boolean") {
			throw new ValidationError("isActive must be a boolean", "isActive");
		}
		update.isActive = data.isActive;
	}

	return update;
}

export function validateCreateProduct(data: any): CreateProductInput {
	validateRequired(data, ["title", "basePrice", "subjectId"]);

	const title = sanitizeString(String(data.title));
	validateStringLength(title, "title", 2, 200);

	const basePrice = Number(data.basePrice);
	validatePositiveNumber(basePrice, "basePrice");

	const subjectId = String(data.subjectId);
	validateStringLength(subjectId, "subjectId", 1, 200);

	if (data.isbn) {
		const isbn = String(data.isbn).trim();
		if (!validateISBN(isbn)) {
			throw new ValidationError("Invalid ISBN", "isbn");
		}
	}

	return {
		title,
		description: data.description ?? null,
		isbn: data.isbn ?? null,
		basePrice,
		subjectId,
		categoryIds: Array.isArray(data.categoryIds) ? data.categoryIds : undefined,
	};
}

export function validateUpdateProduct(data: any): UpdateProductInput {
	const update: UpdateProductInput = {};

	if (data.title !== undefined) {
		const title = sanitizeString(String(data.title));
		validateStringLength(title, "title", 2, 200);
		update.title = title;
	}

	if (data.description !== undefined) {
		update.description = data.description ?? null;
	}

	if (data.isbn !== undefined) {
		const isbn = String(data.isbn).trim();
		if (isbn.length > 0 && !validateISBN(isbn)) {
			throw new ValidationError("Invalid ISBN", "isbn");
		}
		update.isbn = isbn.length > 0 ? isbn : null;
	}

	if (data.basePrice !== undefined) {
		const basePrice = Number(data.basePrice);
		validatePositiveNumber(basePrice, "basePrice");
		update.basePrice = basePrice;
	}

	if (data.subjectId !== undefined) {
		const subjectId = String(data.subjectId);
		validateStringLength(subjectId, "subjectId", 1, 200);
		update.subjectId = subjectId;
	}

	if (data.isActive !== undefined) {
		if (typeof data.isActive !== "boolean") {
			throw new ValidationError("isActive must be a boolean", "isActive");
		}
		update.isActive = data.isActive;
	}

	if (data.categoryIds !== undefined) {
		if (!Array.isArray(data.categoryIds)) {
			throw new ValidationError("categoryIds must be an array", "categoryIds");
		}
		update.categoryIds = data.categoryIds;
	}

	return update;
}

export function validateCreateVariant(data: any): CreateVariantInput {
	validateRequired(data, ["productId", "variantType", "price", "stock", "sku"]);

	const variantType = validateEnum(
		String(data.variantType),
		Object.values(VariantType),
		"variantType",
	) as VariantType;

	const price = Number(data.price);
	validatePositiveNumber(price, "price");

	const stock = Number(data.stock);
	validateNonNegativeNumber(stock, "stock");

	const sku = sanitizeString(String(data.sku));
	validateStringLength(sku, "sku", 2, 100);

	return {
		productId: String(data.productId),
		variantType,
		price,
		stock,
		sku,
	};
}

export function validateUpdateVariant(data: any): UpdateVariantInput {
	const update: UpdateVariantInput = {};

	if (data.price !== undefined) {
		const price = Number(data.price);
		validatePositiveNumber(price, "price");
		update.price = price;
	}

	if (data.stock !== undefined) {
		const stock = Number(data.stock);
		validateNonNegativeNumber(stock, "stock");
		update.stock = stock;
	}

	if (Object.keys(update).length === 0) {
		throw new ValidationError("At least one field must be updated", "update");
	}

	return update;
}
