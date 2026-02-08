/**
 * Global Type Definitions
 *
 * Common types used throughout the API
 */

// ============================================
// API Response Types
// ============================================

/**
 * Standard API success response
 */
export interface ApiResponse<T = any> {
	success: true;
	data: T;
	message?: string;
	pagination?: PaginationMeta;
}

/**
 * Standard API error response
 */
export interface ApiError {
	success: false;
	error: {
		code: string;
		message: string;
		details?: any;
		field?: string; // For validation errors
	};
}

/**
 * Pagination metadata
 */
export interface PaginationMeta {
	page: number;
	limit: number;
	total: number;
	totalPages: number;
	hasNextPage: boolean;
	hasPreviousPage: boolean;
}

/**
 * Paginated response
 */
export interface PaginatedResponse<T> {
	success: true;
	data: T[];
	pagination: PaginationMeta;
}

// ============================================
// Request Types
// ============================================

/**
 * Pagination query parameters
 */
export interface PaginationQuery {
	page?: number;
	limit?: number;
}

/**
 * Sort query parameters
 */
export interface SortQuery {
	sortBy?: string;
	sortOrder?: "asc" | "desc";
}

// ============================================
// Auth Types
// ============================================

/**
 * User role enum
 */
export type UserRole = "CUSTOMER" | "ADMIN";

/**
 * JWT payload
 */
export interface JWTPayload {
	userId: string;
	role: UserRole;
	iat?: number;
	exp?: number;
}

/**
 * Authenticated request context
 */
export interface AuthContext {
	userId: string;
	role: UserRole;
}

// ============================================
// Error Codes
// ============================================

export enum ErrorCode {
	// General
	INTERNAL_SERVER_ERROR = "INTERNAL_SERVER_ERROR",
	BAD_REQUEST = "BAD_REQUEST",
	NOT_FOUND = "NOT_FOUND",
	VALIDATION_ERROR = "VALIDATION_ERROR",
	INVALID_REQUEST = "INVALID_REQUEST",
	NOT_IMPLEMENTED = "NOT_IMPLEMENTED",

	// Auth
	UNAUTHORIZED = "UNAUTHORIZED",
	FORBIDDEN = "FORBIDDEN",
	INVALID_CREDENTIALS = "INVALID_CREDENTIALS",
	TOKEN_EXPIRED = "TOKEN_EXPIRED",
	TOKEN_INVALID = "TOKEN_INVALID",
	USER_ALREADY_EXISTS = "USER_ALREADY_EXISTS",
	USER_NOT_FOUND = "USER_NOT_FOUND",

	// Rate Limiting
	RATE_LIMIT_EXCEEDED = "RATE_LIMIT_EXCEEDED",

	// Resources
	RESOURCE_NOT_FOUND = "RESOURCE_NOT_FOUND",
	RESOURCE_ALREADY_EXISTS = "RESOURCE_ALREADY_EXISTS",

	// Business Logic
	INSUFFICIENT_STOCK = "INSUFFICIENT_STOCK",
	INVALID_ORDER_STATUS = "INVALID_ORDER_STATUS",
	PAYMENT_FAILED = "PAYMENT_FAILED",
}

// ============================================
// Filter Types
// ============================================

/**
 * Common filter options
 */
export interface FilterOptions {
	search?: string;
	isActive?: boolean;
	createdAfter?: Date;
	createdBefore?: Date;
}

// ============================================
// Type Guards
// ============================================

/**
 * Check if response is an API error
 */
export function isApiError(response: any): response is ApiError {
	return response && response.success === false && response.error !== undefined;
}

/**
 * Check if response is an API success
 */
export function isApiResponse<T>(response: any): response is ApiResponse<T> {
	return response && response.success === true && response.data !== undefined;
}
