import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/middleware/admin.middleware";
import { deleteFile, savePDFFile } from "@/lib/file_storage";
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

		// Validate PDF - check file extension if MIME type is not reliable
		const fileName = file.name.toLowerCase();
		const isPdfMimeType = file.type === "application/pdf";
		const isPdfExtension = fileName.endsWith(".pdf");

		if (!isPdfMimeType && !isPdfExtension) {
			return NextResponse.json(
				{ error: "Invalid file type. Only PDF allowed" },
				{ status: 400 },
			);
		}

		if (bufferData.length > 10 * 1024 * 1024) {
			return NextResponse.json(
				{ error: "PDF size exceeds maximum of 10MB" },
				{ status: 400 },
			);
		}

		// Remove old PDF if present
		if (product.pdfUrl) {
			deleteFile(product.pdfUrl);
		}

		// Save PDF file
		const pdfUrl = await savePDFFile(file.name, bufferData);

		// Update product with PDF URL
		await productRepo.updateProduct(productId, {
			pdfUrl,
			fileType: "PDF",
		});

		return NextResponse.json(
			{
				success: true,
				pdfUrl,
				message: "PDF uploaded successfully",
			},
			{ status: 200 },
		);
	} catch (error) {
		console.error("Error uploading PDF:", error);
		const errorMessage =
			error instanceof Error ? error.message : "Failed to upload PDF";
		return NextResponse.json({ error: errorMessage }, { status: 500 });
	}
}
