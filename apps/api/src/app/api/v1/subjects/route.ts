/**
 * GET /api/v1/subjects
 * POST /api/v1/subjects (admin)
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { requireAdmin } from "@/middleware/admin.middleware";
import { ApiResponse } from "@/types/global";
import {
	findAllSubjects,
	createSubject,
} from "@/modules/subjects/subjects.repo";
import { validateCreateSubject } from "@/modules/subjects/subjects.validator";
import { redisClient } from "@/lib/redis";
import { logger } from "@/lib/logger";

export const GET = errorHandler(async (_request: NextRequest) => {
	const subjects = await findAllSubjects();

	const response: ApiResponse<typeof subjects> = {
		success: true,
		data: subjects,
	};

	return NextResponse.json(response, { status: 200 });
});

export const POST = errorHandler(async (request: NextRequest) => {
	const adminResult = await requireAdmin(request);
	if (!adminResult.authorized) return adminResult.response;

	const body = await request.json();
	const payload = validateCreateSubject(body);

	const subject = await createSubject(
		payload.name,
		payload.categoryId,
		payload.parentSubjectId ?? null,
	);

	// Invalidate subject tree cache
	try {
		await redisClient.connect();
		await redisClient.del("subjects:tree:v1");
	} catch (error) {
		logger.warn("Failed to invalidate subject cache", error);
	}

	const response: ApiResponse<typeof subject> = {
		success: true,
		data: subject,
		message: "Subject created successfully",
	};

	return NextResponse.json(response, { status: 201 });
});
