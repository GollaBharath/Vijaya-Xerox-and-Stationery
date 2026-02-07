/**
 * GET /api/v1/catalog/products/:id
 * PATCH /api/v1/catalog/products/:id (admin)
 * DELETE /api/v1/catalog/products/:id (admin)
 */

import { NextRequest, NextResponse } from "next/server";
import { errorHandler, NotFoundError } from "@/middleware/error.middleware";
import { requireAdmin } from "@/middleware/admin.middleware";
import { ApiResponse } from "@/types/global";
import {
	getProductWithVariants,
	updateProduct,
	deleteProduct,
} from "@/modules/catalog/product.repo";
import { validateUpdateProduct } from "@/modules/catalog/catalog.validator";

export const GET = errorHandler(
	async (_request: NextRequest, { params }: { params: { id: string } }) => {
		const product = await getProductWithVariants(params.id);
		if (!product) throw new NotFoundError("Product");

		const response: ApiResponse<typeof product> = {
			success: true,
			data: product,
		};

		return NextResponse.json(response, { status: 200 });
	},
);

export const PATCH = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const body = await request.json();
		const payload = validateUpdateProduct(body);

		const product = await updateProduct(params.id, payload);

		const response: ApiResponse<typeof product> = {
			success: true,
			data: product,
			message: "Product updated successfully",
		};

		return NextResponse.json(response, { status: 200 });
	},
);

export const DELETE = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const product = await deleteProduct(params.id);

		const response: ApiResponse<typeof product> = {
			success: true,
			data: product,
			message: "Product deleted successfully",
		};

		return NextResponse.json(response, { status: 200 });
	},
);
