/**
 * Auth Module Type Definitions
 */

import { UserRole } from "@/types/global";

// ============================================
// Request Types
// ============================================

export interface RegisterRequest {
	name: string;
	email: string;
	phone: string;
	password: string;
}

export interface LoginRequest {
	email: string;
	password: string;
}

export interface RefreshTokenRequest {
	refreshToken: string;
}

// ============================================
// Response Types
// ============================================

export interface AuthTokens {
	accessToken: string;
	refreshToken: string;
	expiresIn: string;
}

export interface UserResponse {
	id: string;
	name: string;
	email: string;
	phone: string;
	role: UserRole;
	isActive: boolean;
	createdAt: string;
}

export interface RegisterResponse {
	user: UserResponse;
	tokens: AuthTokens;
}

export interface LoginResponse {
	user: UserResponse;
	tokens: AuthTokens;
}

export interface RefreshTokenResponse {
	accessToken: string;
	expiresIn: string;
}

// ============================================
// Internal Types
// ============================================

export interface CreateUserData {
	name: string;
	email: string;
	phone: string | null;
	passwordHash: string | null;
	role: UserRole;
}

export interface UserWithPassword {
	id: string;
	name: string;
	email: string;
	phone: string | null;
	passwordHash: string | null;
	role: UserRole;
	isActive: boolean;
	createdAt: Date;
	updatedAt: Date;
}
