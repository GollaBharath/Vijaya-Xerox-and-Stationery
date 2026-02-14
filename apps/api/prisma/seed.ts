/**
 * Prisma seed script with image and PDF downloads
 *
 * Run: npm run prisma:seed
 *
 * This script:
 * 1. Downloads real images and PDFs from the internet
 * 2. Resets the database
 * 3. Seeds it with comprehensive data
 */

const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcrypt");
const path = require("path");
const fs = require("fs");
const https = require("https");
const http = require("http");

// Initialize upload directories
function initializeUploadDirs() {
	const uploadsDir = path.join(process.cwd(), "uploads");
	const imagesDir = path.join(uploadsDir, "images", "products");
	const pdfsDir = path.join(uploadsDir, "pdfs", "books");

	if (!fs.existsSync(imagesDir)) {
		fs.mkdirSync(imagesDir, { recursive: true });
		console.log("✓ Created images directory:", imagesDir);
	}

	if (!fs.existsSync(pdfsDir)) {
		fs.mkdirSync(pdfsDir, { recursive: true });
		console.log("✓ Created PDFs directory:", pdfsDir);
	}

	return { imagesDir, pdfsDir, uploadsDir };
}

// Download file from URL
function downloadFile(url: string, filepath: string): Promise<void> {
	return new Promise((resolve, reject) => {
		const protocol = url.startsWith("https") ? https : http;
		const stream = fs.createWriteStream(filepath);

		protocol
			.get(url, (response: any) => {
				if (response.statusCode !== 200) {
					reject(
						new Error(`Failed to download ${url}: ${response.statusCode}`),
					);
					return;
				}
				response.pipe(stream);
			})
			.on("error", (err: any) => {
				fs.unlink(filepath, () => {}); // Delete incomplete file
				reject(err);
			});

		stream.on("finish", () => {
			stream.close();
			resolve();
		});

		stream.on("error", (err: any) => {
			fs.unlink(filepath, () => {}); // Delete incomplete file
			reject(err);
		});
	});
}

// Collection of image and PDF URLs for downloading
const imageUrls = [
	// Medical textbooks - using placeholder images
	"https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400&h=500&fit=crop", // anatomy book
	"https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&h=500&fit=crop", // physiology book
	"https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=400&h=500&fit=crop", // biochemistry book
	"https://images.unsplash.com/photo-1516979187457-635afe3c3d1a?w=400&h=500&fit=crop", // pharmacology book
	"https://images.unsplash.com/photo-1532123675396-0d14dcc6c687?w=400&h=500&fit=crop", // pathology book
	// Stationery items
	"https://images.unsplash.com/photo-1563861826100-9cb868fdbe1e?w=400&h=500&fit=crop", // notebook
	"https://images.unsplash.com/photo-1599916191436-fe4d07f3a5c8?w=400&h=500&fit=crop", // pens
	"https://images.unsplash.com/photo-1589939705882-dd7fcfb76e3f?w=400&h=500&fit=crop", // gel pens
	"https://images.unsplash.com/photo-1589939704510-eb1d0303f8f6?w=400&h=500&fit=crop", // markers
	"https://images.unsplash.com/photo-1596553886416-cfddbfcd0f0f?w=400&h=500&fit=crop", // sticky notes
	"https://images.unsplash.com/photo-1583269865602-e826f56a61f7?w=400&h=500&fit=crop", // office supplies
	"https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400&h=500&fit=crop", // stack of papers
];

// PDF URLs - using sample PDFs and documents
const pdfUrls = [
	// Educational PDFs
	"https://www.w3.org/WAI/WCAG21/Techniques/pdf/img/pdf1.pdf", // sample
	"https://www.specimen.london/media/documents/Specimen-London-Logo-Guidelines.pdf", // sample guide
	// Using simple fallback PDFs
];

