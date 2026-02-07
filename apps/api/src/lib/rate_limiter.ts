/**
 * Rate Limiter using Redis
 *
 * Implements token bucket algorithm for rate limiting
 */

import { redisClient } from "./redis";
import { logger } from "./logger";

interface RateLimitConfig {
	maxRequests: number; // Max requests per window
	windowMs: number; // Time window in milliseconds
	keyPrefix?: string; // Optional prefix for Redis keys
}

interface RateLimitResult {
	allowed: boolean;
	remaining: number;
	resetAt: Date;
}

export class RateLimiter {
	private config: RateLimitConfig;

	constructor(config: RateLimitConfig) {
		this.config = {
			keyPrefix: "rate_limit",
			...config,
		};
	}

	/**
	 * Check if a request is allowed for a given identifier (e.g., IP, user ID)
	 */
	public async checkLimit(identifier: string): Promise<RateLimitResult> {
		const key = `${this.config.keyPrefix}:${identifier}`;
		const now = Date.now();

		try {
			// Get current count
			const currentCountStr = await redisClient.get(key);
			const currentCount = currentCountStr ? parseInt(currentCountStr, 10) : 0;

			if (currentCount >= this.config.maxRequests) {
				// Rate limit exceeded
				const ttl = await redisClient.getClient().ttl(key);
				const resetAt = new Date(now + ttl * 1000);

				return {
					allowed: false,
					remaining: 0,
					resetAt,
				};
			}

			// Increment counter
			const newCount = await this.incrementCounter(key);
			const remaining = Math.max(0, this.config.maxRequests - newCount);
			const resetAt = new Date(now + this.config.windowMs);

			return {
				allowed: true,
				remaining,
				resetAt,
			};
		} catch (error) {
			logger.error("Rate limiter error:", error);
			// On error, allow the request (fail open)
			return {
				allowed: true,
				remaining: this.config.maxRequests,
				resetAt: new Date(now + this.config.windowMs),
			};
		}
	}

	private async incrementCounter(key: string): Promise<number> {
		const client = redisClient.getClient();
		const count = await client.incr(key);

		// Set expiration on first increment
		if (count === 1) {
			await client.expire(key, Math.ceil(this.config.windowMs / 1000));
		}

		return count;
	}

	/**
	 * Reset rate limit for a specific identifier
	 */
	public async reset(identifier: string): Promise<void> {
		const key = `${this.config.keyPrefix}:${identifier}`;
		await redisClient.del(key);
	}
}

// Pre-configured rate limiters
export const authRateLimiter = new RateLimiter({
	maxRequests: 5,
	windowMs: 15 * 60 * 1000, // 15 minutes
	keyPrefix: "rate_limit:auth",
});

export const apiRateLimiter = new RateLimiter({
	maxRequests: 100,
	windowMs: 60 * 1000, // 1 minute
	keyPrefix: "rate_limit:api",
});
