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
	// Support both camelCase and snake_case
	const variantId = data.productVariantId || data.product_variant_id;

	if (!variantId) {
		throw new ValidationError(
			"productVariantId is required",
			"productVariantId",
		);
	}
	if (!data.quantity) {
		throw new ValidationError("quantity is required", "quantity");
	}

	const productVariantId = String(variantId);
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
