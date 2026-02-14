import { NotFoundError } from "@/middleware/error.middleware";
import * as repo from "./product-likes.repo";
import { prisma } from "@/lib/prisma";

export async function toggleProductLike(userId: string, productId: string) {
	// Verify product exists
	const product = await prisma.product.findUnique({
		where: { id: productId },
	});

	if (!product) {
		throw new NotFoundError("Product not found");
	}

	// Check if already liked
	const hasLiked = await repo.hasUserLikedProduct(userId, productId);

	if (hasLiked) {
		// Remove like
		await repo.removeProductLike(userId, productId);
		const newCount = await repo.getProductLikeCount(productId);
		return { liked: false, likeCount: newCount };
	} else {
		// Add like
		await repo.addProductLike(userId, productId);
		const newCount = await repo.getProductLikeCount(productId);
		return { liked: true, likeCount: newCount };
	}
}

export async function getProductLikeStats(productId: string, userId?: string) {
	const count = await repo.getProductLikeCount(productId);
	const isLiked = userId
		? await repo.hasUserLikedProduct(userId, productId)
		: false;

	return {
		productId,
		likeCount: count,
		isLikedByUser: isLiked,
	};
}

export async function getUserLikes(userId: string) {
	const likes = await repo.getUserLikedProducts(userId);

	// Get like counts for all liked products
	const productIds = likes.map((l) => l.product.id);
	const likeCounts = new Map<string, number>();

	for (const productId of productIds) {
		const count = await repo.getProductLikeCount(productId);
		likeCounts.set(productId, count);
	}

	return likes.map((like) => ({
		id: like.id,
		createdAt: like.createdAt.toISOString(),
		product: {
			...like.product,
			likeCount: likeCounts.get(like.product.id) || 0,
		},
	}));
}