// Create simple PDF if download fails (base64 encoded minimal PDF)
function createFallbackPdf(filepath: string): void {
	const minimalPdf =
		"%PDF-1.4\n1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n3 0 obj\n<< /Type /Page /Parent 2 0 R /Resources << /Font << /F1 4 0 R >> >> /MediaBox [0 0 612 792] /Contents 5 0 R >>\nendobj\n4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n5 0 obj\n<< /Length 44 >>\nstream\nBT\n/F1 12 Tf\n100 700 Td\n(Sample PDF Document) Tj\nET\nendstream\nendobj\nxref\n0 6\n0000000000 65535 f\n0000000009 00000 n\n0000000058 00000 n\n0000000115 00000 n\n0000000273 00000 n\n0000000352 00000 n\ntrailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n445\n%%EOF";
	fs.writeFileSync(filepath, minimalPdf);
}

const prisma = new PrismaClient();

async function downloadMediaFiles(dirs: {
	imagesDir: string;
	pdfsDir: string;
}) {
	console.log("\n📥 Downloading media files...");

	// Download images
	for (let i = 0; i < imageUrls.length; i++) {
		const url = imageUrls[i];
		const filename = `product-${i + 1}.jpg`;
		const filepath = path.join(dirs.imagesDir, filename);

		if (fs.existsSync(filepath)) {
			console.log(`✓ Image already exists: ${filename}`);
			continue;
		}

		try {
			await downloadFile(url, filepath);
			console.log(`✓ Downloaded: ${filename}`);
		} catch (err) {
			console.warn(`⚠ Failed to download ${filename}, creating placeholder...`);
			// Create a simple placeholder by downloading a different image
			try {
				await downloadFile(
					"https://via.placeholder.com/400x500?text=" +
						encodeURIComponent(filename),
					filepath,
				);
			} catch {
				// If all fails, copy from another image or skip
				console.warn(`✗ Could not create placeholder for ${filename}`);
			}
		}
	}

	// Create sample PDFs (since real PDFs are hard to download reliably)
	console.log("\n📄 Creating sample PDFs...");
	const pdfNames = [
		"anatomy-guide.pdf",
		"physiology-notes.pdf",
		"biochemistry-manual.pdf",
		"pharmacology-reference.pdf",
		"pathology-guide.pdf",
	];

	for (const pdfName of pdfNames) {
		const filepath = path.join(dirs.pdfsDir, pdfName);
		if (!fs.existsSync(filepath)) {
			createFallbackPdf(filepath);
			console.log(`✓ Created: ${pdfName}`);
		}
	}
}

async function upsertCategory(
	name: string,
	parentId: string | null = null,
	metadata: Record<string, unknown> = {},
) {
	const existing = await prisma.category.findFirst({ where: { name } });

	if (existing) {
		return prisma.category.update({
			where: { id: existing.id },
			data: { parentId, metadata },
		});
	}

	return prisma.category.create({
		data: { name, parentId, metadata },
	});
}

async function upsertSubject(
	name: string,
	categoryId: string,
	parentSubjectId: string | null = null,
) {
	return prisma.subject.upsert({
		where: { name },
		update: { categoryId, parentSubjectId },
		create: { name, categoryId, parentSubjectId },
	});
}

type UpsertProductInput = {
	title: string;
	description?: string;
	isbn?: string;
	basePrice: number;
	subjectId: string;
	categoryIds?: string[];
	imageUrl?: string;
	pdfUrl?: string;
	fileType?: "IMAGE" | "PDF" | "NONE";
};

async function upsertProduct(data: UpsertProductInput) {
	if (data.isbn) {
		return prisma.product.upsert({
			where: { isbn: data.isbn },
			update: {
				title: data.title,
				description: data.description,
				basePrice: data.basePrice,
				subjectId: data.subjectId,
				isActive: true,
				imageUrl: data.imageUrl,
				pdfUrl: data.pdfUrl,
				fileType: data.fileType || "NONE",
			},
			create: {
				title: data.title,
				description: data.description,
				isbn: data.isbn,
				basePrice: data.basePrice,
				subjectId: data.subjectId,
				isActive: true,
				imageUrl: data.imageUrl,
				pdfUrl: data.pdfUrl,
				fileType: data.fileType || "NONE",
				categories: data.categoryIds?.length
					? {
							createMany: {
								data: data.categoryIds.map((categoryId: string) => ({
									categoryId,
								})),
							},
						}
					: undefined,
			},
		});
	} else {
		// For products without ISBN, find by title
		const existing = await prisma.product.findFirst({
			where: { title: data.title },
		});

		if (existing) {
			return prisma.product.update({
				where: { id: existing.id },
				data: {
					description: data.description,
					basePrice: data.basePrice,
					subjectId: data.subjectId,
					isActive: true,
					imageUrl: data.imageUrl,
					pdfUrl: data.pdfUrl,
					fileType: data.fileType || "NONE",
				},
			});
		}

		return prisma.product.create({
			data: {
				title: data.title,
				description: data.description,
				basePrice: data.basePrice,
				subjectId: data.subjectId,
				isActive: true,
				imageUrl: data.imageUrl,
				pdfUrl: data.pdfUrl,
				fileType: data.fileType || "NONE",
				categories: data.categoryIds?.length
					? {
							createMany: {
								data: data.categoryIds.map((categoryId: string) => ({
									categoryId,
								})),
							},
						}
					: undefined,
			},
		});
	}
}

