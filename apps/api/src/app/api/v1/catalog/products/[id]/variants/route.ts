/**
 * GET /api/v1/catalog/products/:id/variants
 * POST /api/v1/catalog/products/:id/variants (admin)
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler, NotFoundError } from "@/middleware/error.middleware";
import { requireAdmin } from "@/middleware/admin.middleware";
import { ApiResponse } from "@/types/global";
import {
	findVariantsByProduct,
	createVariant,
} from "@/modules/catalog/variant.repo";
import { validateCreateVariant } from "@/modules/catalog/catalog.validator";
import { findProductById } from "@/modules/catalog/product.repo";

export const GET = errorHandler(
	async (_request: NextRequest, { params }: { params: { id: string } }) => {
		const variants = await findVariantsByProduct(params.id);

		const response: ApiResponse<typeof variants> = {
			success: true,
			data: variants,
		};

		return NextResponse.json(response, { status: 200 });
	},
);

export const POST = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const product = await findProductById(params.id);
		if (!product) throw new NotFoundError("Product");

		const body = await request.json();
		const payload = validateCreateVariant({ ...body, productId: params.id });

		const variant = await createVariant(payload);

		const response: ApiResponse<typeof variant> = {
			success: true,
			data: variant,
			message: "Variant created successfully",
		};

		return NextResponse.json(response, { status: 201 });
	},
);
