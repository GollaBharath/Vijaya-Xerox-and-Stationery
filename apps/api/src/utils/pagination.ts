/**
 * Pagination Utilities
 *
 * Helper functions for handling pagination in API endpoints
 */

import { PaginationMeta, PaginationQuery } from "@/types/global";
import { ValidationError } from "@/middleware/error.middleware";

/**
 * Default pagination config
 */
export const PAGINATION_DEFAULTS = {
	PAGE: 1,
	LIMIT: 20,
	MAX_LIMIT: 100,
};

/**
 * Parse and validate pagination parameters from query
 */
export function parsePaginationParams(query: PaginationQuery): {
	page: number;
	limit: number;
	skip: number;
} {
	let page = query.page || PAGINATION_DEFAULTS.PAGE;
	let limit = query.limit || PAGINATION_DEFAULTS.LIMIT;

	// Validate page
	if (typeof page === "string") {
		page = parseInt(page, 10);
	}
	if (isNaN(page) || page < 1) {
		throw new ValidationError("Page must be a positive integer", "page");
	}

	// Validate limit
	if (typeof limit === "string") {
		limit = parseInt(limit, 10);
	}
	if (isNaN(limit) || limit < 1) {
		throw new ValidationError("Limit must be a positive integer", "limit");
	}
	if (limit > PAGINATION_DEFAULTS.MAX_LIMIT) {
		throw new ValidationError(
			`Limit cannot exceed ${PAGINATION_DEFAULTS.MAX_LIMIT}`,
			"limit",
		);
	}

	// Calculate skip
	const skip = (page - 1) * limit;

	return { page, limit, skip };
}

/**
 * Create pagination metadata
 */
export function createPaginationMeta(
	page: number,
	limit: number,
	total: number,
): PaginationMeta {
	const totalPages = Math.ceil(total / limit);

	return {
		page,
		limit,
		total,
		totalPages,
		hasNextPage: page < totalPages,
		hasPreviousPage: page > 1,
	};
}

/**
 * Extract pagination query from request URL
 */
export function getPaginationFromUrl(url: URL): PaginationQuery {
	const page = url.searchParams.get("page");
	const limit = url.searchParams.get("limit");

	return {
		page: page ? parseInt(page, 10) : undefined,
		limit: limit ? parseInt(limit, 10) : undefined,
	};
}

/**
 * Apply pagination to Prisma query
 *
 * Usage:
 * const { skip, take } = applyPagination(page, limit);
 * const products = await prisma.product.findMany({
 *   skip,
 *   take,
 *   // other query options
 * });
 */
export function applyPagination(
	page: number,
	limit: number,
): {
	skip: number;
	take: number;
} {
	return {
		skip: (page - 1) * limit,
		take: limit,
	};
}

/**
 * Create cursor-based pagination for infinite scroll
 *
 * Usage:
 * const { cursor, take } = applyCursorPagination(lastId, limit);
 * const products = await prisma.product.findMany({
 *   take,
 *   cursor: cursor ? { id: cursor } : undefined,
 *   skip: cursor ? 1 : 0, // Skip the cursor
 *   // other query options
 * });
 */
export function applyCursorPagination(
	cursor: string | null,
	limit: number,
): {
	cursor: string | null;
	take: number;
	skip: number;
} {
	return {
		cursor,
		take: limit,
		skip: cursor ? 1 : 0,
	};
}
