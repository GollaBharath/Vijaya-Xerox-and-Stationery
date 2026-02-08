/**
 * Redis Client Setup
 *
 * Used for caching and session storage
 */

import { createClient, RedisClientType } from "redis";
import { env } from "./env";
import { logger } from "./logger";

class RedisClient {
	private static instance: RedisClient;
	private client: RedisClientType;
	private isConnected: boolean = false;

	private constructor() {
		// Parse Redis URL to check if it's Upstash (uses rediss:// protocol)
		const isUpstash = env.REDIS_URL.startsWith("rediss://");

		this.client = createClient({
			url: env.REDIS_URL,
			// Enable TLS for Upstash (rediss:// protocol)
			socket: isUpstash
				? {
						tls: true,
						rejectUnauthorized: true,
					}
				: undefined,
		});

		this.client.on("error", (err) => {
			logger.error("Redis Client Error:", err);
		});

		this.client.on("connect", () => {
			this.isConnected = true;
			logger.info("Redis Client Connected");
		});

		this.client.on("disconnect", () => {
			this.isConnected = false;
			logger.warn("Redis Client Disconnected");
		});
	}

	public static getInstance(): RedisClient {
		if (!RedisClient.instance) {
			RedisClient.instance = new RedisClient();
		}
		return RedisClient.instance;
	}

	public async connect(): Promise<void> {
		if (!this.isConnected) {
			await this.client.connect();
		}
	}

	public async disconnect(): Promise<void> {
		if (this.isConnected) {
			await this.client.disconnect();
		}
	}

	private async ensureConnection(): Promise<void> {
		if (!this.isConnected) {
			await this.connect();
		}
	}

	public getClient(): RedisClientType {
		return this.client;
	}

	// Cache helpers
	public async get(key: string): Promise<string | null> {
		try {
			await this.ensureConnection();
			return await this.client.get(key);
		} catch (error) {
			logger.error(`Redis GET error for key ${key}:`, error);
			return null;
		}
	}

	public async set(
		key: string,
		value: string,
		expirationInSeconds?: number,
	): Promise<void> {
		try {
			await this.ensureConnection();
			if (expirationInSeconds) {
				await this.client.setEx(key, expirationInSeconds, value);
			} else {
				await this.client.set(key, value);
			}
		} catch (error) {
			logger.error(`Redis SET error for key ${key}:`, error);
		}
	}

	public async del(key: string): Promise<void> {
		try {
			await this.ensureConnection();
			await this.client.del(key);
		} catch (error) {
			logger.error(`Redis DEL error for key ${key}:`, error);
		}
	}

	public async exists(key: string): Promise<boolean> {
		try {
			await this.ensureConnection();
			const result = await this.client.exists(key);
			return result === 1;
		} catch (error) {
			logger.error(`Redis EXISTS error for key ${key}:`, error);
			return false;
		}
	}

	public async setJSON(
		key: string,
		value: any,
		expirationInSeconds?: number,
	): Promise<void> {
		try {
			const jsonString = JSON.stringify(value);
			await this.set(key, jsonString, expirationInSeconds);
		} catch (error) {
			logger.error(`Redis setJSON error for key ${key}:`, error);
		}
	}

	public async getJSON<T>(key: string): Promise<T | null> {
		try {
			const value = await this.get(key);
			if (!value) return null;
			return JSON.parse(value) as T;
		} catch (error) {
			logger.error(`Redis getJSON error for key ${key}:`, error);
			return null;
		}
	}
}

// Export singleton instance
const redisClient = RedisClient.getInstance();
export { redisClient };
