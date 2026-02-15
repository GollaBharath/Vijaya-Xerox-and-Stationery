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

const prisma = new PrismaClient();

async function main() {
	console.log("🌱 Starting minimal database seed...");

	// ============================================
	// ADMIN USER
	// ============================================
	console.log("\n👤 Creating admin user...");

	const adminEmail = "vijaya@admin.com";
	const adminPassword = "admin14321";
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
