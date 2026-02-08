/**
 * Auth Service
 *
 * Business logic for authentication
 */

import jwt, { type Secret, type SignOptions } from "jsonwebtoken";
import { env } from "@/lib/env";
import { logger } from "@/lib/logger";
import { verifyFirebaseToken } from "@/lib/firebase-admin";
import { UserRole, JWTPayload, ErrorCode } from "@/types/global";
import { hashPassword, comparePassword } from "@/utils/helpers";
import { AppError, UnauthorizedError } from "@/middleware/error.middleware";
import {
	RegisterRequest,
	LoginRequest,
	RegisterResponse,
	LoginResponse,
	UserResponse,
	AuthTokens,
} from "./auth.types";
import {
	findUserByEmail,
	findUserById,
	createUser,
	userExistsByEmail,
	userExistsByPhone,
} from "./auth.repo";

/**
 * Convert database user to response format
 */
function toUserResponse(user: {
	id: string;
	name: string;
	email: string;
	phone: string | null;
	role: UserRole;
	isActive: boolean;
	createdAt: Date;
}): UserResponse {
	return {
		id: user.id,
		name: user.name,
		email: user.email,
		phone: user.phone || "",
		role: user.role,
		isActive: user.isActive,
		createdAt: user.createdAt.toISOString(),
	};
}

/**
 * Generate JWT tokens (access + refresh)
 *//**
 * Generate JWT tokens (access + refresh)
 */
export function generateTokens(userId: string, role: UserRole): AuthTokens {
	const payload: JWTPayload = { userId, role };

	const accessToken = jwt.sign(payload, env.JWT_SECRET as Secret, {
		expiresIn: env.JWT_EXPIRES_IN as SignOptions["expiresIn"],
	});

	const refreshToken = jwt.sign(payload, env.JWT_REFRESH_SECRET as Secret, {
		expiresIn: env.JWT_REFRESH_EXPIRES_IN as SignOptions["expiresIn"],
	});

	return {
		accessToken,
		refreshToken,
		expiresIn: env.JWT_EXPIRES_IN,
	};
}

/**
 * Verify access token
 */
export function verifyToken(token: string): JWTPayload {
	try {
		const decoded = jwt.verify(token, env.JWT_SECRET) as JWTPayload;
		return decoded;
	} catch (error) {
		if (error instanceof jwt.TokenExpiredError) {
			throw new AppError(ErrorCode.TOKEN_EXPIRED, "Token has expired", 401);
		}
		if (error instanceof jwt.JsonWebTokenError) {
			throw new AppError(ErrorCode.TOKEN_INVALID, "Invalid token", 401);
		}
		logger.error("Token verification error:", error);
		throw new AppError(
			ErrorCode.TOKEN_INVALID,
			"Token verification failed",
			401,
		);
	}
}

/**
 * Verify refresh token
 */
export function verifyRefreshToken(token: string): JWTPayload {
	try {
		const decoded = jwt.verify(token, env.JWT_REFRESH_SECRET) as JWTPayload;
		return decoded;
	} catch (error) {
		if (error instanceof jwt.TokenExpiredError) {
			throw new AppError(
				ErrorCode.TOKEN_EXPIRED,
				"Refresh token has expired. Please login again.",
				401,
			);
		}
		if (error instanceof jwt.JsonWebTokenError) {
			throw new AppError(ErrorCode.TOKEN_INVALID, "Invalid refresh token", 401);
		}
		logger.error("Refresh token verification error:", error);
		throw new AppError(
			ErrorCode.TOKEN_INVALID,
			"Refresh token verification failed",
			401,
		);
	}
}

/**
 * Register a new user
 */
export async function register(
	data: RegisterRequest,
): Promise<RegisterResponse> {
	const { name, email, phone, password } = data;

	// Check if user already exists
	const [emailExists, phoneExists] = await Promise.all([
		userExistsByEmail(email),
		userExistsByPhone(phone),
	]);

	if (emailExists) {
		throw new AppError(
			ErrorCode.USER_ALREADY_EXISTS,
			"A user with this email already exists",
			409,
		);
	}

	if (phoneExists) {
		throw new AppError(
			ErrorCode.USER_ALREADY_EXISTS,
			"A user with this phone number already exists",
			409,
		);
	}

	// Hash password
	const passwordHash = await hashPassword(password);

	// Create user
	const user = await createUser({
		name,
		email,
		phone,
		passwordHash,
		role: "CUSTOMER", // Default role for registration
	});

	logger.info("New user registered", { userId: user.id, email: user.email });

	// Generate tokens
	const tokens = generateTokens(user.id, user.role);

	return {
		user: toUserResponse(user),
		tokens,
	};
}

