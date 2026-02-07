/**
 * GET /api/v1/catalog/categories/tree
 * Returns category hierarchy with caching
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { ApiResponse } from "@/types/global";
import { redisClient } from "@/lib/redis";
import { getCategoryTree } from "@/modules/catalog/category.repo";
import { logger } from "@/lib/logger";

const CACHE_KEY = "categories:tree:v1";
const CACHE_TTL_SECONDS = 300; // 5 minutes

export const GET = errorHandler(async (_request: NextRequest) => {
	try {
		await redisClient.connect();
		const cached = await redisClient.getJSON(CACHE_KEY);

		if (cached) {
			const response: ApiResponse<typeof cached> = {
				success: true,
				data: cached,
			};
			return NextResponse.json(response, { status: 200 });
		}
	} catch (error) {
		logger.warn("Category tree cache unavailable", error);
	}

	const categories = await getCategoryTree();

	try {
		await redisClient.setJSON(CACHE_KEY, categories, CACHE_TTL_SECONDS);
	} catch (error) {
		logger.warn("Failed to set category tree cache", error);
	}

	const response: ApiResponse<typeof categories> = {
		success: true,
		data: categories,
	};

	return NextResponse.json(response, { status: 200 });
});