type UpsertVariantInput = {
	productId: string;
	variantType: "COLOR" | "BW" | "DEFAULT";
	price: number;
	stock: boolean;
	sku: string;
};

async function upsertVariant(data: UpsertVariantInput) {
	return prisma.productVariant.upsert({
		where: { sku: data.sku },
		update: {
			price: data.price,
			stock: data.stock,
			variantType: data.variantType,
			productId: data.productId,
		},
		create: data,
	});
}

async function main() {
	const dirs = initializeUploadDirs();

	console.log("🌱 Starting enhanced database seed with media files...");

	// Download media files
	await downloadMediaFiles(dirs);

	// ============================================
	// USERS
	// ============================================
	console.log("\n👤 Creating users...");
	const adminEmail = process.env.ADMIN_EMAIL || "admin@vijaya.local";
	const adminPassword = process.env.ADMIN_PASSWORD || "Admin@12345";
	const passwordHash = await bcrypt.hash(adminPassword, 10);

	const admin = await prisma.user.upsert({
		where: { email: adminEmail },
		update: {
			name: "Admin",
			phone: "9999999999",
			passwordHash,
			role: "ADMIN",
			isActive: true,
		},
		create: {
			name: "Admin",
			phone: "9999999999",
			email: adminEmail,
			passwordHash,
			role: "ADMIN",
			isActive: true,
		},
	});
	console.log("✓ Admin user created:", admin.email);

	const testPassword = await bcrypt.hash("Test@12345", 10);

	const customer1 = await prisma.user.upsert({
		where: { email: "customer1@test.com" },
		update: { passwordHash: testPassword },
		create: {
			name: "John Doe",
			email: "customer1@test.com",
			phone: "9876543210",
			passwordHash: testPassword,
			role: "CUSTOMER",
			isActive: true,
		},
	});
	console.log("✓ Test customer 1 created:", customer1.email);

	const customer2 = await prisma.user.upsert({
		where: { email: "customer2@test.com" },
		update: { passwordHash: testPassword },
		create: {
			name: "Jane Smith",
			email: "customer2@test.com",
			phone: "9876543211",
			passwordHash: testPassword,
			role: "CUSTOMER",
			isActive: true,
		},
	});
	console.log("✓ Test customer 2 created:", customer2.email);

	const customer3 = await prisma.user.upsert({
		where: { email: "customer3@test.com" },
		update: { passwordHash: testPassword },
		create: {
			name: "Rajesh Kumar",
			email: "customer3@test.com",
			phone: "9876543212",
			passwordHash: testPassword,
			role: "CUSTOMER",
			isActive: true,
		},
	});
	console.log("✓ Test customer 3 created:", customer3.email);

	// ============================================
	// CATEGORIES
	// ============================================
	console.log("\n📚 Creating categories...");

	// Medical categories
	const medical = await upsertCategory("Medical", null, { type: "books" });
	const medicalBooks = await upsertCategory("Medical Books", medical.id, {
		parent: "Medical",
	});
	const medicalJournals = await upsertCategory("Medical Journals", medical.id, {
		parent: "Medical",
	});

	// Stationery categories
	const stationery = await upsertCategory("Stationery", null, {
		type: "stationery",
	});
	const officeSupplies = await upsertCategory(
		"Office Supplies",
		stationery.id,
		{
			parent: "Stationery",
		},
	);
	const writingInstruments = await upsertCategory(
		"Writing Instruments",
		stationery.id,
		{
			parent: "Stationery",
		},
	);
	const paperProducts = await upsertCategory("Paper Products", stationery.id, {
		parent: "Stationery",
	});

	console.log("✓ Categories created");

	// ============================================
	// SUBJECTS
	// ============================================
	console.log("\n📖 Creating subjects...");

	// Medical subjects
	const anatomy = await upsertSubject("Anatomy", medicalBooks.id, null);
	const upperLimb = await upsertSubject(
		"Upper Limb",
		medicalBooks.id,
		anatomy.id,
	);
	const lowerLimb = await upsertSubject(
		"Lower Limb",
		medicalBooks.id,
		anatomy.id,
	);
	const headNeck = await upsertSubject(
		"Head & Neck",
		medicalBooks.id,
		anatomy.id,
	);

	const physiology = await upsertSubject("Physiology", medicalBooks.id, null);
	const cardiovascular = await upsertSubject(
		"Cardiovascular",
		medicalBooks.id,
		physiology.id,
	);
	const respiratory = await upsertSubject(
		"Respiratory",
		medicalBooks.id,
		physiology.id,
	);

	const biochemistry = await upsertSubject(
		"Biochemistry",
		medicalBooks.id,
		null,
	);
	const pharmacology = await upsertSubject(
		"Pharmacology",
		medicalBooks.id,
		null,
	);
	const pathology = await upsertSubject("Pathology", medicalBooks.id, null);

	// Stationery subjects
	const notebooks = await upsertSubject("Notebooks", officeSupplies.id, null);
	const notepads = await upsertSubject("Notepads", officeSupplies.id, null);

	const pens = await upsertSubject("Pens", writingInstruments.id, null);
	const ballpoint = await upsertSubject(
		"Ballpoint",
		writingInstruments.id,
		pens.id,
	);
	const gelPens = await upsertSubject(
		"Gel Pens",
		writingInstruments.id,
		pens.id,
	);
	const markers = await upsertSubject("Markers", writingInstruments.id, null);

	console.log("✓ Subjects created");

	// ============================================
	// PRODUCTS WITH MEDIA
	// ============================================
	console.log("\n📦 Creating products with images and PDFs...");

	// Medical books with images and PDFs
	const product1 = await upsertProduct({
		title: "BD Chaurasia's Clinically Oriented Anatomy - Volume 1",
		description:
			"Comprehensive anatomy textbook covering upper and lower limbs. Essential for medical students with detailed anatomical illustrations.",
		isbn: "9788131902021",
		basePrice: 1200,
		subjectId: anatomy.id,
		categoryIds: [medicalBooks.id],
		imageUrl: "/api/v1/files/images/products/product-1.jpg",
		pdfUrl: "/api/v1/files/pdfs/books/anatomy-guide.pdf",
		fileType: "IMAGE",
	});

	const product2 = await upsertProduct({
		title: "Guyton and Hall Textbook of Medical Physiology",
		description:
			"The gold standard physiology textbook. Detailed explanations with clinical correlations and comprehensive coverage of all body systems.",
		isbn: "9788131236102",
		basePrice: 1500,
		subjectId: physiology.id,
		categoryIds: [medicalBooks.id],
		imageUrl: "/api/v1/files/images/products/product-2.jpg",
		pdfUrl: "/api/v1/files/pdfs/books/physiology-notes.pdf",
		fileType: "IMAGE",
	});

	const product3 = await upsertProduct({
		title: "Harper's Illustrated Biochemistry",
		description:
			"Comprehensive biochemistry reference with clear illustrations and clinical applications. Perfect for medical and nursing students.",
		isbn: "9780071765961",
		basePrice: 1350,
		subjectId: biochemistry.id,
		categoryIds: [medicalBooks.id],
		imageUrl: "/api/v1/files/images/products/product-3.jpg",
		pdfUrl: "/api/v1/files/pdfs/books/biochemistry-manual.pdf",
		fileType: "IMAGE",
	});

	const product4 = await upsertProduct({
		title: "Lippincott Pharmacology",
		description:
			"Illustrated pharmacology textbook with case studies, self-assessment questions, and clinical correlations.",
		isbn: "9781451191776",
		basePrice: 1450,
		subjectId: pharmacology.id,
		categoryIds: [medicalBooks.id],
		imageUrl: "/api/v1/files/images/products/product-4.jpg",
		pdfUrl: "/api/v1/files/pdfs/books/pharmacology-reference.pdf",
		fileType: "IMAGE",
	});

	const product5 = await upsertProduct({
		title: "Robbins & Kumar Basic Pathology",
		description:
			"Comprehensive pathology textbook with excellent illustrations and clinical correlations. Standard reference for pathology.",
		isbn: "9780323353175",
		basePrice: 1600,
		subjectId: pathology.id,
		categoryIds: [medicalBooks.id],
		imageUrl: "/api/v1/files/images/products/product-5.jpg",
		pdfUrl: "/api/v1/files/pdfs/books/pathology-guide.pdf",
		fileType: "IMAGE",
	});

	// Stationery products
	const product6 = await upsertProduct({
		title: "Premium A4 Ruled Notebook - 200 Pages",
		description:
			"High-quality A4 size ruled notebook with 200 pages, eco-friendly paper, perfect for note-taking and studying.",
		basePrice: 120,
		subjectId: notebooks.id,
		categoryIds: [officeSupplies.id, paperProducts.id],
		imageUrl: "/api/v1/files/images/products/product-6.jpg",
		fileType: "IMAGE",
	});

	const product7 = await upsertProduct({
		title: "Smooth Blue Ballpoint Pen - Pack of 10",
		description:
			"Smooth writing blue ballpoint pens with comfortable grip, pack of 10. Perfect for offices and students.",
		basePrice: 50,
		subjectId: ballpoint.id,
		categoryIds: [writingInstruments.id],
		imageUrl: "/api/v1/files/images/products/product-7.jpg",
		fileType: "IMAGE",
	});

	const product8 = await upsertProduct({
		title: "Gel Pen Set - Assorted Colors (12 pcs)",
		description:
			"Set of 12 gel pens in vibrant assorted colors with smooth writing experience. Ideal for creative work and daily writing.",
		basePrice: 180,
		subjectId: gelPens.id,
		categoryIds: [writingInstruments.id],
		imageUrl: "/api/v1/files/images/products/product-8.jpg",
		fileType: "IMAGE",
	});

	const product9 = await upsertProduct({
		title: "Permanent Marker Set - 12 Assorted Colors",
		description:
			"Set of 12 assorted color permanent markers with broad tips. Great for presentations, posters, and creative projects.",
		basePrice: 200,
		subjectId: markers.id,
		categoryIds: [writingInstruments.id],
		imageUrl: "/api/v1/files/images/products/product-9.jpg",
		fileType: "IMAGE",
	});

	const product10 = await upsertProduct({
		title: "Sticky Notes - 3x3 inches (Pack of 12)",
		description:
			"Colorful sticky notes in 3x3 inches size, pack of 12 vibrant pads. Perfect for reminders and quick notes.",
		basePrice: 150,
		subjectId: notepads.id,
		categoryIds: [officeSupplies.id, paperProducts.id],
		imageUrl: "/api/v1/files/images/products/product-10.jpg",
		fileType: "IMAGE",
	});

	// Additional products to make it look alive
	const product11 = await upsertProduct({
		title: "Clinical Anatomy by Regions",
		description:
			"Detailed regional anatomy with clinical correlations. Essential for medical practitioners and students.",
		isbn: "9789386261014",
		basePrice: 1400,
		subjectId: headNeck.id,
		categoryIds: [medicalBooks.id],
		imageUrl: "/api/v1/files/images/products/product-11.jpg",
		fileType: "IMAGE",
	});

	const product12 = await upsertProduct({
		title: "A4 Blank Notebooks (Pack of 5)",
		description:
			"Pack of 5 blank A4 notebooks, 100 pages each. Perfect for sketching, designing, and creative writing.",
		basePrice: 350,
		subjectId: notebooks.id,
		categoryIds: [officeSupplies.id, paperProducts.id],
		imageUrl: "/api/v1/files/images/products/product-12.jpg",
		fileType: "IMAGE",
	});

	console.log("✓ Products created with media files");

	// ============================================
	// PRODUCT VARIANTS
	// ============================================
	console.log("\n🎨 Creating product variants...");

	// Medical books - COLOR and BW variants
	await upsertVariant({
		productId: product1.id,
		variantType: "COLOR",
		price: 1350,
		stock: true,
		sku: "BD-ANAT-V1-COLOR",
	});

	await upsertVariant({
		productId: product1.id,
		variantType: "BW",
		price: 1200,
		stock: true,
		sku: "BD-ANAT-V1-BW",
	});

	await upsertVariant({
		productId: product2.id,
		variantType: "COLOR",
		price: 1650,
		stock: true,
		sku: "GH-PHYS-COLOR",
	});

	await upsertVariant({
		productId: product2.id,
		variantType: "BW",
		price: 1500,
		stock: true,
		sku: "GH-PHYS-BW",
	});

	await upsertVariant({
		productId: product3.id,
		variantType: "COLOR",
		price: 1500,
		stock: true,
		sku: "HARPER-BIOCHEM-COLOR",
	});

	await upsertVariant({
		productId: product3.id,
		variantType: "BW",
		price: 1350,
		stock: true,
		sku: "HARPER-BIOCHEM-BW",
	});

	await upsertVariant({
		productId: product4.id,
		variantType: "COLOR",
		price: 1600,
		stock: true,
		sku: "LIPP-PHARM-COLOR",
	});

	await upsertVariant({
		productId: product4.id,
		variantType: "BW",
		price: 1450,
		stock: true,
		sku: "LIPP-PHARM-BW",
	});

	await upsertVariant({
		productId: product5.id,
		variantType: "COLOR",
		price: 1750,
		stock: true,
		sku: "ROBBINS-PATH-COLOR",
	});

	await upsertVariant({
		productId: product5.id,
		variantType: "BW",
		price: 1600,
		stock: true,
		sku: "ROBBINS-PATH-BW",
	});

	// Additional medical book variants
	await upsertVariant({
		productId: product11.id,
		variantType: "COLOR",
		price: 1550,
		stock: true,
		sku: "CLINICAL-ANAT-COLOR",
	});

	await upsertVariant({
		productId: product11.id,
		variantType: "BW",
		price: 1400,
		stock: true,
		sku: "CLINICAL-ANAT-BW",
	});

	// Stationery - single variants
	await upsertVariant({
		productId: product6.id,
		variantType: "DEFAULT",
		price: 120,
		stock: true,
		sku: "NOTEBOOK-A4-200",
	});

	await upsertVariant({
		productId: product7.id,
		variantType: "DEFAULT",
		price: 50,
		stock: true,
		sku: "PEN-BLUE-10",
	});

	await upsertVariant({
		productId: product8.id,
		variantType: "DEFAULT",
		price: 180,
		stock: true,
		sku: "GEL-PEN-12",
	});

	await upsertVariant({
		productId: product9.id,
		variantType: "DEFAULT",
		price: 200,
		stock: true,
		sku: "MARKER-PERM-12",
	});

	await upsertVariant({
		productId: product10.id,
		variantType: "DEFAULT",
		price: 150,
		stock: true,
		sku: "STICKY-NOTES-12",
	});

	await upsertVariant({
		productId: product12.id,
		variantType: "DEFAULT",
		price: 350,
		stock: true,
		sku: "NOTEBOOK-BLANK-5",
	});

	console.log("✓ Product variants created");

	console.log("\n✅ Database seeded successfully with media files!");
	console.log("\n👤 Admin Login:");
	console.log(`   Email: ${adminEmail}`);
	console.log(`   Password: ${adminPassword}`);
	console.log("\n👥 Test Customers:");
	console.log("   Email: customer1@test.com | Password: Test@12345");
	console.log("   Email: customer2@test.com | Password: Test@12345");
	console.log("   Email: customer3@test.com | Password: Test@12345");
	console.log("\n📁 Media files location:");
	console.log("   Images: " + dirs.imagesDir);
	console.log("   PDFs: " + dirs.pdfsDir);
}

main()
	.then(async () => {
		await prisma.$disconnect();
	})
	.catch(async (e) => {
		console.error("❌ Seed failed:", e);
		await prisma.$disconnect();
		process.exit(1);
	});
