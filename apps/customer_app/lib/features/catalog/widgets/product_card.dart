import 'package:flutter/material.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

/// Product card widget for grid display
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to product detail screen
          context.push('/catalog/product/${product.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image or PDF badge
            Expanded(child: _buildProductMedia()),

            // Product info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Price
                  Text(
                    '₹${product.displayPrice}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Stock indicator (if variant available)
                  if (product.variants != null &&
                      product.variants!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildStockIndicator(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductMedia() {
    if (product.isStationery && product.imageUrl != null) {
      // Display image for stationery products
      return Hero(
        tag: 'product-${product.id}',
        child: CachedNetworkImage(
          imageUrl: product.imageUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 48),
          ),
        ),
      );
    } else if (product.isBook) {
      // Display PDF badge for books
      return Container(
        color: Colors.grey[200],
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // No media available
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image_not_supported, size: 48)),
      );
    }
  }

  Widget _buildStockIndicator() {
    final variant = product.variants?.first;
    if (variant == null) {
      return const SizedBox.shrink();
    }

    final isInStock = variant.stock > 0;

    return Row(
      children: [
        Icon(
          isInStock ? Icons.check_circle : Icons.cancel,
          size: 12,
          color: isInStock ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          isInStock ? 'In Stock' : 'Out of Stock',
          style: TextStyle(
            fontSize: 10,
            color: isInStock ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
