/**
 * Prisma minimal seed script for production
 *
 * Run: npm run prisma:seed
 *
 * This script creates only the essential admin user.
 * All products, subjects, categories, etc. will be added manually.
 */

const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcrypt");
const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../.env") });

const prisma = new PrismaClient();

async function main() {
	console.log("🌱 Starting minimal database seed...");

	// ============================================
	// ADMIN USER
	// ============================================
	console.log("\n👤 Creating admin user...");

	const adminEmail = process.env.ADMIN_EMAIL || "admin@admin.com";
	const adminPhone = process.env.ADMIN_PHONE || "+919876543210";
	const adminPassword = process.env.ADMIN_PASSWORD || "pass123";
	const passwordHash = await bcrypt.hash(adminPassword, 10);

	console.log(`\n📧 Admin Email from env: ${process.env.ADMIN_EMAIL}`);
	console.log(`🔒 Admin Password from env: ${process.env.ADMIN_PASSWORD}`);
	console.log(`📱 Admin Phone from env: ${process.env.ADMIN_PHONE}`);

	// Delete any existing admin with the same phone or email to avoid unique constraint issues
	try {
		await prisma.user.deleteMany({
			where: {
				OR: [{ phone: adminPhone }, { email: adminEmail }],
			},
		});
		console.log("✓ Cleared existing admin records");
	} catch (error) {
		console.log("ℹ️ No existing admin records to clear");
	}

	const admin = await prisma.user.create({
		data: {
			name: "Admin",
			phone: adminPhone,
			email: adminEmail,
			passwordHash,
			role: "ADMIN",
			isActive: true,
		},
	});

	console.log("✓ Admin user created:", admin.email);

	console.log("\n✅ Database seeded successfully!");
	console.log("\n👤 Admin Login Credentials:");
	console.log(`   Email: ${adminEmail}`);
	console.log(`   Password: ${adminPassword}`);
	console.log("\n📝 Next Steps:");
	console.log("   1. Log in to the admin panel");
	console.log("   2. Create categories");
	console.log("   3. Add subjects");
	console.log("   4. Add products");
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
