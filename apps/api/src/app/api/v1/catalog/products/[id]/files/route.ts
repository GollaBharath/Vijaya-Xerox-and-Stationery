import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/middleware/admin.middleware";
import * as productRepo from "@/modules/catalog/product.repo";

export async function DELETE(
	request: NextRequest,
	{ params }: { params: { id: string } },
) {
	try {
		const productId = params.id;

		// Check admin authentication
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) {
			return adminResult.response;
		}

		// Verify product exists
		const product = await productRepo.findProductById(productId);
		if (!product) {
			return NextResponse.json({ error: "Product not found" }, { status: 404 });
		}

		// Delete product files
		const success = await productRepo.deleteProductFiles(productId);

		if (!success) {
			return NextResponse.json(
				{ error: "Failed to delete product files" },
				{ status: 500 },
			);
		}

		return NextResponse.json(
			{
				success: true,
				message: "Product files deleted successfully",
			},
			{ status: 200 },
		);
	} catch (error) {
		console.error("Error deleting product files:", error);
		const errorMessage =
			error instanceof Error ? error.message : "Failed to delete files";
		return NextResponse.json({ error: errorMessage }, { status: 500 });
	}
}
