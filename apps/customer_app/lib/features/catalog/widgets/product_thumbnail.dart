import 'package:flutter/material.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/config/env.dart';

/// Modular product thumbnail widget for displaying images and PDFs
/// 
/// This widget handles:
/// - Image thumbnails with proper URL resolution
/// - PDF thumbnails with distinctive badge overlay
/// - Loading states with spinner
/// - Error states with fallback icons
/// - Configurable sizing and styling
/// - Hero animation support
class ProductThumbnail extends StatelessWidget {
  final Product product;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final VoidCallback? onTap;

  const ProductThumbnail({
    super.key,
    required this.product,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget thumbnail = _buildThumbnail();

    // Wrap with Hero animation if tag is provided
    if (heroTag != null) {
      thumbnail = Hero(
        tag: heroTag!,
        child: thumbnail,
      );
    }

    // Wrap with GestureDetector if onTap is provided
    if (onTap != null) {
      thumbnail = GestureDetector(
        onTap: onTap,
        child: thumbnail,
      );
    }

    // Apply border radius if provided
    if (borderRadius != null) {
      thumbnail = ClipRRect(
        borderRadius: borderRadius!,
        child: thumbnail,
      );
    }

    return thumbnail;
  }

  Widget _buildThumbnail() {
    final resolvedImageUrl = _resolveImageUrl(product.imageUrl);
    final resolvedPdfUrl = _resolvePdfUrl(product.pdfUrl);

    if (product.isStationery && resolvedImageUrl != null) {
      // Display image for stationery products
      return _buildImageThumbnail(resolvedImageUrl);
    } else if (product.isBook && resolvedPdfUrl != null) {
      // Display PDF thumbnail with badge for books
      return _buildPdfThumbnail();
    } else {
      // No media available - show fallback
      return _buildFallbackThumbnail();
    }
  }

  Widget _buildImageThumbnail(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width ?? double.infinity,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width ?? double.infinity,
        height: height,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width ?? double.infinity,
        height: height,
        color: Colors.grey[200],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfThumbnail() {
    return Container(
      width: width ?? double.infinity,
      height: height,
      color: Colors.grey[200],
      child: Stack(
        children: [
          // PDF icon in center
          const Center(
            child: Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: Colors.red,
            ),
          ),
          // PDF badge in top-right corner
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      width: width ?? double.infinity,
      height: height,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text(
            'No preview available',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Resolve image URL from various formats
  String? _resolveImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    // Already a full URL
    if (imagePath.startsWith('http')) return imagePath;
    
    // Absolute path from server root
    if (imagePath.startsWith('/')) {
      return '${Environment.apiBaseUrl}$imagePath';
    }
    
    // Relative path - assume it's in the products folder
    return '${Environment.apiBaseUrl}/api/v1/files/images/products/$imagePath';
  }

  /// Resolve PDF URL from various formats
  String? _resolvePdfUrl(String? pdfPath) {
    if (pdfPath == null || pdfPath.isEmpty) return null;
    
    // Already a full URL
    if (pdfPath.startsWith('http')) return pdfPath;
    
    // Absolute path from server root
    if (pdfPath.startsWith('/')) {
      return '${Environment.apiBaseUrl}$pdfPath';
    }
    
    // Relative path - assume it's in the books folder
    return '${Environment.apiBaseUrl}/api/v1/files/pdfs/books/$pdfPath';
  }
}
