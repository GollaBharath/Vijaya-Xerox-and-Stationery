/**
 * User Profile Module Type Definitions
 */

export interface UserProfile {
	id: string;
	name: string;
	phone: string | null;
	email: string;
	address: string | null;
	city: string | null;
	state: string | null;
	pincode: string | null;
	landmark: string | null;
	createdAt: string;
	updatedAt: string;
}

export interface UpdateProfileRequest {
	name?: string;
	phone?: string;
	address?: string;
	city?: string;
	state?: string;
	pincode?: string;
	landmark?: string;
}

export interface ProfileResponse {
	user: UserProfile;
}
