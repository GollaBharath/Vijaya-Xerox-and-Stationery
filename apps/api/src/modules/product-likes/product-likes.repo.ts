import { prisma } from "@/lib/prisma";

/**
 * Add a like to a product
 */
export async function addProductLike(userId: string, productId: string) {
	return await prisma.productLike.create({
		data: {
			userId,
			productId,
		},
	});
}

/**
 * Remove a like from a product
 */
export async function removeProductLike(userId: string, productId: string) {
	return await prisma.productLike.deleteMany({
		where: {
			userId,
			productId,
		},
	});
}

/**
 * Check if user has liked a product
 */
export async function hasUserLikedProduct(
	userId: string,
	productId: string,
): Promise<boolean> {
	const like = await prisma.productLike.findFirst({
		where: { userId, productId },
	});
	return like !== null;
}

/**
 * Get like count for a product
 */
export async function getProductLikeCount(productId: string): Promise<number> {
	return await prisma.productLike.count({
		where: { productId },
	});
}

/**
 * Get all products liked by a user
 */
export async function getUserLikedProducts(userId: string) {
	return await prisma.productLike.findMany({
		where: { userId },
		include: {
			product: {
				include: {
					subject: true,
					variants: true,
				},
			},
		},
		orderBy: { createdAt: "desc" },
	});
}

/**
 * Get like stats for multiple products
 */
export async function getProductLikeStats(
	productIds: string[],
	userId?: string,
): Promise<Map<string, { count: number; isLiked: boolean }>> {
	// Get counts for all products
	const likeCounts = await prisma.productLike.groupBy({
		by: ["productId"],
		where: {
			productId: { in: productIds },
		},
		_count: { id: true },
	});

	// Get user's likes if userId provided
	let userLikes: string[] = [];
	if (userId) {
		const likes = await prisma.productLike.findMany({
			where: {
				userId,
				productId: { in: productIds },
			},
			select: { productId: true },
		});
		userLikes = likes.map((l) => l.productId);
	}

	// Build stats map
	const statsMap = new Map<string, { count: number; isLiked: boolean }>();

	// Initialize all products with 0 likes
	productIds.forEach((id) => {
		statsMap.set(id, { count: 0, isLiked: false });
	});

	// Update with actual counts
	likeCounts.forEach((item) => {
		statsMap.set(item.productId, {
			count: item._count.id,
			isLiked: userLikes.includes(item.productId),
		});
	});

	// Update liked status
	userLikes.forEach((productId) => {
		const stats = statsMap.get(productId);
		if (stats) {
			stats.isLiked = true;
		}
	});

	return statsMap;
}
