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
	// Try to find existing category by name
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
	parentSubjectId: string | null = null,
) {
	return prisma.subject.upsert({
		where: { name },
		update: { parentSubjectId },
		create: { name, parentSubjectId },
	});
}

type UpsertProductInput = {
	title: string;
	description?: string;
	isbn: string;
	basePrice: number;
	subjectId: string;
	categoryIds?: string[];
};

async function upsertProductByIsbn(data: UpsertProductInput) {
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
	// Initialize upload directories first
	initializeUploadDirs();

	console.log("🌱 Starting database seed...");

	// Create Admin User
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

	// Create Test Customer Users
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

	console.log("✓ Test customer 2 created:", customer2.email);

	// Create Categories
	console.log("\n📚 Creating categories...");
	const medical = await upsertCategory("Medical", null, { type: "books" });
	const stationery = await upsertCategory("Stationery", null, {
		type: "stationery",
	});
	const medicalBooks = await upsertCategory("Medical Books", medical.id, {
		parent: "Medical",
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
	console.log("✓ Categories created");

	// Create Subjects
	console.log("\n📖 Creating subjects...");
	const anatomy = await upsertSubject("Anatomy", null);
	const physiology = await upsertSubject("Physiology", null);
	const biochemistry = await upsertSubject("Biochemistry", null);
	const pharmacology = await upsertSubject("Pharmacology", null);
	const general = await upsertSubject("General", null);
	console.log("✓ Subjects created");

	// Create Products
	console.log("\n📦 Creating products...");
	const product1 = await upsertProductByIsbn({
		title: "BD Chaurasia Anatomy - Volume 1",
		description:
			"Comprehensive anatomy textbook covering upper and lower limbs. Essential for medical students.",
		isbn: "9788131902021",
		basePrice: 1200,
		subjectId: anatomy.id,
		categoryIds: [medicalBooks.id],
	});

	const product2 = await upsertProductByIsbn({
		title: "Guyton and Hall Textbook of Medical Physiology",
		description:
			"The gold standard physiology textbook. Detailed explanations with clinical correlations.",
		isbn: "9788131236102",
		basePrice: 1500,
		subjectId: physiology.id,
		categoryIds: [medicalBooks.id],
	});

	const product3 = await upsertProductByIsbn({
		title: "Harper's Illustrated Biochemistry",
		description:
			"Comprehensive biochemistry reference with clear illustrations and clinical applications.",
		isbn: "9780071765961",
		basePrice: 1350,
		subjectId: biochemistry.id,
		categoryIds: [medicalBooks.id],
	});

	const product4 = await upsertProductByIsbn({
		title: "Lippincott Pharmacology",
		description:
			"Illustrated pharmacology textbook with case studies and self-assessment questions.",
		isbn: "9781451191776",
		basePrice: 1450,
		subjectId: pharmacology.id,
		categoryIds: [medicalBooks.id],
	});

	const product5 = await upsertProductByIsbn({
		title: "Gray's Anatomy for Students",
		description:
			"The classic anatomy reference book with detailed illustrations and clinical notes.",
		isbn: "9780323393041",
		basePrice: 2500,
		subjectId: anatomy.id,
		categoryIds: [medicalBooks.id],
	});

	const notebook = await prisma.product.findFirst({
		where: { title: "Notebook A4 - 200 Pages" },
	});
	const product6 =
		notebook ||
		(await prisma.product.create({
			data: {
				title: "Notebook A4 - 200 Pages",
				description:
					"A4 size ruled notebook with 200 pages, perfect for note-taking",
				basePrice: 120,
				subjectId: general.id,
				isActive: true,
				categories: {
					createMany: {
						data: [{ categoryId: officeSupplies.id }],
					},
				},
			},
		}));

	const pen = await prisma.product.findFirst({
		where: { title: "Blue Ballpoint Pen" },
	});
	const product7 =
		pen ||
		(await prisma.product.create({
			data: {
				title: "Blue Ballpoint Pen",
				description: "Smooth writing blue ballpoint pen, pack of 10",
				basePrice: 50,
				subjectId: general.id,
				isActive: true,
				categories: {
					createMany: {
						data: [{ categoryId: writingInstruments.id }],
					},
				},
			},
		}));

	const marker = await prisma.product.findFirst({
		where: { title: "Permanent Marker Set" },
	});
	const product8 =
		marker ||
		(await prisma.product.create({
			data: {
				title: "Permanent Marker Set",
				description: "Set of 12 assorted color permanent markers",
				basePrice: 180,
				subjectId: general.id,
				isActive: true,
				categories: {
					createMany: {
						data: [{ categoryId: writingInstruments.id }],
					},
				},
			},
		}));
	console.log("✓ Products created");

	// Create Product Variants
	console.log("\n🎨 Creating product variants...");
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
		price: 2750,
		stock: 5,
		sku: "GRAY-ANAT-COLOR",
	});

	await upsertVariant({
		productId: product5.id,
		variantType: "BW",
		price: 2500,
		stock: 7,
		sku: "GRAY-ANAT-BW",
	});

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
		stock: 50,
		sku: "MARKER-PERM-12",
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
