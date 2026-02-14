// Support Info Service

import { SupportRepository } from "./support.repo";
import { UpdateSupportInfoDto } from "./support.types";

export class SupportService {
	private repo: SupportRepository;

	constructor() {
		this.repo = new SupportRepository();
	}

	/**
	 * Get support info
	 */
	async getSupportInfo() {
		return await this.repo.getSupportInfo();
	}

	/**
	 * Update support info (admin only)
	 */
	async updateSupportInfo(data: UpdateSupportInfoDto) {
		return await this.repo.updateSupportInfo(data);
	}
}
