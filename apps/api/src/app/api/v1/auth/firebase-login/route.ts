/**
 * POST /api/v1/auth/firebase-login
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { ApiResponse } from "@/types/global";
import { firebaseLogin } from "@/modules/auth/auth.service";

export const POST = errorHandler(async (request: NextRequest) => {
	const body = await request.json();

	const { idToken } = body;

	if (!idToken) {
		return NextResponse.json(
			{
				success: false,
				error: {
					code: "VALIDATION_ERROR",
					message: "Firebase ID token is required",
				},
			},
			{ status: 400 },
		);
	}

	const result = await firebaseLogin(idToken);

	const response: ApiResponse<typeof result> = {
		success: true,
		data: result,
		message: "Firebase login successful",
	};

	return NextResponse.json(response, { status: 200 });
});
