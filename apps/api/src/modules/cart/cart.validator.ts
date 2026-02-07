/**
 * Cart Module Validators
 */

import { validateRequired, validatePositiveNumber } from "@/utils/validators";
import { ValidationError } from "@/middleware/error.middleware";

export interface AddToCartInput {
	productVariantId: string;
	quantity: number;
}

export interface UpdateCartItemInput {
	quantity: number;
}

export function validateAddToCart(data: any): AddToCartInput {
	validateRequired(data, ["productVariantId", "quantity"]);

	const productVariantId = String(data.productVariantId);
	const quantity = Number(data.quantity);

	validatePositiveNumber(quantity, "quantity");
	if (!Number.isInteger(quantity)) {
		throw new ValidationError("quantity must be an integer", "quantity");
	}

	return {
		productVariantId,
		quantity,
	};
}

export function validateUpdateCartItem(data: any): UpdateCartItemInput {
	validateRequired(data, ["quantity"]);

	const quantity = Number(data.quantity);
	validatePositiveNumber(quantity, "quantity");
	if (!Number.isInteger(quantity)) {
		throw new ValidationError("quantity must be an integer", "quantity");
	}

	return { quantity };
}
