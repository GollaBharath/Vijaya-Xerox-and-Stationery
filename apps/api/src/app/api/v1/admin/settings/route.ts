/**
 * GET /api/v1/admin/settings
 * POST /api/v1/admin/settings
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler, NotFoundError } from "@/middleware/error.middleware";
import { requireAdmin } from "@/middleware/admin.middleware";
import { ApiResponse } from "@/types/global";
import { getAllSettings, setSetting } from "@/modules/settings/settings.repo";

export const GET = errorHandler(async (request: NextRequest) => {
	const adminResult = await requireAdmin(request);
	if (!adminResult.authorized) return adminResult.response;

	const settings = await getAllSettings();

	const response: ApiResponse<typeof settings> = {
		success: true,
		data: settings,
	};

	return NextResponse.json(response, { status: 200 });
});

export const POST = errorHandler(async (request: NextRequest) => {
	const adminResult = await requireAdmin(request);
	if (!adminResult.authorized) return adminResult.response;

	const body = await request.json();

	if (!body.key || typeof body.key !== "string") {
		throw new NotFoundError("Setting key");
	}

	const valueJson = body.valueJson ?? null;
	const setting = await setSetting(body.key, valueJson);

	const response: ApiResponse<typeof setting> = {
		success: true,
		data: setting,
		message: "Setting saved",
	};

	return NextResponse.json(response, { status: 200 });
});
