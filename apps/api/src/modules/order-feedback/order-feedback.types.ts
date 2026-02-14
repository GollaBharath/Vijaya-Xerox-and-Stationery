export interface CreateFeedbackDto {
	rating: number; // 1-5
	comment?: string;
}

export interface FeedbackResponse {
	id: string;
	orderId: string;
	userId: string;
	userName: string;
	rating: number;
	comment: string | null;
	createdAt: string;
	updatedAt: string;
	order?: {
		id: string;
		totalPrice: number;
		itemCount: number;
		createdAt: string;
	};
}

export interface FeedbackListResponse {
	feedbacks: FeedbackResponse[];
	pagination: {
		page: number;
		limit: number;
		total: number;
		pages: number;
	};
}
