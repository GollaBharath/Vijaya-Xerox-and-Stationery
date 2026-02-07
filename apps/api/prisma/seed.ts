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

	const adminEmail = process.env.ADMIN_EMAIL || "admin@vijaya.local";
	const adminPassword = process.env.ADMIN_PASSWORD || "Admin@12345";

	const passwordHash = await bcrypt.hash(adminPassword, 10);

	await prisma.user.upsert({
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

	const medical = await upsertCategory("Medical", null, { type: "books" });
	const stationery = await upsertCategory("Stationery", null, {
		type: "stationery",
	});
	const medicalBooks = await upsertCategory("Medical Books", medical.id, {
		parent: "Medical",
	});

	const anatomy = await upsertSubject("Anatomy", null);
	const physiology = await upsertSubject("Physiology", null);
	const general = await upsertSubject("General", null);

	const product1 = await upsertProductByIsbn({
		title: "BD Chaurasia Anatomy",
		description: "Anatomy textbook",
		isbn: "9788131902021",
		basePrice: 1200,
		subjectId: anatomy.id,
		categoryIds: [medicalBooks.id],
	});

	const product2 = await upsertProductByIsbn({
		title: "Guyton and Hall Physiology",
		description: "Physiology textbook",
		isbn: "9788131236102",
		basePrice: 1500,
		subjectId: physiology.id,
		categoryIds: [medicalBooks.id],
	});

	const notebook = await prisma.product.findFirst({
		where: { title: "Notebook A4" },
	});
	const product3 =
		notebook ||
		(await prisma.product.create({
			data: {
				title: "Notebook A4",
				description: "A4 ruled notebook",
				basePrice: 120,
				subjectId: general.id,
				isActive: true,
				categories: {
					createMany: {
						data: [{ categoryId: stationery.id }],
					},
				},
			},
		}));

	await upsertVariant({
		productId: product1.id,
		variantType: "COLOR",
		price: 1350,
		stock: 10,
		sku: "BD-ANAT-COLOR",
	});

	await upsertVariant({
		productId: product1.id,
		variantType: "BW",
		price: 1200,
		stock: 20,
		sku: "BD-ANAT-BW",
	});

	await upsertVariant({
		productId: product2.id,
		variantType: "COLOR",
		price: 1600,
		stock: 8,
		sku: "GH-PHYS-COLOR",
	});

	await upsertVariant({
		productId: product3.id,
		variantType: "BW",
		price: 120,
		stock: 50,
		sku: "NOTEBOOK-A4-BW",
	});
}

main()
	.then(async () => {
		await prisma.$disconnect();
		console.log("Seed completed");
	})
	.catch(async (e) => {
		console.error(e);
		await prisma.$disconnect();
		process.exit(1);
	});
