/**
 * Orders Module Validators
 */

import { ValidationError } from "@/middleware/error.middleware";
import { validateRequired } from "@/utils/validators";

export interface CheckoutInput {
	address: Record<string, unknown>;
}

export function validateCheckout(data: any): CheckoutInput {
	validateRequired(data, ["address"]);

	if (typeof data.address !== "object" || data.address === null) {
		throw new ValidationError("address must be an object", "address");
	}

	return { address: data.address };
}
