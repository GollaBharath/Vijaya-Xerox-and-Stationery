/**
 * User Profile Validators
 */

import { z } from "zod";
import { AppError } from "@/middleware/error.middleware";
import { ErrorCode } from "@/types/global";
import { UpdateProfileRequest } from "./profile.types";

const updateProfileSchema = z.object({
	name: z.string().min(1).max(100).optional(),
	phone: z
		.string()
		.regex(/^\+?[1-9]\d{1,14}$/)
		.optional()
		.nullable(),
	address: z.string().min(1).max(500).optional().nullable(),
	city: z.string().min(1).max(100).optional().nullable(),
	state: z.string().min(1).max(100).optional().nullable(),
	pincode: z
		.string()
		.regex(/^[0-9]{6}$/)
		.optional()
		.nullable(),
	landmark: z.string().max(200).optional().nullable(),
});

export function validateUpdateProfile(data: unknown): UpdateProfileRequest {
	const result = updateProfileSchema.safeParse(data);
	if (!result.success) {
		throw new AppError(
			ErrorCode.VALIDATION_ERROR,
			result.error.errors[0]?.message || "Invalid profile data",
			400,
		);
	}
	return result.data;
}
