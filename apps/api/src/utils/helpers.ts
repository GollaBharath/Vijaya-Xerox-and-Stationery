/**
 * Helper Utilities
 *
 * Common helper functions used throughout the application
 */

import crypto from "crypto";
import bcrypt from "bcrypt";

/**
 * Hash password using bcrypt
 */
export async function hashPassword(password: string): Promise<string> {
	const saltRounds = 10;
	return bcrypt.hash(password, saltRounds);
}

/**
 * Compare password with hash
 */
export async function comparePassword(
	password: string,
	hash: string,
): Promise<boolean> {
	return bcrypt.compare(password, hash);
}

/**
 * Generate random string
 */
export function generateRandomString(length: number = 32): string {
	return crypto.randomBytes(length).toString("hex");
}

/**
 * Generate OTP
 */
export function generateOTP(length: number = 6): string {
	const digits = "0123456789";
	let otp = "";
	for (let i = 0; i < length; i++) {
		otp += digits[Math.floor(Math.random() * 10)];
	}
	return otp;
}

/**
 * Sleep/delay function
 */
export function sleep(ms: number): Promise<void> {
	return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Parse JSON safely
 */
export function safeJsonParse<T = any>(
	json: string,
	defaultValue?: T,
): T | null {
	try {
		return JSON.parse(json) as T;
	} catch {
		return defaultValue !== undefined ? defaultValue : null;
	}
}

/**
 * Format currency (Indian Rupees)
 */
export function formatCurrency(amount: number): string {
	return new Intl.NumberFormat("en-IN", {
		style: "currency",
		currency: "INR",
	}).format(amount);
}

/**
 * Format date to ISO string
 */
export function formatDate(date: Date): string {
	return date.toISOString();
}

/**
 * Get date range for queries
 */
export function getDateRange(days: number): { from: Date; to: Date } {
	const to = new Date();
	const from = new Date();
	from.setDate(from.getDate() - days);

	return { from, to };
}

/**
 * Chunk array into smaller arrays
 */
export function chunkArray<T>(array: T[], size: number): T[][] {
	const chunks: T[][] = [];
	for (let i = 0; i < array.length; i += size) {
		chunks.push(array.slice(i, i + size));
	}
	return chunks;
}

/**
 * Remove null/undefined values from object
 */
export function removeNullish<T extends Record<string, any>>(
	obj: T,
): Partial<T> {
	const result: Partial<T> = {};
	for (const [key, value] of Object.entries(obj)) {
		if (value !== null && value !== undefined) {
			result[key as keyof T] = value;
		}
	}
	return result;
}

/**
 * Deep clone object
 */
export function deepClone<T>(obj: T): T {
	return JSON.parse(JSON.stringify(obj));
}

/**
 * Debounce function
 */
export function debounce<T extends (...args: any[]) => any>(
	func: T,
	wait: number,
): (...args: Parameters<T>) => void {
	let timeout: NodeJS.Timeout;
	return (...args: Parameters<T>) => {
		clearTimeout(timeout);
		timeout = setTimeout(() => func(...args), wait);
	};
}

/**
 * Retry async function with exponential backoff
 */
export async function retry<T>(
	fn: () => Promise<T>,
	options: {
		maxRetries?: number;
		initialDelay?: number;
		maxDelay?: number;
		backoffMultiplier?: number;
	} = {},
): Promise<T> {
	const {
		maxRetries = 3,
		initialDelay = 1000,
		maxDelay = 10000,
		backoffMultiplier = 2,
	} = options;

	let lastError: any;
	let delay = initialDelay;

	for (let attempt = 0; attempt <= maxRetries; attempt++) {
		try {
			return await fn();
		} catch (error) {
			lastError = error;

			if (attempt < maxRetries) {
				await sleep(Math.min(delay, maxDelay));
				delay *= backoffMultiplier;
			}
		}
	}

	throw lastError;
}

/**
 * Extract client IP from request
 */
export function getClientIp(headers: Headers): string {
	return (
		headers.get("x-forwarded-for")?.split(",")[0].trim() ||
		headers.get("x-real-ip") ||
		"unknown"
	);
}

/**
 * Parse boolean from string
 */
export function parseBoolean(value: string | boolean | undefined): boolean {
	if (typeof value === "boolean") {
		return value;
	}
	if (typeof value === "string") {
		return value.toLowerCase() === "true" || value === "1";
	}
	return false;
}

/**
 * Slugify string for URLs
 */
export function slugify(text: string): string {
	return text
		.toLowerCase()
		.trim()
		.replace(/[^\w\s-]/g, "")
		.replace(/[\s_-]+/g, "-")
		.replace(/^-+|-+$/g, "");
}

/**
 * Truncate string
 */
export function truncate(
	text: string,
	maxLength: number,
	suffix: string = "...",
): string {
	if (text.length <= maxLength) {
		return text;
	}
	return text.substring(0, maxLength - suffix.length) + suffix;
}

/**
 * Calculate percentage
 */
export function calculatePercentage(value: number, total: number): number {
	if (total === 0) return 0;
	return Math.round((value / total) * 100);
}

/**
 * Generate SKU
 */
export function generateSKU(prefix: string, id: string | number): string {
	return `${prefix}-${id}-${Date.now().toString(36).toUpperCase()}`;
}
