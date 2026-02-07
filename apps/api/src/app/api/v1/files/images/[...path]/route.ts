import { NextRequest, NextResponse } from "next/server";
import { getFilePath } from "@/lib/file_storage";
import fs from "fs";

export async function GET(
	request: NextRequest,
	{ params }: { params: { path: string[] } },
) {
	try {
		const filename = params.path[params.path.length - 1];
		const relativeUrl = `/api/v1/files/images/products/${filename}`;

		const filepath = getFilePath(relativeUrl);
		if (!filepath) {
			return NextResponse.json({ error: "Image not found" }, { status: 404 });
		}

		const fileBuffer = fs.readFileSync(filepath);
		const ext = filename.split(".").pop()?.toLowerCase();

		const mimeTypes: Record<string, string> = {
			jpg: "image/jpeg",
			jpeg: "image/jpeg",
			png: "image/png",
			webp: "image/webp",
		};

		const contentType = mimeTypes[ext || ""] || "application/octet-stream";

		return new NextResponse(fileBuffer, {
			status: 200,
			headers: {
				"Content-Type": contentType,
				"Cache-Control": "public, max-age=31536000, immutable",
			},
		});
	} catch (error) {
		console.error("Error serving image:", error);
		return NextResponse.json(
			{ error: "Failed to serve image" },
			{ status: 500 },
		);
	}
}
