import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/middleware/admin.middleware";
import { deleteFile, saveImageFile } from "@/lib/file_storage";
import * as productRepo from "@/modules/catalog/product.repo";

export async function POST(request: NextRequest) {
	try {
		// Check admin authentication
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) {
			return adminResult.response;
		}

		// Parse form data
		const formData = await request.formData();
		const file = formData.get("file") as File;
		const productId = formData.get("productId") as string;

		if (!file) {
			return NextResponse.json({ error: "No file provided" }, { status: 400 });
		}

		if (!productId) {
			return NextResponse.json(
				{ error: "Product ID is required" },
				{ status: 400 },
			);
		}

		// Verify product exists
		const product = await productRepo.findProductById(productId);
		if (!product) {
			return NextResponse.json({ error: "Product not found" }, { status: 404 });
		}

		// Convert File to Buffer
		const buffer = await file.arrayBuffer();
		const bufferData = Buffer.from(buffer);

		// Validate image
		if (!["image/jpeg", "image/png", "image/webp"].includes(file.type)) {
			return NextResponse.json(
				{
					error: `Invalid image type. Allowed: image/jpeg, image/png, image/webp`,
				},
				{ status: 400 },
			);
		}

		if (bufferData.length > 5 * 1024 * 1024) {
			return NextResponse.json(
				{ error: "Image size exceeds maximum of 5MB" },
				{ status: 400 },
			);
		}

		// Remove old image if present
		if (product.imageUrl) {
			deleteFile(product.imageUrl);
		}

		// Save image file
		const imageUrl = await saveImageFile(file.name, bufferData);

		// Update product with image URL
		await productRepo.updateProduct(productId, {
			imageUrl,
			fileType: "IMAGE",
		});

		return NextResponse.json(
			{
				success: true,
				imageUrl,
				message: "Image uploaded successfully",
			},
			{ status: 200 },
		);
	} catch (error) {
		console.error("Error uploading image:", error);
		const errorMessage =
			error instanceof Error ? error.message : "Failed to upload image";
		return NextResponse.json({ error: errorMessage }, { status: 500 });
	}
}
