/**
 * Subjects Module Validators
 */

import {
	validateRequired,
	validateStringLength,
	sanitizeString,
} from "@/utils/validators";
import { ValidationError } from "@/middleware/error.middleware";

export interface CreateSubjectInput {
	name: string;
	categoryId: string;
	parentSubjectId?: string | null;
}

export interface UpdateSubjectInput {
	name?: string;
	categoryId?: string;
	parentSubjectId?: string | null;
}

export function validateCreateSubject(data: any): CreateSubjectInput {
	validateRequired(data, ["name", "categoryId"]);

	const name = sanitizeString(String(data.name));
	validateStringLength(name, "name", 2, 100);

	const categoryId = String(data.categoryId);
	validateStringLength(categoryId, "categoryId", 1, 200);

	return {
		name,
		categoryId,
		parentSubjectId: data.parentSubjectId ?? null,
	};
}

export function validateUpdateSubject(data: any): UpdateSubjectInput {
	const update: UpdateSubjectInput = {};

	if (data.name !== undefined) {
		const name = sanitizeString(String(data.name));
		validateStringLength(name, "name", 2, 200);
		update.name = name;
	}

	if (data.categoryId !== undefined) {
		const categoryId = String(data.categoryId);
		validateStringLength(categoryId, "categoryId", 1, 200);
		update.categoryId = categoryId;
	}

	if (data.parentSubjectId !== undefined) {
		if (
			data.parentSubjectId !== null &&
			typeof data.parentSubjectId !== "string"
		) {
			throw new ValidationError(
				"parentSubjectId must be a string or null",
				"parentSubjectId",
			);
		}
		update.parentSubjectId = data.parentSubjectId ?? null;
	}

	if (Object.keys(update).length === 0) {
		throw new ValidationError("At least one field must be updated", "update");
	}

	return update;
}
