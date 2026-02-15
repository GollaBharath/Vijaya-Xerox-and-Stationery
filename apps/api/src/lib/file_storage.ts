import fs from "fs";
import path from "path";
import { randomBytes } from "crypto";

const UPLOADS_DIR = path.join(process.cwd(), "uploads");
const IMAGES_DIR = path.join(UPLOADS_DIR, "images", "products");
const PDFS_DIR = path.join(UPLOADS_DIR, "pdfs", "books");

// Max file sizes (in bytes)
const MAX_IMAGE_SIZE = 5 * 1024 * 1024; // 5MB
const MAX_PDF_SIZE = 10 * 1024 * 1024; // 10MB

// Allowed MIME types
const ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/webp"];
const ALLOWED_PDF_TYPES = ["application/pdf"];

/**
 * Initialize upload directories
 */
export function initializeUploadDirs(): void {
	if (!fs.existsSync(IMAGES_DIR)) {
		fs.mkdirSync(IMAGES_DIR, { recursive: true });
	}
	if (!fs.existsSync(PDFS_DIR)) {
		fs.mkdirSync(PDFS_DIR, { recursive: true });
	}
}

/**
 * Generate a unique filename
 */
export function generateFilename(originalName: string): string {
	const ext = path.extname(originalName);
	const name = path.basename(originalName, ext);
	const timestamp = Date.now();
	const random = randomBytes(4).toString("hex");
	return `${name}-${timestamp}-${random}${ext}`;
}

/**
 * Validate image file
 */
export function validateImage(file: Express.Multer.File): {
	valid: boolean;
	error?: string;
} {
	if (!file) {
		return { valid: false, error: "No file provided" };
	}

	// Check MIME type
	if (!ALLOWED_IMAGE_TYPES.includes(file.mimetype)) {
		return {
			valid: false,
			error: `Invalid image type. Allowed: ${ALLOWED_IMAGE_TYPES.join(", ")}`,
		};
	}

	// Check file size
	if (file.size > MAX_IMAGE_SIZE) {
		return {
			valid: false,
			error: `Image size exceeds maximum of ${MAX_IMAGE_SIZE / 1024 / 1024}MB`,
		};
	}

	return { valid: true };
}

/**
 * Validate PDF file
 */
export function validatePDF(file: Express.Multer.File): {
	valid: boolean;
	error?: string;
} {
	if (!file) {
		return { valid: false, error: "No file provided" };
	}

	// Check MIME type
	if (!ALLOWED_PDF_TYPES.includes(file.mimetype)) {
		return {
			valid: false,
			error: `Invalid PDF type. Only application/pdf allowed`,
		};
	}

	// Check file size
	if (file.size > MAX_PDF_SIZE) {
		return {
			valid: false,
			error: `PDF size exceeds maximum of ${MAX_PDF_SIZE / 1024 / 1024}MB`,
		};
	}

	return { valid: true };
}

/**
 * Save image file
 */
export async function saveImageFile(
	filename: string,
	buffer: Buffer,
): Promise<string> {
	initializeUploadDirs();
	// Validate size
	const MAX_IMAGE_SIZE = 5 * 1024 * 1024;
	if (buffer.length > MAX_IMAGE_SIZE) {
		throw new Error(
			`Image size exceeds maximum of ${MAX_IMAGE_SIZE / 1024 / 1024}MB`,
		);
	}

	const uniqueFilename = generateFilename(filename);
	const filepath = path.join(IMAGES_DIR, uniqueFilename);

	fs.writeFileSync(filepath, buffer);

	return `/api/v1/files/images/products/${uniqueFilename}`;
}

/**
 * Save PDF file
 */
export async function savePDFFile(
	filename: string,
	buffer: Buffer,
): Promise<string> {
	initializeUploadDirs();
	// Validate size
	const MAX_PDF_SIZE = 10 * 1024 * 1024;
	if (buffer.length > MAX_PDF_SIZE) {
		throw new Error(
			`PDF size exceeds maximum of ${MAX_PDF_SIZE / 1024 / 1024}MB`,
		);
	}

	const uniqueFilename = generateFilename(filename);
	const filepath = path.join(PDFS_DIR, uniqueFilename);

	fs.writeFileSync(filepath, buffer);


	return `/api/v1/files/pdfs/books/${uniqueFilename}`;
}

/**
 * Save Preview Image file
 */
export async function savePreviewImage(
	filename: string,
	buffer: Buffer,
): Promise<string> {
	initializeUploadDirs();

	// Ensure filename ends with .png (or desired format)
	const baseName = path.basename(filename, path.extname(filename));
	const uniqueFilename = `${baseName}-${Date.now()}-preview.png`;
	const filepath = path.join(PDFS_DIR, uniqueFilename); // Saving in PDF dir for now to keep related files together, or could be IMAGES_DIR

	// Or better, save in IMAGES_DIR but maybe a subdirectory?
	// Let's save in IMAGES_DIR as it is an image
	const imagePreviewPath = path.join(IMAGES_DIR, uniqueFilename);

	fs.writeFileSync(imagePreviewPath, buffer);

	return `/api/v1/files/images/products/${uniqueFilename}`;
}

/**
 * Delete file from filesystem
 */
export function deleteFile(relativeUrl: string): boolean {
	try {
		// Extract filename from URL like /api/v1/files/images/products/filename.jpg
		const urlParts = relativeUrl.split("/");
		const filename = urlParts[urlParts.length - 1];

		if (relativeUrl.includes("/images/")) {
			const filepath = path.join(IMAGES_DIR, filename);
			if (fs.existsSync(filepath)) {
				fs.unlinkSync(filepath);
				return true;
			}
		} else if (relativeUrl.includes("/pdfs/")) {
			const filepath = path.join(PDFS_DIR, filename);
			if (fs.existsSync(filepath)) {
				fs.unlinkSync(filepath);
				return true;
			}
		}
		return false;
	} catch (error) {
		console.error("Error deleting file:", error);
		return false;
	}
}

/**
 * Get absolute file path from relative URL
 */
export function getFilePath(relativeUrl: string): string | null {
	try {
		const urlParts = relativeUrl.split("/");
		const filename = urlParts[urlParts.length - 1];

		if (relativeUrl.includes("/images/")) {
			const filepath = path.join(IMAGES_DIR, filename);
			if (fs.existsSync(filepath)) {
				return filepath;
			}
		} else if (relativeUrl.includes("/pdfs/")) {
			const filepath = path.join(PDFS_DIR, filename);
			if (fs.existsSync(filepath)) {
				return filepath;
			}
		}
		return null;
	} catch (error) {
		console.error("Error getting file path:", error);
		return null;
	}
}

/**
 * Get all files in a directory
 */
export function getFilesInDirectory(dir: "images" | "pdfs"): string[] {
	try {
		const dirPath = dir === "images" ? IMAGES_DIR : PDFS_DIR;
		if (!fs.existsSync(dirPath)) {
			return [];
		}
		return fs.readdirSync(dirPath);
	} catch (error) {
		console.error("Error reading directory:", error);
		return [];
	}
}
