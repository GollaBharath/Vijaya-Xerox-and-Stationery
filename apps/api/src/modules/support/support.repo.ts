// Support Info Repository

import { prisma } from "../../lib/prisma";
import { UpdateSupportInfoDto } from "./support.types";

export class SupportRepository {
	/**
	 * Get support info (returns first record or creates one if none exists)
	 */
	async getSupportInfo() {
		let supportInfo = await prisma.supportInfo.findFirst();

		// If no record exists, create a default one
		if (!supportInfo) {
			supportInfo = await prisma.supportInfo.create({
				data: {
					shopName: "Vijaya Xerox & Stationery",
					shopPhone: null,
					shopEmail: null,
					shopWhatsapp: null,
					shopAddress: null,
					developerName: null,
					developerEmail: null,
					developerWhatsapp: null,
					workingHours: null,
					websiteUrl: null,
				},
			});
		}

		return supportInfo;
	}

	/**
	 * Update support info (updates first record or creates one if none exists)
	 */
	async updateSupportInfo(data: UpdateSupportInfoDto) {
		const existing = await prisma.supportInfo.findFirst();

		if (existing) {
			return await prisma.supportInfo.update({
				where: { id: existing.id },
				data,
			});
		}

		// Create new record if none exists
		return await prisma.supportInfo.create({
			data: data as any,
		});
	}
}
