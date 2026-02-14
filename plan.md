# Implementation Plan: Product Likes & Order Feedback Features

## Overview

This document outlines a detailed implementation plan for adding two community engagement features:

1. **Product Likes** - Allow users to like products and display like counts ✅ **COMPLETED**
2. **Order Feedback** - Enable customers to submit feedback after receiving products and display feedback in admin dashboard

## Status

- ✅ **Phase 1: Product Likes Backend** - COMPLETED
- ✅ **Phase 2: Product Likes Frontend (Customer App)** - COMPLETED
- ✅ **Phase 3: Order Feedback Backend** - COMPLETED
- ✅ **Phase 4: Order Feedback Frontend (Customer)** - COMPLETED
- ✅ **Phase 5: Order Feedback Frontend (Admin)** - COMPLETED
- ⏳ **Phase 6: Testing & Polish** - TODO

---

## Feature 1: Product Likes System ✅

### Goals ✅

- ✅ Replace the placeholder wishlist functionality with a product like system
- ✅ Store product likes per user in the database
- ✅ Display heart-shaped like button with count on product cards and detail pages
- ✅ Show like count next to products (❤️ icon + number)

### Database Changes

#### Create New Table: `ProductLike`

**File**: `apps/api/prisma/schema.prisma`

Add after the `CartItem` model:

```prisma
// ================================
// Product Like Model
// ================================
model ProductLike {
  id         String     @id @default(cuid())
  userId     String     @map("user_id")
  productId  String     @map("product_id")
  createdAt  DateTime   @default(now()) @map("created_at")

  // Relations
  user       User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  product    Product    @relation(fields: [productId], references: [id], onDelete: Cascade)

  @@unique([userId, productId])
  @@map("product_likes")
}
```

**Update `User` model** - Add relation:

```prisma
model User {
  // ... existing fields
  likes         ProductLike[]
}
```

**Update `Product` model** - Add relation and computed like count:

```prisma
model Product {
  // ... existing fields
  likes         ProductLike[]
}
```

**Migration Steps**:

1. Run: `cd apps/api && npx prisma migrate dev --name add_product_likes`
2. Generate Prisma client: `npx prisma generate`

---

### Backend API Implementation

#### 1. Create Product Likes Module

**Directory**: `apps/api/src/modules/product-likes/`

**Files to create**:

##### `product-likes.types.ts`

```typescript
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
```

##### `product-likes.repo.ts`

```typescript
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
```

##### `product-likes.service.ts`

```typescript
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
	return likes.map((like) => ({
		id: like.id,
		createdAt: like.createdAt.toISOString(),
		product: like.product,
	}));
}
```

#### 2. Create API Routes

##### Customer Route: Toggle Like

**File**: `apps/api/src/app/api/v1/products/[id]/like/route.ts`

```typescript
import { NextRequest, NextResponse } from "next/server";
import { authenticate } from "@/middleware/auth.middleware";
import {
	toggleProductLike,
	getProductLikeStats,
} from "@/modules/product-likes/product-likes.service";
import { handleError } from "@/middleware/error.middleware";

/**
 * GET /api/v1/products/:id/like
 * Get like stats for a product
 */
export async function GET(
	req: NextRequest,
	{ params }: { params: { id: string } },
) {
	try {
		const user = await authenticate(req, { required: false });
		const stats = await getProductLikeStats(params.id, user?.id);

		return NextResponse.json({ data: stats });
	} catch (error: any) {
		return handleError(error);
	}
}

/**
 * POST /api/v1/products/:id/like
 * Toggle like on a product (add or remove)
 */
export async function POST(
	req: NextRequest,
	{ params }: { params: { id: string } },
) {
	try {
		const user = await authenticate(req, { required: true });
		const result = await toggleProductLike(user!.id, params.id);

		return NextResponse.json({
			data: result,
			message: result.liked ? "Product liked" : "Like removed",
		});
	} catch (error: any) {
		return handleError(error);
	}
}
```

##### Customer Route: Get User's Liked Products

**File**: `apps/api/src/app/api/v1/me/likes/route.ts`

```typescript
import { NextRequest, NextResponse } from "next/server";
import { authenticate } from "@/middleware/auth.middleware";
import { getUserLikes } from "@/modules/product-likes/product-likes.service";
import { handleError } from "@/middleware/error.middleware";

/**
 * GET /api/v1/me/likes
 * Get all products liked by current user
 */
export async function GET(req: NextRequest) {
	try {
		const user = await authenticate(req, { required: true });
		const likes = await getUserLikes(user!.id);

		return NextResponse.json({ data: likes });
	} catch (error: any) {
		return handleError(error);
	}
}
```

#### 3. Update Product Endpoints

**Modify**: `apps/api/src/modules/catalog/catalog.service.ts`

Update the `getProducts` and `getProductById` functions to include like stats:

