/**
 * Auth Module Validators
 */

import {
	validateEmail,
	validatePhone,
	validatePassword,
	validateRequired,
	validateStringLength,
	sanitizeString,
	normalizePhone,
} from "@/utils/validators";
import { ValidationError } from "@/middleware/error.middleware";
import { RegisterRequest, LoginRequest } from "./auth.types";

/**
 * Validate registration request
 */
export function validateRegister(data: any): RegisterRequest {
	// Check required fields
	validateRequired(data, ["name", "email", "phone", "password"]);

	const { name, email, phone, password } = data;

	// Validate name
	if (typeof name !== "string") {
		throw new ValidationError("Name must be a string", "name");
	}
	validateStringLength(name, "name", 2, 100);

	// Validate email
	if (typeof email !== "string") {
		throw new ValidationError("Email must be a string", "email");
	}
	if (!validateEmail(email)) {
		throw new ValidationError("Invalid email format", "email");
	}

	// Validate phone
	if (typeof phone !== "string") {
		throw new ValidationError("Phone must be a string", "phone");
	}
	if (!validatePhone(phone)) {
		throw new ValidationError(
			"Invalid phone number. Must be a valid Indian phone number (10 digits)",
			"phone",
		);
	}

	// Validate password
	if (typeof password !== "string") {
		throw new ValidationError("Password must be a string", "password");
	}
	const passwordValidation = validatePassword(password);
	if (!passwordValidation.valid) {
		throw new ValidationError(passwordValidation.errors.join(". "), "password");
	}

	return {
		name: sanitizeString(name),
		email: email.toLowerCase().trim(),
		phone: normalizePhone(phone),
		password,
	};
}

/**
 * Validate login request
 */
export function validateLogin(data: any): LoginRequest {
	// Check required fields
	validateRequired(data, ["email", "password"]);

	const { email, password } = data;

	// Validate email
	if (typeof email !== "string") {
		throw new ValidationError("Email must be a string", "email");
	}
	if (!validateEmail(email)) {
		throw new ValidationError("Invalid email format", "email");
	}

	// Validate password
	if (typeof password !== "string") {
		throw new ValidationError("Password must be a string", "password");
	}
	if (password.length === 0) {
		throw new ValidationError("Password is required", "password");
	}

	return {
		email: email.toLowerCase().trim(),
		password,
	};
}

/**
 * Validate refresh token request
 */
export function validateRefreshToken(data: any): string {
	validateRequired(data, ["refreshToken"]);

	const { refreshToken } = data;

	if (typeof refreshToken !== "string") {
		throw new ValidationError("Refresh token must be a string", "refreshToken");
	}

	if (refreshToken.length === 0) {
		throw new ValidationError("Refresh token is required", "refreshToken");
	}

	return refreshToken;
}
