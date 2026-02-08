#!/usr/bin/env node
/**
 * Database Connection Test
 * Tests PostgreSQL connection
 */

const path = require("path");
const { PrismaClient } = require(
	path.join(__dirname, "../apps/api/node_modules/@prisma/client"),
);
require(path.join(__dirname, "../apps/api/node_modules/dotenv")).config({
	path: path.join(__dirname, "../apps/api/.env"),
});

async function testDatabaseConnection() {
	console.log("\n🔍 Testing Database Connection...\n");

	if (!process.env.DATABASE_URL) {
		console.error("❌ Error: DATABASE_URL environment variable not set");
		process.exit(1);
	}

	const dbUrl = process.env.DATABASE_URL;
	console.log("📡 Database URL:", dbUrl.replace(/:[^:@]+@/, ":****@")); // Hide password

	const prisma = new PrismaClient({
		log: ["error", "warn"],
	});

	try {
		console.log("⏳ Connecting to database...");

		// Test connection with a simple query
		await prisma.$connect();
		console.log("✅ Connected successfully!\n");

		// Test query
		console.log("🔍 Testing query...");
		const result = await prisma.$queryRaw`SELECT 1 as test`;
		console.log("✅ Query successful:", result);

		// Get database version
		const version = await prisma.$queryRaw`SELECT version()`;
		console.log("\n📊 Database info:");
		console.log(
			"   Version:",
			version[0].version.split(" ")[0],
			version[0].version.split(" ")[1],
		);

		console.log("\n🎉 Database connection test passed!\n");
	} catch (error) {
		console.error("\n❌ Connection test failed:", error.message);
		console.log("\n💡 Troubleshooting:");
		console.log("   1. Check DATABASE_URL format (no quotes!)");
		console.log("   2. Verify password is correct");
		console.log("   3. Ensure ?sslmode=require is present");
		console.log("   4. Check database is accessible from your IP\n");
		process.exit(1);
	} finally {
		await prisma.$disconnect();
	}
}

testDatabaseConnection();
