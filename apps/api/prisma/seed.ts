/**
 * Prisma seed script
 *
 * Run: npm run prisma:seed
 */

const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcrypt");
const path = require("path");
const fs = require("fs");

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
}

const prisma = new PrismaClient();

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
			},
			create: {
				title: data.title,
				description: data.description,
				isbn: data.isbn,
				basePrice: data.basePrice,
				subjectId: data.subjectId,
				isActive: true,
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
	variantType: "COLOR" | "BW";
	price: number;
	stock: number;
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
	initializeUploadDirs();

	console.log("🌱 Starting database seed...");

	// ============================================
	// USERS
	// ============================================
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

	// ============================================
	// CATEGORIES
	// ============================================
	console.log("\n📚 Creating categories...");

	// Medical categories
	const medical = await upsertCategory("Medical", null, { type: "books" });
	const medicalBooks = await upsertCategory("Medical Books", medical.id, {
		parent: "Medical",
	});

	// Stationery categories
	const stationery = await upsertCategory("Stationery", null, {
		type: "stationery",
	});
	const officeSupplies = await upsertCategory("Office Supplies", stationery.id, {
		parent: "Stationery",
	});
	const writingInstruments = await upsertCategory(
		"Writing Instruments",
		stationery.id,
		{
			parent: "Stationery",
		},
	);

	console.log("✓ Categories created");

	// ============================================
	// SUBJECTS (with proper category relationships)
	// ============================================
	console.log("\n📖 Creating subjects...");

	// Medical subjects under Medical Books category
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
	const headNeck = await upsertSubject("Head & Neck", medicalBooks.id, anatomy.id);

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

	const biochemistry = await upsertSubject("Biochemistry", medicalBooks.id, null);
	const pharmacology = await upsertSubject("Pharmacology", medicalBooks.id, null);
	const pathology = await upsertSubject("Pathology", medicalBooks.id, null);

	// Stationery subjects
	const paperProducts = await upsertSubject(
		"Paper Products",
		officeSupplies.id,
		null,
	);
	const notebooks = await upsertSubject(
		"Notebooks",
		officeSupplies.id,
		paperProducts.id,
	);
	const notepads = await upsertSubject(
		"Notepads",
		officeSupplies.id,
		paperProducts.id,
	);

	const pens = await upsertSubject("Pens", writingInstruments.id, null);
	const ballpoint = await upsertSubject(
		"Ballpoint",
		writingInstruments.id,
		pens.id,
	);
	const gelPens = await upsertSubject("Gel Pens", writingInstruments.id, pens.id);

	const markers = await upsertSubject("Markers", writingInstruments.id, null);

	console.log("✓ Subjects created");

	// ============================================
	// PRODUCTS
	// ============================================
	console.log("\n📦 Creating products...");

	// Medical books
	const product1 = await upsertProduct({
		title: "BD Chaurasia Anatomy - Volume 1 (Upper & Lower Limbs)",
		description:
			"Comprehensive anatomy textbook covering upper and lower limbs. Essential for medical students.",
		isbn: "9788131902021",
		basePrice: 1200,
		subjectId: anatomy.id,
		categoryIds: [medicalBooks.id],
	});

	const product2 = await upsertProduct({
		title: "Guyton and Hall Textbook of Medical Physiology",
		description:
			"The gold standard physiology textbook. Detailed explanations with clinical correlations.",
		isbn: "9788131236102",
		basePrice: 1500,
		subjectId: physiology.id,
		categoryIds: [medicalBooks.id],
	});

	const product3 = await upsertProduct({
		title: "Harper's Illustrated Biochemistry",
		description:
			"Comprehensive biochemistry reference with clear illustrations and clinical applications.",
		isbn: "9780071765961",
		basePrice: 1350,
		subjectId: biochemistry.id,
		categoryIds: [medicalBooks.id],
	});

	const product4 = await upsertProduct({
		title: "Lippincott Pharmacology",
		description:
			"Illustrated pharmacology textbook with case studies and self-assessment questions.",
		isbn: "9781451191776",
		basePrice: 1450,
		subjectId: pharmacology.id,
		categoryIds: [medicalBooks.id],
	});

	const product5 = await upsertProduct({
		title: "Robbins Basic Pathology",
		description:
			"Comprehensive pathology textbook with excellent illustrations and clinical correlations.",
		isbn: "9780323353175",
		basePrice: 1600,
		subjectId: pathology.id,
		categoryIds: [medicalBooks.id],
	});

	// Stationery products
	const product6 = await upsertProduct({
		title: "A4 Ruled Notebook - 200 Pages",
		description:
			"Premium quality A4 size ruled notebook with 200 pages, perfect for note-taking",
		basePrice: 120,
		subjectId: notebooks.id,
		categoryIds: [officeSupplies.id],
	});

	const product7 = await upsertProduct({
		title: "Blue Ballpoint Pen (Pack of 10)",
		description: "Smooth writing blue ballpoint pens, pack of 10",
		basePrice: 50,
		subjectId: ballpoint.id,
		categoryIds: [writingInstruments.id],
	});

	const product8 = await upsertProduct({
		title: "Gel Pen Set - Assorted Colors (12 pcs)",
		description: "Set of 12 gel pens in assorted colors, smooth writing",
		basePrice: 180,
		subjectId: gelPens.id,
		categoryIds: [writingInstruments.id],
	});

	const product9 = await upsertProduct({
		title: "Permanent Marker Set (12 colors)",
		description: "Set of 12 assorted color permanent markers",
		basePrice: 200,
		subjectId: markers.id,
		categoryIds: [writingInstruments.id],
	});

	const product10 = await upsertProduct({
		title: "Sticky Notes - 3x3 inches (Pack of 12)",
		description: "Colorful sticky notes, 3x3 inches, pack of 12 pads",
		basePrice: 150,
		subjectId: notepads.id,
		categoryIds: [officeSupplies.id],
	});

	console.log("✓ Products created");

	// ============================================
	// PRODUCT VARIANTS
	// ============================================
	console.log("\n🎨 Creating product variants...");

	// Medical books - COLOR and BW variants
	await upsertVariant({
		productId: product1.id,
		variantType: "COLOR",
		price: 1350,
		stock: 15,
		sku: "BD-ANAT-V1-COLOR",
	});

	await upsertVariant({
		productId: product1.id,
		variantType: "BW",
		price: 1200,
		stock: 25,
		sku: "BD-ANAT-V1-BW",
	});

	await upsertVariant({
		productId: product2.id,
		variantType: "COLOR",
		price: 1650,
		stock: 12,
		sku: "GH-PHYS-COLOR",
	});

	await upsertVariant({
		productId: product2.id,
		variantType: "BW",
		price: 1500,
		stock: 18,
		sku: "GH-PHYS-BW",
	});

	await upsertVariant({
		productId: product3.id,
		variantType: "COLOR",
		price: 1500,
		stock: 10,
		sku: "HARPER-BIOCHEM-COLOR",
	});

	await upsertVariant({
		productId: product3.id,
		variantType: "BW",
		price: 1350,
		stock: 14,
		sku: "HARPER-BIOCHEM-BW",
	});

	await upsertVariant({
		productId: product4.id,
		variantType: "COLOR",
		price: 1600,
		stock: 8,
		sku: "LIPP-PHARM-COLOR",
	});

	await upsertVariant({
		productId: product4.id,
		variantType: "BW",
		price: 1450,
		stock: 11,
		sku: "LIPP-PHARM-BW",
	});

	await upsertVariant({
		productId: product5.id,
		variantType: "COLOR",
		price: 1750,
		stock: 6,
		sku: "ROBBINS-PATH-COLOR",
	});

	await upsertVariant({
		productId: product5.id,
		variantType: "BW",
		price: 1600,
		stock: 9,
		sku: "ROBBINS-PATH-BW",
	});

	// Stationery - single variants
	await upsertVariant({
		productId: product6.id,
		variantType: "BW",
		price: 120,
		stock: 100,
		sku: "NOTEBOOK-A4-200",
	});

	await upsertVariant({
		productId: product7.id,
		variantType: "BW",
		price: 50,
		stock: 200,
		sku: "PEN-BLUE-10",
	});

	await upsertVariant({
		productId: product8.id,
		variantType: "COLOR",
		price: 180,
		stock: 80,
		sku: "GEL-PEN-12",
	});

	await upsertVariant({
		productId: product9.id,
		variantType: "COLOR",
		price: 200,
		stock: 50,
		sku: "MARKER-PERM-12",
	});

	await upsertVariant({
		productId: product10.id,
		variantType: "COLOR",
		price: 150,
		stock: 120,
		sku: "STICKY-NOTES-12",
	});

	console.log("✓ Product variants created");

	console.log("\n✅ Database seeded successfully!");
	console.log("\n👤 Admin Login:");
	console.log(`   Email: ${adminEmail}`);
	console.log(`   Password: ${adminPassword}`);
	console.log("\n👥 Test Customers:");
	console.log("   Email: customer1@test.com | Password: Test@12345");
	console.log("   Email: customer2@test.com | Password: Test@12345");
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
