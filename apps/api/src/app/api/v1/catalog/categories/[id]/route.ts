/**
 * GET /api/v1/catalog/categories/:id
 * PATCH /api/v1/catalog/categories/:id (admin)
 * DELETE /api/v1/catalog/categories/:id (admin)
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler, NotFoundError } from "@/middleware/error.middleware";
import { requireAdmin } from "@/middleware/admin.middleware";
import { ApiResponse } from "@/types/global";
import {
	findCategoryById,
	updateCategory,
	deleteCategory,
} from "@/modules/catalog/category.repo";
import { validateUpdateCategory } from "@/modules/catalog/catalog.validator";
import { redisClient } from "@/lib/redis";
import { logger } from "@/lib/logger";

export const GET = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const category = await findCategoryById(params.id);
		if (!category) throw new NotFoundError("Category");

		const response: ApiResponse<typeof category> = {
			success: true,
			data: category,
		};

		return NextResponse.json(response, { status: 200 });
	},
);

export const PATCH = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const body = await request.json();
		const payload = validateUpdateCategory(body);

		const category = await updateCategory(params.id, payload);

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
			message: "Category updated successfully",
		};

		return NextResponse.json(response, { status: 200 });
	},
);

export const DELETE = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const category = await deleteCategory(params.id);

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
			message: "Category deleted successfully",
		};

		return NextResponse.json(response, { status: 200 });
	},
);
