import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/env.dart';

/// Modular product thumbnail widget for displaying images and PDFs
/// 
/// This widget handles:
/// - Image thumbnails with proper URL resolution
/// - PDF preview images (no badge)
/// - PDF rendering fallback using pdfx
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
    Widget thumbnail = _buildContent();

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

  Widget _buildContent() {
    final resolvedImageUrl = _resolveImageUrl(product.imageUrl);
    final resolvedPdfUrl = _resolvePdfUrl(product.pdfUrl);
    final resolvedPreviewUrl = _resolveImageUrl(product.previewUrl);

    if (product.isStationery && resolvedImageUrl != null) {
      // Display image for stationery products
      return _buildImageThumbnail(resolvedImageUrl);
    } else if (product.isBook) {
      if (resolvedPreviewUrl != null) {
        // Display preview image (PRIMARY METHOD)
        return _buildImageThumbnail(resolvedPreviewUrl);
      } else if (resolvedPdfUrl != null) {
        // Fallback: Render PDF first page using pdfx
        return _buildPdfThumbnail(resolvedPdfUrl);
      } else {
        // No PDF or preview available
        return _buildPdfPlaceholder();
      }
    }
    
    // No media available - show fallback
    return _buildFallbackThumbnail();
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

  Widget _buildPdfThumbnail(String pdfUrl) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      color: Colors.grey[200],
      child: FutureBuilder<PdfDocument>(
        future: PdfDocument.openData(
          // Download PDF from URL
          _downloadPdf(pdfUrl),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildPdfPlaceholder();
          }

          final document = snapshot.data!;
          
          return FutureBuilder<PdfPage>(
            future: document.getPage(1),
            builder: (context, pageSnapshot) {
              if (pageSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              
              if (pageSnapshot.hasError || !pageSnapshot.hasData) {
                return _buildPdfPlaceholder();
              }

              final page = pageSnapshot.data!;
              
              return FutureBuilder<PdfPageImage?>(
                future: page.render(
                  width: page.width * 2,
                  height: page.height * 2,
                ),
                builder: (context, imageSnapshot) {
                  if (imageSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  
                  if (imageSnapshot.hasError || !imageSnapshot.hasData || imageSnapshot.data == null) {
                    return _buildPdfPlaceholder();
                  }

                  return Image.memory(
                    imageSnapshot.data!.bytes,
                    fit: BoxFit.cover,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Uint8List> _downloadPdf(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Failed to download PDF');
  }

  Widget _buildPdfPlaceholder() {
    return Container(
      width: width ?? double.infinity,
      height: height,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text(
            'PDF Document',
            style: TextStyle(color: Colors.grey, fontSize: 12),
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
