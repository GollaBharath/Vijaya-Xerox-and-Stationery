import 'package:flutter/material.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'product_thumbnail.dart';
import '../../cart/providers/cart_provider.dart';
import '../../likes/providers/likes_provider.dart';

/// Product card widget for grid display with action buttons
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/home/product/${product.id}');
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with wishlist button overlay
            Expanded(
              child: Stack(
                children: [
                  // Thumbnail
                  ProductThumbnail(
                    product: product,
                    heroTag: 'product-${product.id}',
                    fit: BoxFit.cover,
                  ),

                  // Like button overlay (top-right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildLikeButton(context),
                  ),
                ],
              ),
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Price
                  Text(
                    '₹${product.displayPrice}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Stock indicator
                  _buildStockIndicator(context),
                  const SizedBox(height: 8),

                  // Add to cart button
                  _buildAddToCartButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton(BuildContext context) {
    final likesProvider = Provider.of<LikesProvider>(context);
    final isLiked = likesProvider.isLiked(product.id);
    final likeCount = likesProvider.getLikeCount(product.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
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
          onTap: () {
            likesProvider.toggleLike(product);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: Colors.red,
                ),
                if (likeCount > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$likeCount',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    final variant = product.variants?.firstOrNull;
    final isInStock = variant != null && variant.stock;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isInStock ? () => _addToCart(context, variant) : null,
        icon: const Icon(Icons.shopping_cart_outlined, size: 16),
        label: const Text('Add to Cart', style: TextStyle(fontSize: 13)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, ProductVariant variant) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    cartProvider.addToCart(variant.id, 1).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.title} added to cart'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (cartProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cartProvider.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  Widget _buildStockIndicator(BuildContext context) {
    final variant = product.variants?.firstOrNull;
    if (variant == null) {
      return const SizedBox.shrink();
    }

    final isInStock = variant.stock;

    return Row(
      children: [
        Icon(
          isInStock ? Icons.check_circle : Icons.cancel,
          size: 14,
          color: isInStock ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          isInStock ? 'In Stock' : 'Out of Stock',
          style: TextStyle(
            fontSize: 11,
            color: isInStock ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