/**
 * Login user
 */
export async function login(data: LoginRequest): Promise<LoginResponse> {
	const { email, password } = data;

	// Find user
	const user = await findUserByEmail(email);

	if (!user) {
		throw new UnauthorizedError("Invalid email or password");
	}

	// Check if user is active
	if (!user.isActive) {
		throw new AppError(
			ErrorCode.FORBIDDEN,
			"Your account has been deactivated. Please contact support.",
			403,
		);
	}

	// Check if user has a password
	if (!user.passwordHash) {
		throw new AppError(
			ErrorCode.INVALID_CREDENTIALS,
			"This account has no password set. Please reset your password.",
			401,
		);
	}

	// Verify password
	const isPasswordValid = await comparePassword(password, user.passwordHash);

	if (!isPasswordValid) {
		throw new UnauthorizedError("Invalid email or password");
	}

	logger.info("User logged in", { userId: user.id, email: user.email });

	// Generate tokens
	const tokens = generateTokens(user.id, user.role);

	return {
		user: toUserResponse(user),
		tokens,
	};
}

/**
 * Refresh access token
 */
export async function refreshAccessToken(
	refreshToken: string,
): Promise<AuthTokens> {
	// Verify refresh token
	const payload = verifyRefreshToken(refreshToken);

	// Verify user still exists and is active
	const user = await findUserById(payload.userId);

	if (!user) {
		throw new AppError(ErrorCode.USER_NOT_FOUND, "User not found", 404);
	}

	if (!user.isActive) {
		throw new AppError(
			ErrorCode.FORBIDDEN,
			"Your account has been deactivated",
			403,
		);
	}

	// Generate new tokens
	const tokens = generateTokens(user.id, user.role);

	logger.info("Access token refreshed", { userId: user.id });

	return tokens;
}

/**
 * Get current user by ID
 */
export async function getCurrentUser(userId: string): Promise<UserResponse> {
	const user = await findUserById(userId);

	if (!user) {
		throw new AppError(ErrorCode.USER_NOT_FOUND, "User not found", 404);
	}

	if (!user.isActive) {
		throw new AppError(
			ErrorCode.FORBIDDEN,
			"Your account has been deactivated",
			403,
		);
	}

	return toUserResponse(user);
}

/**
 * Firebase Login - Creates user if doesn't exist
 */
export async function firebaseLogin(idToken: string): Promise<LoginResponse> {
	try {
		// Verify Firebase token
		const decodedToken = await verifyFirebaseToken(idToken);

		const email = decodedToken.email;
		const name =
			decodedToken.name || decodedToken.email?.split("@")[0] || "User";
		const firebaseUid = decodedToken.uid;

		if (!email) {
			throw new UnauthorizedError("Email not found in Firebase token");
		}

		// Check if user exists
		let user = await findUserByEmail(email);

		if (!user) {
			// Create new user
			user = await createUser({
				name,
				email,
				phone: "", // Empty string instead of null
				passwordHash: null, // Firebase users don't have password
				role: "CUSTOMER",
			});

			logger.info("New user created via Firebase", {
				userId: user.id,
				email: user.email,
				firebaseUid,
			});
		} else {
			// Check if user is active
			if (!user.isActive) {
				throw new AppError(
					ErrorCode.FORBIDDEN,
					"Your account has been deactivated. Please contact support.",
					403,
				);
			}

			logger.info("Existing user logged in via Firebase", {
				userId: user.id,
				email: user.email,
			});
		}

		// Generate JWT tokens
		const tokens = generateTokens(user.id, user.role);

		return {
			user: toUserResponse(user),
			tokens,
		};
	} catch (error) {
		if (error instanceof AppError) {
			throw error;
		}
		logger.error("Firebase login error", { error });
		throw new UnauthorizedError("Invalid Firebase token");
	}
}
