/**
 * Auth Repository
 *
 * Database operations for authentication
 */

import { prisma } from "@/lib/prisma";
import { UserRole } from "@/types/global";
import { CreateUserData, UserWithPassword } from "./auth.types";

/**
 * Find user by email
 */
export async function findUserByEmail(
	email: string,
): Promise<UserWithPassword | null> {
	const user = await prisma.user.findUnique({
		where: { email },
	});

	if (!user) {
		return null;
	}

	return {
		id: user.id,
		name: user.name,
		email: user.email,
		phone: user.phone,
		passwordHash: user.passwordHash,
		role: user.role as UserRole,
		isActive: user.isActive,
		createdAt: user.createdAt,
		updatedAt: user.updatedAt,
	};
}

/**
 * Find user by ID
 */
export async function findUserById(
	id: string,
): Promise<UserWithPassword | null> {
	const user = await prisma.user.findUnique({
		where: { id },
	});

	if (!user) {
		return null;
	}

	return {
		id: user.id,
		name: user.name,
		email: user.email,
		phone: user.phone,
		passwordHash: user.passwordHash,
		role: user.role as UserRole,
		isActive: user.isActive,
		createdAt: user.createdAt,
		updatedAt: user.updatedAt,
	};
}

/**
 * Find user by phone
 */
export async function findUserByPhone(
	phone: string,
): Promise<UserWithPassword | null> {
	const user = await prisma.user.findUnique({
		where: { phone },
	});

	if (!user) {
		return null;
	}

	return {
		id: user.id,
		name: user.name,
		email: user.email,
		phone: user.phone,
		passwordHash: user.passwordHash,
		role: user.role as UserRole,
		isActive: user.isActive,
		createdAt: user.createdAt,
		updatedAt: user.updatedAt,
	};
}

/**
 * Create a new user
 */
export async function createUser(
	data: CreateUserData,
): Promise<UserWithPassword> {
	const user = await prisma.user.create({
		data: {
			name: data.name,
			email: data.email,
			phone: data.phone,
			passwordHash: data.passwordHash,
			role: data.role,
		},
	});

	return {
		id: user.id,
		name: user.name,
		email: user.email,
		phone: user.phone,
		passwordHash: user.passwordHash,
		role: user.role as UserRole,
		isActive: user.isActive,
		createdAt: user.createdAt,
		updatedAt: user.updatedAt,
	};
}

/**
 * Update user password
 */
export async function updatePassword(
	userId: string,
	newHash: string,
): Promise<void> {
	await prisma.user.update({
		where: { id: userId },
		data: { passwordHash: newHash },
	});
}

/**
 * Check if user exists by email
 */
export async function userExistsByEmail(email: string): Promise<boolean> {
	const count = await prisma.user.count({
		where: { email },
	});
	return count > 0;
}

/**
 * Check if user exists by phone
 */
export async function userExistsByPhone(phone: string): Promise<boolean> {
	const count = await prisma.user.count({
		where: { phone },
	});
	return count > 0;
}
