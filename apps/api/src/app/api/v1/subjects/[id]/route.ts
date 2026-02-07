/**
 * GET /api/v1/subjects/:id
 * PATCH /api/v1/subjects/:id (admin)
 * DELETE /api/v1/subjects/:id (admin)
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler, NotFoundError } from "@/middleware/error.middleware";
import { requireAdmin } from "@/middleware/admin.middleware";
import { ApiResponse } from "@/types/global";
import {
	findSubjectById,
	updateSubject,
	deleteSubject,
} from "@/modules/subjects/subjects.repo";
import { validateUpdateSubject } from "@/modules/subjects/subjects.validator";

export const GET = errorHandler(
	async (_request: NextRequest, { params }: { params: { id: string } }) => {
		const subject = await findSubjectById(params.id);
		if (!subject) throw new NotFoundError("Subject");

		const response: ApiResponse<typeof subject> = {
			success: true,
			data: subject,
		};

		return NextResponse.json(response, { status: 200 });
	},
);

export const PATCH = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const body = await request.json();
		const payload = validateUpdateSubject(body);

		const subject = await updateSubject(params.id, payload);

		const response: ApiResponse<typeof subject> = {
			success: true,
			data: subject,
			message: "Subject updated successfully",
		};

		return NextResponse.json(response, { status: 200 });
	},
);

export const DELETE = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const subject = await deleteSubject(params.id);

		const response: ApiResponse<typeof subject> = {
			success: true,
			data: subject,
			message: "Subject deleted successfully",
		};

		return NextResponse.json(response, { status: 200 });
	},
);
