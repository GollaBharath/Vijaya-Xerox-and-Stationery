// Support Info Types

export interface SupportInfo {
	id: string;
	shopName: string | null;
	shopPhone: string | null;
	shopEmail: string | null;
	shopWhatsapp: string | null;
	shopAddress: string | null;
	developerName: string | null;
	developerEmail: string | null;
	developerWhatsapp: string | null;
	workingHours: string | null;
	websiteUrl: string | null;
	createdAt: Date;
	updatedAt: Date;
}

export interface UpdateSupportInfoDto {
	shopName?: string | null;
	shopPhone?: string | null;
	shopEmail?: string | null;
	shopWhatsapp?: string | null;
	shopAddress?: string | null;
	developerName?: string | null;
	developerEmail?: string | null;
	developerWhatsapp?: string | null;
	workingHours?: string | null;
	websiteUrl?: string | null;
}
