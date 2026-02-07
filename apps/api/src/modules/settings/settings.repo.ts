/**
 * Settings Repository
 */

import { prisma } from "@/lib/prisma";
import { StoreSetting } from "./settings.types";
import { Prisma } from "@prisma/client";

function toSetting(entity: any): StoreSetting {
	return {
		id: entity.id,
		key: entity.key,
		valueJson: entity.valueJson ?? null,
		createdAt: entity.createdAt.toISOString(),
		updatedAt: entity.updatedAt.toISOString(),
	};
}

export async function getSetting(key: string): Promise<StoreSetting | null> {
	const setting = await prisma.storeSetting.findUnique({
		where: { key },
	});
	return setting ? toSetting(setting) : null;
}

export async function getAllSettings(): Promise<StoreSetting[]> {
	const settings = await prisma.storeSetting.findMany({
		orderBy: { createdAt: "desc" },
	});
	return settings.map(toSetting);
}

export async function setSetting(
	key: string,
	valueJson: Record<string, unknown> | null,
): Promise<StoreSetting> {
	const setting = await prisma.storeSetting.upsert({
		where: { key },
		update: {
			valueJson:
				valueJson === null
					? Prisma.JsonNull
					: (valueJson as Prisma.InputJsonValue),
		},
		create: {
			key,
			valueJson:
				valueJson === null
					? Prisma.JsonNull
					: (valueJson as Prisma.InputJsonValue),
		},
	});

	return toSetting(setting);
}

export async function deleteSetting(key: string): Promise<void> {
	await prisma.storeSetting.delete({
		where: { key },
	});
}
