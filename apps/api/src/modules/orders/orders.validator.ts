/**
 * Orders Module Validators
 */

import { ValidationError } from "@/middleware/error.middleware";

export interface CheckoutInput {
	address?: Record<string, unknown>;
}

export function validateCheckout(data: any): CheckoutInput {
	if (data.address !== undefined) {
		if (typeof data.address !== "object" || data.address === null) {
			throw new ValidationError("address must be an object", "address");
		}
	}

	return { address: data.address };
}
