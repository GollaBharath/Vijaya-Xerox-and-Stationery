import { NextRequest, NextResponse } from "next/server";
import { getFilePath } from "@/lib/file_storage";
import fs from "fs";

export async function GET(
	request: NextRequest,
	{ params }: { params: { path: string[] } },
) {
	try {
		const filename = params.path[params.path.length - 1];
		const relativeUrl = `/api/v1/files/pdfs/books/${filename}`;

		const filepath = getFilePath(relativeUrl);
		if (!filepath) {
			return NextResponse.json({ error: "PDF not found" }, { status: 404 });
		}

		const fileBuffer = fs.readFileSync(filepath);

		// Check if inline preview is requested
		const inline = request.nextUrl.searchParams.get("inline") === "true";
		const disposition = inline ? "inline" : "attachment";

		return new NextResponse(fileBuffer, {
			status: 200,
			headers: {
				"Content-Type": "application/pdf",
				"Content-Disposition": `${disposition}; filename="${filename}"`,
				"Cache-Control": "public, max-age=31536000, immutable",
			},
		});
	} catch (error) {
		console.error("Error serving PDF:", error);
		return NextResponse.json({ error: "Failed to serve PDF" }, { status: 500 });
	}
}
