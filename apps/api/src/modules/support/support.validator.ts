// Support Info Validator

import { z } from "zod";

export const updateSupportInfoSchema = z.object({
	shopName: z.string().optional().nullable(),
	shopPhone: z.string().optional().nullable(),
	shopEmail: z
		.union([z.string().email(), z.literal("")])
		.optional()
		.nullable(),
	shopWhatsapp: z.string().optional().nullable(),
	shopAddress: z.string().optional().nullable(),
	developerName: z.string().optional().nullable(),
	developerEmail: z
		.union([z.string().email(), z.literal("")])
		.optional()
		.nullable(),
	developerWhatsapp: z.string().optional().nullable(),
	workingHours: z.string().optional().nullable(),
	websiteUrl: z
		.union([z.string().url(), z.literal("")])
		.optional()
		.nullable(),
});

export type UpdateSupportInfoInput = z.infer<typeof updateSupportInfoSchema>;
