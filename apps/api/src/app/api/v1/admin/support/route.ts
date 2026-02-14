// PATCH /api/v1/admin/support - Update support info (admin only)
// GET /api/v1/admin/support - Get support info (admin only)

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { requireAdmin } from "@/middleware/admin.middleware";
import { SupportService } from "@/modules/support/support.service";
import { updateSupportInfoSchema } from "@/modules/support/support.validator";
import { ApiResponse } from "@/types/global";

const supportService = new SupportService();

export const GET = errorHandler(async (req: NextRequest) => {
	const adminResult = await requireAdmin(req);
	if (!adminResult.authorized) return adminResult.response;

	const supportInfo = await supportService.getSupportInfo();

	const response: ApiResponse<typeof supportInfo> = {
		success: true,
		data: supportInfo,
	};

	return NextResponse.json(response, { status: 200 });
});

export const PATCH = errorHandler(async (req: NextRequest) => {
	const adminResult = await requireAdmin(req);
	if (!adminResult.authorized) return adminResult.response;

	const body = await req.json();
	const validationResult = updateSupportInfoSchema.safeParse(body);

	if (!validationResult.success) {
		return NextResponse.json(
			{
				success: false,
				error: "Validation failed",
				details: validationResult.error.errors,
			},
			{ status: 400 },
		);
	}

	const supportInfo = await supportService.updateSupportInfo(
		validationResult.data,
	);

	const response: ApiResponse<typeof supportInfo> = {
		success: true,
		data: supportInfo,
	};

	return NextResponse.json(response, { status: 200 });
});
