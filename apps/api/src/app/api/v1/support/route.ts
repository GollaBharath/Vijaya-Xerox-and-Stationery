// GET /api/v1/support - Get support info

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { SupportService } from "@/modules/support/support.service";
import { ApiResponse } from "@/types/global";

const supportService = new SupportService();

export const GET = errorHandler(async (req: NextRequest) => {
	const supportInfo = await supportService.getSupportInfo();

	const response: ApiResponse<typeof supportInfo> = {
		success: true,
		data: supportInfo,
	};

	return NextResponse.json(response, { status: 200 });
});
