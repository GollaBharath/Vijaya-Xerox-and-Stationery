import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import 'quantity_selector.dart';
import '../../../core/config/constants.dart';

/// Cart item card widget displaying item details and controls
class CartItemCard extends StatelessWidget {
  final CartItem cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to product detail
          if (cartItem.variant?.productId != null) {
            context.push('/home/product/${cartItem.variant!.productId}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image or PDF badge
              _buildProductMedia(),
              const SizedBox(width: 12),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      cartItem.variant?.product?.title ??
                          cartItem.variant?.sku ??
                          'Product',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Variant info
                    if (cartItem.variant?.variantType != null) ...[
                      Text(
                        _getVariantLabel(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Price
                    Text(
                      '₹${(cartItem.variant?.price ?? 0.0).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quantity selector and remove button
                    Row(
                      children: [
                        QuantitySelector(
                          quantity: cartItem.quantity,
                          onIncrement: () {
                            cartProvider.incrementQuantity(cartItem.id);
                          },
                          onDecrement: () {
                            cartProvider.decrementQuantity(cartItem.id);
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            _confirmRemove(context, cartProvider);
                          },
                          color: Colors.red,
                          tooltip: 'Remove item',
                        ),
                      ],
                    ),

                    // Subtotal
                    Text(
                      'Subtotal: ₹${cartItem.getTotal().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductMedia() {
    final product = cartItem.variant?.product;
    final fileType = product?.fileType ?? 'NONE';
    final imageUrl = product?.imageUrl;

    // Build full image URL if it's a relative path
    String? fullImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        fullImageUrl = imageUrl;
      } else {
        // Construct full URL from base URL and relative path
        fullImageUrl = '${AppConstants.apiBaseUrl}$imageUrl';
      }
    }

    if (fileType == 'IMAGE' && fullImageUrl != null) {
      // Display image for stationery
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: fullImageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image),
          ),
        ),
      );
    } else if (fileType == 'PDF') {
      // Display PDF badge for books
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 32, color: Colors.red),
            SizedBox(height: 4),
            Text(
              'PDF',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    } else {
      // No media
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_not_supported),
      );
    }
  }

  String _getVariantLabel() {
    final variantType = cartItem.variant?.variantType.toUpperCase() ?? '';

    if (variantType == 'COLOR') {
      return 'Color Print';
    } else if (variantType == 'BW' || variantType == 'B&W') {
      return 'Black & White';
    } else {
      return variantType;
    }
  }

  void _confirmRemove(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Remove this item from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cartProvider.removeFromCart(cartItem.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item removed from cart'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
