/**
 * Settings Module Type Definitions
 */

export interface StoreSetting {
	id: string;
	key: string;
	valueJson: Record<string, unknown> | null;
	createdAt: string;
	updatedAt: string;
}

export interface SetSettingInput {
	key: string;
	valueJson: Record<string, unknown> | null;
}
