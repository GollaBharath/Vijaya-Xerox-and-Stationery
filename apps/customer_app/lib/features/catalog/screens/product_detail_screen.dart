import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/config/env.dart';
import '../providers/product_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../widgets/variant_selector.dart';
import '../widgets/pdf_viewer_widget.dart';

/// Product detail screen with image/PDF display and add to cart
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductVariant? _selectedVariant;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Schedule data load after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductDetails();
    });
  }

  void _loadProductDetails() {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.fetchProductDetails(widget.productId);
  }

  void _onVariantSelected(ProductVariant variant) {
    setState(() {
      _selectedVariant = variant;
    });
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() async {
    if (_selectedVariant == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a variant')));
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final success = await cartProvider.addToCart(
      _selectedVariant!.id,
      _quantity,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_quantity item(s) to cart'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
    } else if (mounted && cartProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    productProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProductDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final product = productProvider.selectedProduct;
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          // Set default variant if not selected
          if (_selectedVariant == null &&
              product.variants != null &&
              product.variants!.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedVariant = product.variants!.first;
              });
            });
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product media (image or PDF)
                _buildProductMedia(product),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        product.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),

                      // ISBN (if book)
                      if (product.isbn != null) ...[
                        Text(
                          'ISBN: ${product.isbn}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Price
                      Text(
                        '₹${_selectedVariant?.price ?? product.displayPrice}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Stock status
                      _buildStockStatus(_selectedVariant),
                      const SizedBox(height: 16),

                      // Variant selector
                      if (product.variants != null &&
                          product.variants!.isNotEmpty) ...[
                        VariantSelector(
                          variants: product.variants!,
                          selectedVariant: _selectedVariant,
                          onVariantSelected: _onVariantSelected,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Quantity selector
                      _buildQuantitySelector(),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProductMedia(Product product) {
    final resolvedImageUrl = _resolveImageUrl(product.imageUrl);
    final resolvedPdfUrl = _resolvePdfUrl(product.pdfUrl);

    if (product.isStationery && resolvedImageUrl != null) {
      // Display image for stationery
      return Hero(
        tag: 'product-${product.id}',
        child: GestureDetector(
          onTap: () => _showImageZoom(resolvedImageUrl),
          child: CachedNetworkImage(
            imageUrl: resolvedImageUrl,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 300,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 300,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, size: 64),
            ),
          ),
        ),
      );
    } else if (product.isBook && resolvedPdfUrl != null) {
      // Display PDF badge and preview button for books
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showPdfViewer(resolvedPdfUrl),
              icon: const Icon(Icons.visibility),
              label: const Text('Preview PDF'),
            ),
          ],
        ),
      );
    } else {
      // No media available
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image_not_supported, size: 64)),
      );
    }
  }

  Widget _buildStockStatus(ProductVariant? variant) {
    if (variant == null) {
      return const SizedBox.shrink();
    }

    final stock = variant.stock;
    final isInStock = stock > 0;

    return Row(
      children: [
        Icon(
          isInStock ? Icons.check_circle : Icons.cancel,
          color: isInStock ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          isInStock ? 'In Stock ($stock available)' : 'Out of Stock',
          style: TextStyle(
            color: isInStock ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text('Quantity:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _quantity > 1 ? _decrementQuantity : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _quantity.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _incrementQuantity,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: (_selectedVariant?.stock ?? 0) > 0 ? _addToCart : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Add to Cart', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  void _showImageZoom(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPdfViewer(String pdfUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PdfViewerWidget(pdfUrl: pdfUrl)),
    );
  }

  String? _resolveImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    if (imagePath.startsWith('http')) return imagePath;
    if (imagePath.startsWith('/')) {
      return '${Environment.apiBaseUrl}$imagePath';
    }
    return '${Environment.apiBaseUrl}/api/v1/files/images/products/$imagePath';
  }

  String? _resolvePdfUrl(String? pdfPath) {
    if (pdfPath == null || pdfPath.isEmpty) return null;
    if (pdfPath.startsWith('http')) return pdfPath;
    if (pdfPath.startsWith('/')) {
      return '${Environment.apiBaseUrl}$pdfPath';
    }
    return '${Environment.apiBaseUrl}/api/v1/files/pdfs/books/$pdfPath';
  }
}
