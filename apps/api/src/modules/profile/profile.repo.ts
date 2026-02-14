/**
 * User Profile Repository
 */

import { prisma } from "@/lib/prisma";
import { UserProfile, UpdateProfileRequest } from "./profile.types";

/**
 * Get user profile by ID
 */
export async function getUserProfile(
	userId: string,
): Promise<UserProfile | null> {
	const user = await prisma.user.findUnique({
		where: { id: userId },
		select: {
			id: true,
			name: true,
			phone: true,
			email: true,
			address: true,
			city: true,
			state: true,
			pincode: true,
			landmark: true,
			createdAt: true,
			updatedAt: true,
		},
	});

	if (!user) return null;

	return {
		...user,
		createdAt: user.createdAt.toISOString(),
		updatedAt: user.updatedAt.toISOString(),
	};
}

/**
 * Update user profile
 */
export async function updateUserProfile(
	userId: string,
	data: UpdateProfileRequest,
): Promise<UserProfile> {
	const user = await prisma.user.update({
		where: { id: userId },
		data: {
			...(data.name !== undefined && { name: data.name }),
			...(data.phone !== undefined && { phone: data.phone }),
			...(data.address !== undefined && { address: data.address }),
			...(data.city !== undefined && { city: data.city }),
			...(data.state !== undefined && { state: data.state }),
			...(data.pincode !== undefined && { pincode: data.pincode }),
			...(data.landmark !== undefined && { landmark: data.landmark }),
		},
		select: {
			id: true,
			name: true,
			phone: true,
			email: true,
			address: true,
			city: true,
			state: true,
			pincode: true,
			landmark: true,
			createdAt: true,
			updatedAt: true,
		},
	});

	return {
		...user,
		createdAt: user.createdAt.toISOString(),
		updatedAt: user.updatedAt.toISOString(),
	};
}
