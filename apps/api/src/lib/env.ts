/**
 * Environment Variables Validation and Export
 *
 * Ensures all required environment variables are present
 * and provides type-safe access
 */

interface EnvConfig {
	// Database
	DATABASE_URL: string;

	// Redis
	REDIS_URL: string;

	// JWT
	JWT_SECRET: string;
	JWT_REFRESH_SECRET: string;
	JWT_EXPIRES_IN: string;
	JWT_REFRESH_EXPIRES_IN: string;

	// OAuth
	GOOGLE_CLIENT_ID?: string;
	GOOGLE_CLIENT_SECRET?: string;
	FACEBOOK_APP_ID?: string;
	FACEBOOK_APP_SECRET?: string;
	APPLE_CLIENT_ID?: string;
	APPLE_TEAM_ID?: string;
	APPLE_KEY_ID?: string;
	APPLE_PRIVATE_KEY?: string;

	// Razorpay
	RAZORPAY_KEY_ID: string;
	RAZORPAY_KEY_SECRET: string;
	RAZORPAY_WEBHOOK_SECRET: string;

	// App
	NODE_ENV: "development" | "production" | "test";
	PORT: string;
	API_BASE_URL: string;

	// Admin
	ADMIN_EMAIL: string;
	ADMIN_PASSWORD: string;
}

function validateEnv(): EnvConfig {
	const requiredEnvVars = [
		"DATABASE_URL",
		"REDIS_URL",
		"JWT_SECRET",
		"JWT_REFRESH_SECRET",
		"JWT_EXPIRES_IN",
		"JWT_REFRESH_EXPIRES_IN",
		"RAZORPAY_KEY_ID",
		"RAZORPAY_KEY_SECRET",
		"RAZORPAY_WEBHOOK_SECRET",
		"NODE_ENV",
		"PORT",
		"API_BASE_URL",
		"ADMIN_EMAIL",
		"ADMIN_PASSWORD",
	];

	const missingVars: string[] = [];

	for (const envVar of requiredEnvVars) {
		if (!process.env[envVar]) {
			missingVars.push(envVar);
		}
	}

	if (missingVars.length > 0) {
		throw new Error(
			`Missing required environment variables: ${missingVars.join(", ")}\n` +
				"Please check your .env file and ensure all required variables are set.",
		);
	}

	return {
		DATABASE_URL: process.env.DATABASE_URL!,
		REDIS_URL: process.env.REDIS_URL!,
		JWT_SECRET: process.env.JWT_SECRET!,
		JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET!,
		JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN!,
		JWT_REFRESH_EXPIRES_IN: process.env.JWT_REFRESH_EXPIRES_IN!,
		GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID,
		GOOGLE_CLIENT_SECRET: process.env.GOOGLE_CLIENT_SECRET,
		FACEBOOK_APP_ID: process.env.FACEBOOK_APP_ID,
		FACEBOOK_APP_SECRET: process.env.FACEBOOK_APP_SECRET,
		APPLE_CLIENT_ID: process.env.APPLE_CLIENT_ID,
		APPLE_TEAM_ID: process.env.APPLE_TEAM_ID,
		APPLE_KEY_ID: process.env.APPLE_KEY_ID,
		APPLE_PRIVATE_KEY: process.env.APPLE_PRIVATE_KEY,
		RAZORPAY_KEY_ID: process.env.RAZORPAY_KEY_ID!,
		RAZORPAY_KEY_SECRET: process.env.RAZORPAY_KEY_SECRET!,
		RAZORPAY_WEBHOOK_SECRET: process.env.RAZORPAY_WEBHOOK_SECRET!,
		NODE_ENV: process.env.NODE_ENV as "development" | "production" | "test",
		PORT: process.env.PORT!,
		API_BASE_URL: process.env.API_BASE_URL!,
		ADMIN_EMAIL: process.env.ADMIN_EMAIL!,
		ADMIN_PASSWORD: process.env.ADMIN_PASSWORD!,
	};
}

export const env = validateEnv();
