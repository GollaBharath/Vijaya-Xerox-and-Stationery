export interface ProductLikeResponse {
	id: string;
	userId: string;
	productId: string;
	createdAt: string;
}

export interface ProductLikeStats {
	productId: string;
	likeCount: number;
	isLikedByUser: boolean;
}
