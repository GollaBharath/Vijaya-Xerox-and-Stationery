/**
 * User Profile Service
 */

import { NotFoundError } from "@/middleware/error.middleware";
import { getUserProfile, updateUserProfile } from "./profile.repo";
import {
	UserProfile,
	UpdateProfileRequest,
	ProfileResponse,
} from "./profile.types";

/**
 * Get user profile
 */
export async function getProfile(userId: string): Promise<ProfileResponse> {
	const user = await getUserProfile(userId);
	if (!user) throw new NotFoundError("User");
	return { user };
}

/**
 * Update user profile
 */
export async function updateProfile(
	userId: string,
	data: UpdateProfileRequest,
): Promise<ProfileResponse> {
	const user = await updateUserProfile(userId, data);
	return { user };
}

/**
 * Check if user has complete address information
 */
export function hasCompleteAddress(user: UserProfile): boolean {
	return !!(user.address && user.city && user.state && user.pincode);
}

/**
 * Get address snapshot from user profile
 */
export function getUserAddressSnapshot(
	user: UserProfile,
): Record<string, unknown> | null {
	if (!hasCompleteAddress(user)) return null;

	return {
		name: user.name,
		phone: user.phone || "",
		address: user.address,
		city: user.city,
		state: user.state,
		pincode: user.pincode,
		landmark: user.landmark || "",
	};
}
