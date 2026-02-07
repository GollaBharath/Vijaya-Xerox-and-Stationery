/**
 * Validation Utilities
 *
 * Common validation functions for email, phone, password, etc.
 */

import { ValidationError } from "@/middleware/error.middleware";

/**
 * Email validation
 */
export function validateEmail(email: string): boolean {
	const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
	return emailRegex.test(email);
}

/**
 * Phone validation (Indian format)
 * Accepts: 10 digits, with optional +91 prefix
 */
export function validatePhone(phone: string): boolean {
	// Remove spaces and dashes
	const cleaned = phone.replace(/[\s-]/g, "");

	// Check for Indian phone number patterns
	const phoneRegex = /^(\+91)?[6-9]\d{9}$/;
	return phoneRegex.test(cleaned);
}

/**
 * Normalize phone number to standard format
 */
export function normalizePhone(phone: string): string {
	const cleaned = phone.replace(/[\s-]/g, "");

	// Remove +91 if present
	if (cleaned.startsWith("+91")) {
		return cleaned.substring(3);
	}
	if (cleaned.startsWith("91") && cleaned.length === 12) {
		return cleaned.substring(2);
	}

	return cleaned;
}

/**
 * Password validation
 * Requirements:
 * - At least 8 characters
 * - At least 1 uppercase letter
 * - At least 1 lowercase letter
 * - At least 1 number
 */
export function validatePassword(password: string): {
	valid: boolean;
	errors: string[];
} {
	const errors: string[] = [];

	if (password.length < 8) {
		errors.push("Password must be at least 8 characters long");
	}

	if (!/[A-Z]/.test(password)) {
		errors.push("Password must contain at least one uppercase letter");
	}

	if (!/[a-z]/.test(password)) {
		errors.push("Password must contain at least one lowercase letter");
	}

	if (!/\d/.test(password)) {
		errors.push("Password must contain at least one number");
	}

	return {
		valid: errors.length === 0,
		errors,
	};
}

/**
 * ISBN validation (ISBN-10 or ISBN-13)
 */
export function validateISBN(isbn: string): boolean {
	// Remove hyphens and spaces
	const cleaned = isbn.replace(/[\s-]/g, "");

	// ISBN-10
	if (cleaned.length === 10) {
		return validateISBN10(cleaned);
	}

	// ISBN-13
	if (cleaned.length === 13) {
		return validateISBN13(cleaned);
	}

	return false;
}

function validateISBN10(isbn: string): boolean {
	let sum = 0;
	for (let i = 0; i < 9; i++) {
		const digit = parseInt(isbn[i], 10);
		if (isNaN(digit)) return false;
		sum += digit * (10 - i);
	}

	const lastChar = isbn[9];
	const checkDigit = lastChar === "X" ? 10 : parseInt(lastChar, 10);
	if (isNaN(checkDigit)) return false;

	sum += checkDigit;
	return sum % 11 === 0;
}

function validateISBN13(isbn: string): boolean {
	let sum = 0;
	for (let i = 0; i < 12; i++) {
		const digit = parseInt(isbn[i], 10);
		if (isNaN(digit)) return false;
		sum += digit * (i % 2 === 0 ? 1 : 3);
	}

	const checkDigit = parseInt(isbn[12], 10);
	if (isNaN(checkDigit)) return false;

	const calculatedCheck = (10 - (sum % 10)) % 10;
	return checkDigit === calculatedCheck;
}

/**
 * Validate required fields
 */
export function validateRequired(
	data: Record<string, any>,
	requiredFields: string[],
): void {
	const missingFields: string[] = [];

	for (const field of requiredFields) {
		const value = data[field];
		if (value === undefined || value === null || value === "") {
			missingFields.push(field);
		}
	}

	if (missingFields.length > 0) {
		throw new ValidationError(
			`Missing required fields: ${missingFields.join(", ")}`,
			missingFields[0],
		);
	}
}

/**
 * Validate enum value
 */
export function validateEnum<T extends string>(
	value: string,
	enumValues: T[],
	fieldName: string,
): T {
	if (!enumValues.includes(value as T)) {
		throw new ValidationError(
			`Invalid ${fieldName}. Must be one of: ${enumValues.join(", ")}`,
			fieldName,
		);
	}
	return value as T;
}

/**
 * Validate positive number
 */
export function validatePositiveNumber(value: number, fieldName: string): void {
	if (typeof value !== "number" || isNaN(value) || value <= 0) {
		throw new ValidationError(
			`${fieldName} must be a positive number`,
			fieldName,
		);
	}
}

/**
 * Validate non-negative number
 */
export function validateNonNegativeNumber(
	value: number,
	fieldName: string,
): void {
	if (typeof value !== "number" || isNaN(value) || value < 0) {
		throw new ValidationError(
			`${fieldName} must be a non-negative number`,
			fieldName,
		);
	}
}

/**
 * Validate string length
 */
export function validateStringLength(
	value: string,
	fieldName: string,
	min?: number,
	max?: number,
): void {
	if (typeof value !== "string") {
		throw new ValidationError(`${fieldName} must be a string`, fieldName);
	}

	if (min !== undefined && value.length < min) {
		throw new ValidationError(
			`${fieldName} must be at least ${min} characters`,
			fieldName,
		);
	}

	if (max !== undefined && value.length > max) {
		throw new ValidationError(
			`${fieldName} must not exceed ${max} characters`,
			fieldName,
		);
	}
}

/**
 * Sanitize string input (trim and remove extra spaces)
 */
export function sanitizeString(value: string): string {
	return value.trim().replace(/\s+/g, " ");
}
