import 'package:flutter/material.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'package:provider/provider.dart';
import '../../likes/providers/likes_provider.dart';

class LikeButton extends StatelessWidget {
  final Product product;
  final Color? color;
  final double size;
  final bool showCount;

  const LikeButton({
    super.key,
    required this.product,
    this.color,
    this.size = 18,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    // Watch only the specific product's like state
    return Consumer<LikesProvider>(
      builder: (context, likesProvider, child) {
        final isLiked = likesProvider.isLiked(product.id);
        
        // Use provider's count if available (for real-time updates), 
        // otherwise fallback to product's initial count
        final likeCount = likesProvider.likeCounts[product.id] ?? product.likeCount;

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
                      size: size,
                      color: Colors.red,
                    ),
                    if (showCount && likeCount > 0) ...[
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
      },
    );
  }
}
