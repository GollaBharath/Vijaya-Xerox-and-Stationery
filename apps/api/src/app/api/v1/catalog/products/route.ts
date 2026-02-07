/**
 * GET /api/v1/catalog/products
 * POST /api/v1/catalog/products (admin)
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { requireAdmin } from "@/middleware/admin.middleware";
import { ApiResponse } from "@/types/global";
import {
	getPaginationFromUrl,
	parsePaginationParams,
	createPaginationMeta,
} from "@/utils/pagination";
import { parseBoolean } from "@/utils/helpers";
import { prisma } from "@/lib/prisma";
import { findAllProducts, createProduct } from "@/modules/catalog/product.repo";
import { validateCreateProduct } from "@/modules/catalog/catalog.validator";

export const GET = errorHandler(async (request: NextRequest) => {
	const url = new URL(request.url);
	const paginationQuery = getPaginationFromUrl(url);
	const { page, limit, skip } = parsePaginationParams(paginationQuery);

	const search = url.searchParams.get("search") || undefined;
	const subjectId = url.searchParams.get("subjectId") || undefined;
	const categoryId = url.searchParams.get("categoryId") || undefined;
	const isActiveParam = url.searchParams.get("isActive");
	const isActive = isActiveParam ? parseBoolean(isActiveParam) : undefined;

	console.log("[Products API] Filter params:", {
		isActiveParam,
		isActive,
		search,
		subjectId,
		categoryId,
	});

	const filters = { search, subjectId, categoryId, isActive };

	const [products, total] = await Promise.all([
		findAllProducts({ skip, take: limit }, filters),
		prisma.product.count({
			where: {
				isActive: filters.isActive ?? undefined,
				subjectId: filters.subjectId ?? undefined,
				title: filters.search
					? { contains: filters.search, mode: "insensitive" }
					: undefined,
				categories: filters.categoryId
					? { some: { categoryId: filters.categoryId } }
					: undefined,
			},
		}),
	]);

	const response: ApiResponse<typeof products> = {
		success: true,
		data: products,
		pagination: createPaginationMeta(page, limit, total),
	};

	return NextResponse.json(response, { status: 200 });
});

export const POST = errorHandler(async (request: NextRequest) => {
	const adminResult = await requireAdmin(request);
	if (!adminResult.authorized) return adminResult.response;

	const body = await request.json();
	const payload = validateCreateProduct(body);

	const product = await createProduct(payload);

	const response: ApiResponse<typeof product> = {
		success: true,
		data: product,
		message: "Product created successfully",
	};

	return NextResponse.json(response, { status: 201 });
});
