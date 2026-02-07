/**
 * GET /api/v1/subjects/tree
 * Returns subject hierarchy
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { ApiResponse } from "@/types/global";
import { getSubjectTree } from "@/modules/subjects/subjects.repo";

export const GET = errorHandler(async (_request: NextRequest) => {
	const subjects = await getSubjectTree();

	const response: ApiResponse<typeof subjects> = {
		success: true,
		data: subjects,
	};

	return NextResponse.json(response, { status: 200 });
});