```typescript
// Import the repo
import * as likeRepo from "@/modules/product-likes/product-likes.repo";

// In getProducts function, after fetching products:
const productIds = products.map((p) => p.id);
const likeStats = await likeRepo.getProductLikeStats(productIds, userId);

// Add like stats to each product in response
const productsWithLikes = products.map((product) => {
	const stats = likeStats.get(product.id) || { count: 0, isLiked: false };
	return {
		...product,
		likeCount: stats.count,
		isLikedByUser: stats.isLiked,
	};
});

// In getProductById function:
const likeStats = await likeRepo.getProductLikeStats([productId], userId);
const stats = likeStats.get(productId) || { count: 0, isLiked: false };

return {
	...product,
	likeCount: stats.count,
	isLikedByUser: stats.isLiked,
};
```

---

### Shared Models (Flutter)

**File**: `packages/flutter_shared/lib/models/product.dart`

Add like fields to Product model:

```dart
class Product {
  // ... existing fields
  final int likeCount;
  final bool isLikedByUser;

  Product({
    // ... existing parameters
    this.likeCount = 0,
    this.isLikedByUser = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // ... existing fields
      likeCount: json['likeCount'] ?? 0,
      isLikedByUser: json['isLikedByUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ... existing fields
      'likeCount': likeCount,
      'isLikedByUser': isLikedByUser,
    };
  }
}
```

**File**: `packages/flutter_shared/lib/models/product_like.dart` (NEW)

```dart
class ProductLike {
  final String id;
  final String userId;
  final String productId;
  final DateTime createdAt;
  final Product? product;

  ProductLike({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
    this.product,
  });

  factory ProductLike.fromJson(Map<String, dynamic> json) {
    return ProductLike(
      id: json['id'],
      userId: json['userId'],
      productId: json['productId'],
      createdAt: DateTime.parse(json['createdAt']),
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'createdAt': createdAt.toIso8601String(),
      if (product != null) 'product': product!.toJson(),
    };
  }
}
```

Export in `packages/flutter_shared/lib/flutter_shared.dart`:

```dart
export 'models/product_like.dart';
```

---

### Customer App Frontend Implementation

#### 1. Create Likes Provider

**File**: `apps/customer_app/lib/features/likes/providers/likes_provider.dart` (NEW)

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';

class LikesProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<ProductLike> _likedProducts = [];
  bool _isLoading = false;
  String? _error;

  LikesProvider(this._apiClient);

  List<ProductLike> get likedProducts => _likedProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLikes => _likedProducts.isNotEmpty;

  /// Fetch user's liked products
  Future<void> fetchLikedProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/me/likes');
      if (response['data'] != null) {
        _likedProducts = (response['data'] as List)
            .map((json) => ProductLike.fromJson(json))
            .toList();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _likedProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle like on a product
  Future<bool> toggleLike(String productId) async {
    try {
      final response = await _apiClient.post('/products/$productId/like');

      // Update local cache
      await fetchLikedProducts();

      return response['data']['liked'] == true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Check if product is liked
  bool isProductLiked(String productId) {
    return _likedProducts.any((like) => like.productId == productId);
  }

  /// Clear all data
  void clear() {
    _likedProducts = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
```

#### 2. Update Product Card Widget

**File**: `apps/customer_app/lib/features/catalog/widgets/product_card.dart`

Replace the `_buildWishlistButton` method:

```dart
Widget _buildWishlistButton(BuildContext context) {
  return Consumer<LikesProvider>(
    builder: (context, likesProvider, child) {
      final isLiked = product.isLikedByUser;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final authProvider = Provider.of<FirebaseAuthProvider>(
                context,
                listen: false,
              );

              if (!authProvider.isAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please login to like products'),
                  ),
                );
                return;
              }

              await likesProvider.toggleLike(product.id);

              // Refresh product data to get updated like count
              final productProvider = Provider.of<ProductProvider>(
                context,
                listen: false,
              );
              await productProvider.fetchProducts(refresh: true);
            },
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
    },
  );
}
```

Add like count display below the product image:

```dart
// Add this after the Stack containing the image and wishlist button
if (product.likeCount > 0)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      children: [
        const Icon(
          Icons.favorite,
          size: 14,
          color: Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          '${product.likeCount}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  ),
```

#### 3. Update Product Detail Screen

**File**: `apps/customer_app/lib/features/catalog/screens/product_detail_screen.dart`

Add like button in the app bar or below product title:

```dart
// In build method, add to the actions of AppBar:
actions: [
  Consumer<LikesProvider>(
    builder: (context, likesProvider, child) {
      return IconButton(
        icon: Icon(
          product.isLikedByUser ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
        onPressed: () async {
          await likesProvider.toggleLike(product.id);
          _loadProductDetails(); // Refresh to get updated count
        },
      );
    },
  ),
],

// Add like count display below title:
if (product.likeCount > 0) ...[
  const SizedBox(height: 8),
  Row(
    children: [
      const Icon(
        Icons.favorite,
        size: 18,
        color: Colors.red,
      ),
      const SizedBox(width: 6),
      Text(
        '${product.likeCount} ${product.likeCount == 1 ? 'like' : 'likes'}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey[600],
        ),
      ),
    ],
  ),
],
```

#### 4. Register Provider in Main

**File**: `apps/customer_app/lib/main.dart`

Add LikesProvider to the MultiProvider:

```dart
import 'features/likes/providers/likes_provider.dart';

// In the providers list:
ChangeNotifierProvider(
  create: (context) => LikesProvider(apiClient),
),
```

#### 5. Optional: Create Liked Products Screen

**File**: `apps/customer_app/lib/features/likes/screens/liked_products_screen.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/likes_provider.dart';
import '../../catalog/widgets/product_card.dart';

class LikedProductsScreen extends StatefulWidget {
  const LikedProductsScreen({super.key});

  @override
  State<LikedProductsScreen> createState() => _LikedProductsScreenState();
}

class _LikedProductsScreenState extends State<LikedProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LikesProvider>(context, listen: false).fetchLikedProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Products'),
      ),
      body: Consumer<LikesProvider>(
        builder: (context, likesProvider, child) {
          if (likesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (likesProvider.error != null) {
            return Center(
              child: Text(
                likesProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!likesProvider.hasLikes) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No liked products yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start liking products to see them here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: likesProvider.likedProducts.length,
            itemBuilder: (context, index) {
              final like = likesProvider.likedProducts[index];
              if (like.product != null) {
                return ProductCard(product: like.product!);
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
```

Add route in `apps/customer_app/lib/routing/app_router.dart`:

```dart
GoRoute(
  path: 'likes',
  builder: (context, state) => const LikedProductsScreen(),
),
```

---

## Feature 2: Order Feedback System

### Goals

- Allow customers to submit feedback after receiving orders
- Store feedback with rating and text comment
- Display feedback in admin dashboard
- Only allow feedback for DELIVERED orders
- One feedback per order

### Database Changes

#### Create New Table: `OrderFeedback`

**File**: `apps/api/prisma/schema.prisma`

Add after the `Order` model:

```prisma
// ================================
// Order Feedback Model
// ================================
model OrderFeedback {
  id         String     @id @default(cuid())
  orderId    String     @unique @map("order_id")
  userId     String     @map("user_id")
  rating     Int        // 1-5 stars
  comment    String?    @db.Text
  createdAt  DateTime   @default(now()) @map("created_at")
  updatedAt  DateTime   @updatedAt @map("updated_at")

  // Relations
  order      Order      @relation(fields: [orderId], references: [id], onDelete: Cascade)
  user       User       @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("order_feedbacks")
}
```

**Update `User` model**:

```prisma
model User {
  // ... existing fields
  feedbacks     OrderFeedback[]
}
```

**Update `Order` model**:

```prisma
model Order {
  // ... existing fields
  feedback      OrderFeedback?
}
```

**Migration Steps**:

1. Run: `cd apps/api && npx prisma migrate dev --name add_order_feedback`
2. Generate Prisma client: `npx prisma generate`

---

### Backend API Implementation

#### 1. Create Order Feedback Module

**Directory**: `apps/api/src/modules/order-feedback/`

**Files to create**:

##### `order-feedback.types.ts`

```typescript
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
```

##### `order-feedback.repo.ts`

```typescript
import { prisma } from "@/lib/prisma";
import { OrderStatus } from "@prisma/client";

/**
 * Create feedback for an order
 */
export async function createFeedback(
	orderId: string,
	userId: string,
	rating: number,
	comment?: string,
) {
	return await prisma.orderFeedback.create({
		data: {
			orderId,
			userId,
			rating,
			comment,
		},
		include: {
			user: {
				select: {
					id: true,
					name: true,
					email: true,
				},
			},
			order: {
				select: {
					id: true,
					totalPrice: true,
					createdAt: true,
					items: {
						select: {
							id: true,
						},
					},
				},
			},
		},
	});
}

/**
 * Get feedback by order ID
 */
export async function getFeedbackByOrderId(orderId: string) {
	return await prisma.orderFeedback.findUnique({
		where: { orderId },
		include: {
			user: {
				select: {
					id: true,
					name: true,
					email: true,
				},
			},
			order: {
				select: {
					id: true,
					totalPrice: true,
					createdAt: true,
					items: {
						select: {
							id: true,
						},
					},
				},
			},
		},
	});
}

/**
 * Check if user owns the order
 */
export async function isOrderOwnedByUser(
	orderId: string,
	userId: string,
): Promise<boolean> {
	const order = await prisma.order.findUnique({
		where: { id: orderId, userId },
		select: { id: true },
	});
	return order !== null;
}

/**
 * Check if order is delivered
 */
export async function isOrderDelivered(orderId: string): Promise<boolean> {
	const order = await prisma.order.findUnique({
		where: { id: orderId },
		select: { status: true },
	});
	return order?.status === OrderStatus.DELIVERED;
}

/**
 * Get all feedbacks with pagination (admin)
 */
export async function getAllFeedbacks(page: number = 1, limit: number = 20) {
	const skip = (page - 1) * limit;

	const [feedbacks, total] = await Promise.all([
		prisma.orderFeedback.findMany({
			skip,
			take: limit,
			orderBy: { createdAt: "desc" },
			include: {
				user: {
					select: {
						id: true,
						name: true,
						email: true,
					},
				},
				order: {
					select: {
						id: true,
						totalPrice: true,
						createdAt: true,
						items: {
							select: {
								id: true,
							},
						},
					},
				},
			},
		}),
		prisma.orderFeedback.count(),
	]);

	return {
		feedbacks,
		total,
		pages: Math.ceil(total / limit),
	};
}

/**
 * Get feedback statistics
 */
export async function getFeedbackStats() {
	const [total, avgRating, ratingDistribution] = await Promise.all([
		prisma.orderFeedback.count(),
		prisma.orderFeedback.aggregate({
			_avg: { rating: true },
		}),
		prisma.orderFeedback.groupBy({
			by: ["rating"],
			_count: { rating: true },
		}),
	]);

	return {
		totalFeedbacks: total,
		averageRating: avgRating._avg.rating || 0,
		ratingDistribution: ratingDistribution.reduce(
			(acc, item) => {
				acc[item.rating] = item._count.rating;
				return acc;
			},
			{} as Record<number, number>,
		),
	};
}
```

##### `order-feedback.service.ts`

```typescript
import { AppError, NotFoundError } from "@/middleware/error.middleware";
import { ErrorCode } from "@/types/global";
import * as repo from "./order-feedback.repo";
import { FeedbackResponse } from "./order-feedback.types";

function toFeedbackResponse(feedback: any): FeedbackResponse {
	return {
		id: feedback.id,
		orderId: feedback.orderId,
		userId: feedback.userId,
		userName: feedback.user?.name || "Unknown",
		rating: feedback.rating,
		comment: feedback.comment,
		createdAt: feedback.createdAt.toISOString(),
		updatedAt: feedback.updatedAt.toISOString(),
		order: feedback.order
			? {
					id: feedback.order.id,
					totalPrice: feedback.order.totalPrice,
					itemCount: feedback.order.items?.length || 0,
					createdAt: feedback.order.createdAt.toISOString(),
				}
			: undefined,
	};
}

export async function submitFeedback(
	orderId: string,
	userId: string,
	rating: number,
	comment?: string,
) {
	// Validate rating
	if (rating < 1 || rating > 5) {
		throw new AppError(
			ErrorCode.BAD_REQUEST,
			"Rating must be between 1 and 5",
			400,
		);
	}

	// Check if user owns the order
	const isOwner = await repo.isOrderOwnedByUser(orderId, userId);
	if (!isOwner) {
		throw new AppError(
			ErrorCode.FORBIDDEN,
			"You can only submit feedback for your own orders",
			403,
		);
	}

	// Check if order is delivered
	const isDelivered = await repo.isOrderDelivered(orderId);
	if (!isDelivered) {
		throw new AppError(
			ErrorCode.BAD_REQUEST,
			"Feedback can only be submitted for delivered orders",
			400,
		);
	}

	// Check if feedback already exists
	const existingFeedback = await repo.getFeedbackByOrderId(orderId);
	if (existingFeedback) {
		throw new AppError(
			ErrorCode.BAD_REQUEST,
			"Feedback already submitted for this order",
			400,
		);
	}

	// Create feedback
	const feedback = await repo.createFeedback(orderId, userId, rating, comment);
	return toFeedbackResponse(feedback);
}

export async function getFeedbackForOrder(orderId: string) {
	const feedback = await repo.getFeedbackByOrderId(orderId);
	if (!feedback) {
		throw new NotFoundError("Feedback not found for this order");
	}
	return toFeedbackResponse(feedback);
}

export async function listAllFeedbacks(page: number = 1, limit: number = 20) {
	const result = await repo.getAllFeedbacks(page, limit);
	return {
		feedbacks: result.feedbacks.map(toFeedbackResponse),
		pagination: {
			page,
			limit,
			total: result.total,
			pages: result.pages,
		},
	};
}

export async function getFeedbackStatistics() {
	return await repo.getFeedbackStats();
}
```

#### 2. Create API Routes

##### Customer Route: Submit Feedback

**File**: `apps/api/src/app/api/v1/orders/[id]/feedback/route.ts`

```typescript
import { NextRequest, NextResponse } from "next/server";
import { authenticate } from "@/middleware/auth.middleware";
import {
	submitFeedback,
	getFeedbackForOrder,
} from "@/modules/order-feedback/order-feedback.service";
import { handleError } from "@/middleware/error.middleware";
import { z } from "zod";

const feedbackSchema = z.object({
	rating: z.number().min(1).max(5),
	comment: z.string().optional(),
});

/**
 * GET /api/v1/orders/:id/feedback
 * Get feedback for an order (if exists)
 */
export async function GET(
	req: NextRequest,
	{ params }: { params: { id: string } },
) {
	try {
		await authenticate(req, { required: true });
		const feedback = await getFeedbackForOrder(params.id);
		return NextResponse.json({ data: feedback });
	} catch (error: any) {
		return handleError(error);
	}
}

/**
 * POST /api/v1/orders/:id/feedback
 * Submit feedback for an order
 */
export async function POST(
	req: NextRequest,
	{ params }: { params: { id: string } },
) {
	try {
		const user = await authenticate(req, { required: true });
		const body = await req.json();

		const validatedData = feedbackSchema.parse(body);

		const feedback = await submitFeedback(
			params.id,
			user!.id,
			validatedData.rating,
			validatedData.comment,
		);

		return NextResponse.json(
			{
				data: feedback,
				message: "Feedback submitted successfully",
			},
			{ status: 201 },
		);
	} catch (error: any) {
		return handleError(error);
	}
}
```

##### Admin Route: List All Feedbacks

**File**: `apps/api/src/app/api/v1/admin/feedbacks/route.ts`

```typescript
import { NextRequest, NextResponse } from "next/server";
import { authenticate } from "@/middleware/auth.middleware";
import {
	listAllFeedbacks,
	getFeedbackStatistics,
} from "@/modules/order-feedback/order-feedback.service";
import { handleError } from "@/middleware/error.middleware";

/**
 * GET /api/v1/admin/feedbacks
 * List all customer feedbacks (admin only)
 */
export async function GET(req: NextRequest) {
	try {
		await authenticate(req, { required: true, adminOnly: true });

		const { searchParams } = new URL(req.url);
		const page = parseInt(searchParams.get("page") || "1");
		const limit = parseInt(searchParams.get("limit") || "20");

		const result = await listAllFeedbacks(page, limit);

		return NextResponse.json({
			data: result.feedbacks,
			pagination: result.pagination,
		});
	} catch (error: any) {
		return handleError(error);
	}
}
```

##### Admin Route: Feedback Statistics

**File**: `apps/api/src/app/api/v1/admin/feedbacks/stats/route.ts`

```typescript
import { NextRequest, NextResponse } from "next/server";
import { authenticate } from "@/middleware/auth.middleware";
import { getFeedbackStatistics } from "@/modules/order-feedback/order-feedback.service";
import { handleError } from "@/middleware/error.middleware";

/**
 * GET /api/v1/admin/feedbacks/stats
 * Get feedback statistics (admin only)
 */
export async function GET(req: NextRequest) {
	try {
		await authenticate(req, { required: true, adminOnly: true });
		const stats = await getFeedbackStatistics();
		return NextResponse.json({ data: stats });
	} catch (error: any) {
		return handleError(error);
	}
}
```

---

### Shared Models (Flutter)

**File**: `packages/flutter_shared/lib/models/order_feedback.dart` (NEW)

```dart
class OrderFeedback {
  final String id;
  final String orderId;
  final String userId;
  final String userName;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderFeedback({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderFeedback.fromJson(Map<String, dynamic> json) {
    return OrderFeedback(
      id: json['id'],
      orderId: json['orderId'],
      userId: json['userId'],
      userName: json['userName'] ?? 'Unknown',
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

**File**: `packages/flutter_shared/lib/models/order.dart`

Add feedback field:

```dart
class Order {
  // ... existing fields
  final OrderFeedback? feedback;

  Order({
    // ... existing parameters
    this.feedback,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      // ... existing fields
      feedback: json['feedback'] != null
          ? OrderFeedback.fromJson(json['feedback'])
          : null,
    );
  }

  bool get canSubmitFeedback => status == 'DELIVERED' && feedback == null;
  bool get hasFeedback => feedback != null;
}
```

Export in `packages/flutter_shared/lib/flutter_shared.dart`:

```dart
export 'models/order_feedback.dart';
```

---

### Customer App Frontend Implementation

#### 1. Create Feedback Provider

**File**: `apps/customer_app/lib/features/feedback/providers/feedback_provider.dart` (NEW)

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';

class FeedbackProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  bool _isSubmitting = false;
  String? _error;

  FeedbackProvider(this._apiClient);

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  /// Submit feedback for an order
  Future<bool> submitFeedback({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.post(
        '/orders/$orderId/feedback',
        body: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );

      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Get feedback for an order
  Future<OrderFeedback?> getFeedbackForOrder(String orderId) async {
    try {
      final response = await _apiClient.get('/orders/$orderId/feedback');
      if (response['data'] != null) {
        return OrderFeedback.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
```

#### 2. Create Feedback Dialog Widget

**File**: `apps/customer_app/lib/features/feedback/widgets/feedback_dialog.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feedback_provider.dart';

class FeedbackDialog extends StatefulWidget {
  final String orderId;

  const FeedbackDialog({super.key, required this.orderId});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final feedbackProvider = Provider.of<FeedbackProvider>(
      context,
      listen: false,
    );

    final success = await feedbackProvider.submitFeedback(
      orderId: widget.orderId,
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted && feedbackProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(feedbackProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Consumer<FeedbackProvider>(
        builder: (context, feedbackProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    const Text(
                      'Rate Your Order',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How was your experience?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Star Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          iconSize: 40,
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: feedbackProvider.isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _rating = index + 1;
                                  });
                                },
                        );
                      }),
                    ),
                    if (_rating > 0)
                      Text(
                        _getRatingText(_rating),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 24),

                    // Comment field
                    TextFormField(
                      controller: _commentController,
                      maxLines: 4,
                      enabled: !feedbackProvider.isSubmitting,
                      decoration: InputDecoration(
                        labelText: 'Comments (Optional)',
                        hintText: 'Tell us more about your experience...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLength: 500,
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: feedbackProvider.isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: feedbackProvider.isSubmitting
                                ? null
                                : _submitFeedback,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: feedbackProvider.isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
```

#### 3. Update Order Detail Screen

**File**: `apps/customer_app/lib/features/orders/screens/order_detail_screen.dart`

Add feedback button for delivered orders:

```dart
// Import feedback dialog
import '../../feedback/widgets/feedback_dialog.dart';

// In the build method, add feedback section after order items:
if (order.status == 'DELIVERED') ...[
  const SizedBox(height: 16),
  _buildFeedbackSection(order),
],

// Add method to build feedback section:
Widget _buildFeedbackSection(Order order) {
  if (order.hasFeedback) {
    // Show existing feedback
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < order.feedback!.rating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${order.feedback!.rating}/5',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (order.feedback!.comment != null &&
                order.feedback!.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                order.feedback!.comment!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Submitted on ${DateFormat('MMM dd, yyyy').format(order.feedback!.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  } else {
    // Show button to submit feedback
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.feedback_outlined, color: Colors.grey[700]),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'How was your order?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Share your experience with us',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showFeedbackDialog(order.id),
              icon: const Icon(Icons.rate_review),
              label: const Text('Give Feedback'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add method to show feedback dialog:
Future<void> _showFeedbackDialog(String orderId) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => FeedbackDialog(orderId: orderId),
  );

  if (result == true) {
    // Refresh order details to show submitted feedback
    _loadOrderDetails();
  }
}
```

#### 4. Register Provider in Main

**File**: `apps/customer_app/lib/main.dart`

```dart
import 'features/feedback/providers/feedback_provider.dart';

// In the providers list:
ChangeNotifierProvider(
  create: (context) => FeedbackProvider(apiClient),
),
```

---

### Admin App Frontend Implementation

#### 1. Create Feedback Provider

**File**: `apps/admin_app/lib/features/feedback/providers/feedback_provider.dart` (NEW)

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';

class AdminFeedbackProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<OrderFeedback> _feedbacks = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalFeedbacks = 0;

  // Statistics
  double _averageRating = 0.0;
  Map<int, int> _ratingDistribution = {};

  AdminFeedbackProvider(this._apiClient);

  // Getters
  List<OrderFeedback> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalFeedbacks => _totalFeedbacks;
  double get averageRating => _averageRating;
  Map<int, int> get ratingDistribution => _ratingDistribution;
  bool get hasFeedbacks => _feedbacks.isNotEmpty;

  /// Fetch all feedbacks with pagination
  Future<void> fetchFeedbacks({
    int page = 1,
    int limit = 20,
    bool refresh = false,
  }) async {
    if (refresh) {
      _feedbacks = [];
      _currentPage = 1;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '/admin/feedbacks',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response['data'] != null) {
        _feedbacks = (response['data'] as List)
            .map((json) => OrderFeedback.fromJson(json))
            .toList();
      }

      if (response['pagination'] != null) {
        _currentPage = response['pagination']['page'] ?? page;
        _totalPages = response['pagination']['pages'] ?? 1;
        _totalFeedbacks = response['pagination']['total'] ?? 0;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      _feedbacks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch feedback statistics
  Future<void> fetchStatistics() async {
    try {
      final response = await _apiClient.get('/admin/feedbacks/stats');

      if (response['data'] != null) {
        final data = response['data'];
        _averageRating = (data['averageRating'] ?? 0.0).toDouble();

        if (data['ratingDistribution'] != null) {
          _ratingDistribution = Map<int, int>.from(
            data['ratingDistribution'].map(
              (key, value) => MapEntry(int.parse(key.toString()), value as int),
            ),
          );
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching feedback statistics: $e');
    }
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (_currentPage < _totalPages && !_isLoading) {
      await fetchFeedbacks(page: _currentPage + 1);
    }
  }

  /// Refresh feedbacks
  Future<void> refresh() async {
    await fetchFeedbacks(refresh: true);
    await fetchStatistics();
  }
}
```

#### 2. Create Feedback List Screen

**File**: `apps/admin_app/lib/features/feedback/screens/feedback_list_screen.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../../../routing/route_names.dart';
import '../providers/feedback_provider.dart';
import '../widgets/feedback_card.dart';
import '../widgets/feedback_stats_card.dart';

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeedbacks();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final provider = Provider.of<AdminFeedbackProvider>(
        context,
        listen: false,
      );
      if (!provider.isLoading && provider.currentPage < provider.totalPages) {
        provider.loadNextPage();
      }
    }
  }

  Future<void> _loadFeedbacks() async {
    final provider = Provider.of<AdminFeedbackProvider>(
      context,
      listen: false,
    );
    await provider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Customer Feedback',
      currentRoute: RouteNames.feedback,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadFeedbacks,
          tooltip: 'Refresh',
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _loadFeedbacks,
        child: Consumer<AdminFeedbackProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && !provider.hasFeedbacks) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && !provider.hasFeedbacks) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadFeedbacks,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!provider.hasFeedbacks) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.feedback_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No feedback yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customer feedback will appear here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.hasFeedbacks
                  ? provider.feedbacks.length + 2 // +2 for stats and loading
                  : 1,
              itemBuilder: (context, index) {
                // Statistics card at top
                if (index == 0) {
                  return Column(
                    children: [
                      FeedbackStatsCard(
                        totalFeedbacks: provider.totalFeedbacks,
                        averageRating: provider.averageRating,
                        ratingDistribution: provider.ratingDistribution,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                    ],
                  );
                }

                // Feedback cards
                if (index <= provider.feedbacks.length) {
                  final feedback = provider.feedbacks[index - 1];
                  return FeedbackCard(
                    feedback: feedback,
                    onTap: () {
                      // Navigate to order details if needed
                    },
                  );
                }

                // Loading indicator at bottom
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}
```

#### 3. Create Feedback Card Widget

**File**: `apps/admin_app/lib/features/feedback/widgets/feedback_card.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'package:intl/intl.dart';

class FeedbackCard extends StatelessWidget {
  final OrderFeedback feedback;
  final VoidCallback? onTap;

  const FeedbackCard({
    super.key,
    required this.feedback,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Customer name and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            feedback.userName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feedback.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                DateFormat('MMM dd, yyyy • hh:mm a')
                                    .format(feedback.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Rating
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < feedback.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${feedback.rating}/5',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Comment
              if (feedback.comment != null && feedback.comment!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  feedback.comment!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Order ID
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Order #${feedback.orderId.substring(0, 8)}...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 4. Create Feedback Stats Card Widget

**File**: `apps/admin_app/lib/features/feedback/widgets/feedback_stats_card.dart` (NEW)

```dart
import 'package:flutter/material.dart';

class FeedbackStatsCard extends StatelessWidget {
  final int totalFeedbacks;
  final double averageRating;
  final Map<int, int> ratingDistribution;

  const FeedbackStatsCard({
    super.key,
    required this.totalFeedbacks,
    required this.averageRating,
    required this.ratingDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Feedback Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Summary stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  'Total',
                  totalFeedbacks.toString(),
                  Icons.feedback,
                ),
                _buildStatColumn(
                  context,
                  'Average',
                  averageRating.toStringAsFixed(1),
                  Icons.star,
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Rating distribution
            const Text(
              'Rating Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ...List.generate(5, (index) {
              final stars = 5 - index;
              final count = ratingDistribution[stars] ?? 0;
              final percentage = totalFeedbacks > 0
                  ? (count / totalFeedbacks * 100)
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Row(
                        children: [
                          Text(
                            '$stars',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getRatingColor(stars),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '$count (${percentage.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getRatingColor(int stars) {
    switch (stars) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
```

#### 5. Add Route to Admin Navigation

**File**: `apps/admin_app/lib/routing/route_names.dart`

```dart
class RouteNames {
  // ... existing routes
  static const String feedback = '/feedback';
}
```

**File**: `apps/admin_app/lib/routing/app_router.dart`

```dart
import '../features/feedback/screens/feedback_list_screen.dart';

// Add route:
GoRoute(
  path: RouteNames.feedback,
  builder: (context, state) => const FeedbackListScreen(),
),
```

**File**: `apps/admin_app/lib/shared/widgets/admin_scaffold.dart`

Add feedback to navigation menu:

```dart
NavigationRailDestination(
  icon: const Icon(Icons.feedback_outlined),
  selectedIcon: const Icon(Icons.feedback),
  label: const Text('Feedback'),
),
```

Update the `_getSelectedIndex` method to handle feedback route.

#### 6. Register Provider in Main

**File**: `apps/admin_app/lib/main.dart`

```dart
import 'features/feedback/providers/feedback_provider.dart';

// In the providers list:
ChangeNotifierProvider(
  create: (context) => AdminFeedbackProvider(apiClient),
),
```

---

## Testing Plan

### Backend Testing

#### Product Likes API Tests

```bash
# Test toggle like (add)
curl -X POST http://localhost:3000/api/v1/products/{productId}/like \
  -H "Authorization: Bearer {token}"

# Test get like stats
curl http://localhost:3000/api/v1/products/{productId}/like

# Test get user's liked products
curl http://localhost:3000/api/v1/me/likes \
  -H "Authorization: Bearer {token}"

# Test toggle like (remove)
curl -X POST http://localhost:3000/api/v1/products/{productId}/like \
  -H "Authorization: Bearer {token}"
```

#### Order Feedback API Tests

```bash
# Test submit feedback
curl -X POST http://localhost:3000/api/v1/orders/{orderId}/feedback \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "rating": 5,
    "comment": "Great service!"
  }'

# Test get feedback for order
curl http://localhost:3000/api/v1/orders/{orderId}/feedback \
  -H "Authorization: Bearer {token}"

# Test admin: list all feedbacks
curl http://localhost:3000/api/v1/admin/feedbacks \
  -H "Authorization: Bearer {adminToken}"

# Test admin: feedback stats
curl http://localhost:3000/api/v1/admin/feedbacks/stats \
  -H "Authorization: Bearer {adminToken}"
```

### Frontend Testing

#### Customer App

1. **Product Likes**
   - [ ] Heart icon shows correct state (filled/outlined)
   - [ ] Like count updates immediately after toggle
   - [ ] Likes persist across app restarts
   - [ ] Like button requires authentication
   - [ ] Like count displays correctly on product cards
   - [ ] Like count displays correctly on product detail screen

2. **Order Feedback**
   - [ ] Feedback button only shows for DELIVERED orders
   - [ ] Feedback dialog shows star rating and comment field
   - [ ] Cannot submit without rating
   - [ ] Feedback submits successfully
   - [ ] Submitted feedback displays in order details
   - [ ] Cannot submit feedback twice for same order

#### Admin App

1. **Feedback Dashboard**
   - [ ] Feedback list loads successfully
   - [ ] Statistics show correct values
   - [ ] Rating distribution chart displays correctly
   - [ ] Pagination works correctly
   - [ ] Feedback cards display all information
   - [ ] Refresh updates data

---

## Implementation Sequence

### Phase 1: Product Likes (Backend)

1. Update Prisma schema and run migrations
2. Create product-likes module (repo, service, types)
3. Create API routes
4. Update catalog endpoints to include like stats
5. Test all endpoints

### Phase 2: Product Likes (Frontend)

1. Update shared Product model
2. Create LikesProvider in customer app
3. Update ProductCard widget with like button
4. Update ProductDetailScreen with like button
5. Register provider in main.dart
6. Test functionality

### Phase 3: Order Feedback (Backend)

1. Update Prisma schema and run migrations
2. Create order-feedback module (repo, service, types)
3. Create customer API routes
4. Create admin API routes
5. Test all endpoints

### Phase 4: Order Feedback (Frontend - Customer App)

1. Update shared OrderFeedback model
2. Create FeedbackProvider
3. Create FeedbackDialog widget
4. Update OrderDetailScreen
5. Register provider in main.dart
6. Test functionality

### Phase 5: Order Feedback (Frontend - Admin App)

1. Create AdminFeedbackProvider
2. Create FeedbackListScreen
3. Create FeedbackCard widget
4. Create FeedbackStatsCard widget
5. Add routes and navigation
6. Register provider in main.dart
7. Test functionality

### Phase 6: Final Testing & Polish

1. Integration testing
2. Edge case handling
3. Error message improvements
4. Performance optimization
5. Documentation updates

---

## Edge Cases to Handle

### Product Likes

- User not authenticated trying to like
- Product doesn't exist
- Network errors during toggle
- Rapid clicking on like button
- Like count synchronization

### Order Feedback

- User trying to submit feedback for non-delivered order
- User trying to submit feedback for someone else's order
- Submitting feedback twice
- Invalid rating values (< 1 or > 5)
- Empty/too long comments
- Network errors during submission

---

## Performance Considerations

1. **Database Indexing**: Ensure indexes on:
   - `product_likes.userId`
   - `product_likes.productId`
   - `product_likes.userId + productId` (composite unique index)
   - `order_feedbacks.orderId` (unique index)
   - `order_feedbacks.userId`

2. **Caching**: Consider caching:
   - Product like counts (Redis with TTL)
   - Feedback statistics (Redis with TTL)

3. **Batch Operations**: When loading multiple products, fetch like stats in batch

4. **Lazy Loading**: Implement pagination for feedback list

---

## Documentation Updates Needed

1. Update `Agent-Context/Backend-Endpoints.md` with new endpoints
2. Update API documentation
3. Add user guide for feedback feature
4. Update admin documentation

---

## Future Enhancements

1. **Product Likes**
   - Show trending products based on likes
   - Most liked products section
   - Email notifications for popular products

2. **Order Feedback**
   - Response from admin to feedback
   - Feedback moderation system
   - Public reviews on product pages
   - Sentiment analysis on comments
   - Feedback reminders via push notifications

---

## End of Plan

This plan provides a complete roadmap for implementing both features. Follow the implementation sequence and test thoroughly at each phase. Each feature is independent, so they can be implemented in parallel by different developers if needed.
