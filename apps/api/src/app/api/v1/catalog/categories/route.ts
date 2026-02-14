/**
 * GET /api/v1/catalog/categories
 * POST /api/v1/catalog/categories (admin)
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { requireAdmin } from "@/middleware/admin.middleware";
import { ApiResponse } from "@/types/global";
import { parseBoolean } from "@/utils/helpers";
import {
	createCategory,
	findAllCategories,
} from "@/modules/catalog/category.repo";
import { validateCreateCategory } from "@/modules/catalog/catalog.validator";
import { redisClient } from "@/lib/redis";
import { logger } from "@/lib/logger";

export const GET = errorHandler(async (request: NextRequest) => {
	const { searchParams } = new URL(request.url);
	const isActiveParam = searchParams.get("isActive");
	const isActive =
		isActiveParam !== null ? parseBoolean(isActiveParam) : undefined;

	const categories = await findAllCategories(isActive);

	const response: ApiResponse<typeof categories> = {
		success: true,
		data: categories,
	};

	return NextResponse.json(response, { status: 200 });
});

export const POST = errorHandler(async (request: NextRequest) => {
	const adminResult = await requireAdmin(request);
	if (!adminResult.authorized) return adminResult.response;

	const body = await request.json();
	const payload = validateCreateCategory(body);

	const category = await createCategory(
		payload.name,
		payload.parentId ?? null,
		payload.metadata ?? null,
	);

	// Invalidate category tree cache
	try {
		await redisClient.connect();
		await redisClient.del("categories:tree:v1");
	} catch (error) {
		logger.warn("Failed to invalidate category cache", error);
	}

	const response: ApiResponse<typeof category> = {
		success: true,
		data: category,
		message: "Category created successfully",
	};

	return NextResponse.json(response, { status: 201 });
});
