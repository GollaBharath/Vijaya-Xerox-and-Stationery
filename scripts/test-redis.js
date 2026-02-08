#!/usr/bin/env node
/**
 * Upstash Redis Connection Test
 *
 * Tests the Redis connection to ensure Upstash is properly configured
 * Run: node scripts/test-redis.js
 */

const { createClient } = require("redis");
require("dotenv").config();

async function testRedisConnection() {
	console.log("\n🔍 Testing Upstash Redis Connection...\n");

	// Validate environment variable
	if (!process.env.REDIS_URL) {
		console.error("❌ Error: REDIS_URL environment variable not set");
		console.log("💡 Please set REDIS_URL in your .env file");
		process.exit(1);
	}

	const redisUrl = process.env.REDIS_URL;
	console.log("📡 Redis URL:", redisUrl.replace(/:[^:@]+@/, ":****@")); // Hide password

	// Check if it's an Upstash URL
	const isUpstash = redisUrl.startsWith("rediss://");
	if (isUpstash) {
		console.log("✓ Detected Upstash Redis (TLS enabled)");
	} else {
		console.log("⚠️  Warning: Not using secure connection (rediss://)");
	}

	// Create Redis client
	const client = createClient({
		url: redisUrl,
		socket: isUpstash
			? {
					tls: true,
					rejectUnauthorized: true,
				}
			: undefined,
	});

	// Event handlers
	client.on("error", (err) => {
		console.error("❌ Redis Client Error:", err.message);
	});

	client.on("connect", () => {
		console.log("✓ Connected to Redis server");
	});

	try {
		// Connect
		console.log("\n⏳ Connecting...");
		await client.connect();
		console.log("✅ Connection successful!\n");

		// Test PING
		console.log("🏓 Testing PING command...");
		const pingResponse = await client.ping();
		console.log(`✅ PING response: ${pingResponse}\n`);

		// Test SET
		console.log("📝 Testing SET command...");
		const testKey = "upstash:test:connection";
		const testValue = `Test at ${new Date().toISOString()}`;
		await client.set(testKey, testValue, { EX: 60 });
		console.log(`✅ SET ${testKey} = ${testValue}\n`);

		// Test GET
		console.log("📖 Testing GET command...");
		const retrievedValue = await client.get(testKey);
		console.log(`✅ GET ${testKey} = ${retrievedValue}\n`);

		// Verify value
		if (retrievedValue === testValue) {
			console.log("✅ Value verification successful!\n");
		} else {
			console.log("❌ Value mismatch!\n");
		}

		// Test DELETE
		console.log("🗑️  Testing DEL command...");
		await client.del(testKey);
		console.log(`✅ Deleted ${testKey}\n`);

		// Get server info
		console.log("ℹ️  Server Information:");
		const info = await client.info("server");
		const redisVersion = info.match(/redis_version:([\d.]+)/)?.[1];
		if (redisVersion) {
			console.log(`   Redis Version: ${redisVersion}`);
		}

		console.log("\n🎉 All tests passed! Upstash Redis is working correctly.\n");
	} catch (error) {
		console.error("\n❌ Connection test failed:", error.message);
		console.log("\n💡 Troubleshooting tips:");
		console.log(
			"   1. Check your REDIS_URL format: rediss://default:password@endpoint.upstash.io:6379",
		);
		console.log("   2. Verify credentials in Upstash dashboard");
		console.log("   3. Ensure your IP is not blocked by firewall");
		console.log("   4. Check if Upstash database is active\n");
		process.exit(1);
	} finally {
		// Cleanup
		await client.quit();
		console.log("👋 Disconnected from Redis\n");
	}
}

// Run the test
testRedisConnection().catch((error) => {
	console.error("Fatal error:", error);
	process.exit(1);
});
