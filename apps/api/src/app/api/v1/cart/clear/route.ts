/**
 * DELETE /api/v1/cart/clear
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler } from "@/middleware/error.middleware";
import { requireAuth } from "@/middleware/auth.middleware";
import { ApiResponse } from "@/types/global";
import { clearCart } from "@/modules/cart/cart.repo";

export const DELETE = errorHandler(async (request: NextRequest) => {
	const authResult = await requireAuth(request);
	if (!authResult.authorized) return authResult.response;

	await clearCart(authResult.user.userId);

	const response: ApiResponse<{ cleared: boolean }> = {
		success: true,
		data: { cleared: true },
		message: "Cart cleared",
	};

	return NextResponse.json(response, { status: 200 });
});
