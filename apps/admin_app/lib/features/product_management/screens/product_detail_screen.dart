import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shared/flutter_shared.dart';
import '../../../routing/route_names.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../providers/product_provider.dart';
import '../providers/variant_provider.dart';
import 'product_form_screen.dart';
import 'variant_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVariants();
    });
  }

  Future<void> _loadVariants() async {
    try {
      await context.read<VariantProvider>().fetchVariants(widget.product.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading variants: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteVariant(String variantId, String variantType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Variant'),
        content: Text(
          'Are you sure you want to delete "$variantType" variant?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<VariantProvider>().deleteVariant(variantId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Variant deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting variant: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToVariantForm({ProductVariant? variant}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VariantFormScreen(productId: widget.product.id, variant: variant),
      ),
    ).then((_) => _loadVariants());
  }

  void _navigateToEditProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: widget.product),
      ),
    ).then((_) {
      // Refresh product details
      context.read<ProductProvider>().fetchProductDetails(widget.product.id);
    });
  }

  Widget _buildFilePreview() {
    if (widget.product.fileType == 'image' && widget.product.imageUrl != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Image.network(
                widget.product.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.error, size: 48, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (widget.product.fileType == 'pdf' &&
        widget.product.pdfUrl != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product PDF',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, size: 48),
                title: const Text('PDF Preview Available'),
                subtitle: Text(widget.product.pdfUrl!),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // TODO: Implement PDF download
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF download not implemented yet'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Product Details',
      currentRoute: RouteNames.products,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _navigateToEditProduct,
          tooltip: 'Edit Product',
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Product Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.product.isActive
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.product.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: widget.product.isActive
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Base Price',
                    '₹${widget.product.basePrice.toStringAsFixed(2)}',
                  ),
                  if (widget.product.isbn != null)
                    _buildInfoRow('ISBN', widget.product.isbn!),
                  _buildInfoRow('Subject ID', widget.product.subjectId),
                  _buildInfoRow(
                    'File Type',
                    widget.product.fileType == 'image'
                        ? '📷 Image'
                        : widget.product.fileType == 'pdf'
                        ? '📄 PDF'
                        : 'None',
                  ),
                  _buildInfoRow(
                    'Created',
                    '${widget.product.createdAt.toString().split('.')[0]}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // File Preview
          _buildFilePreview(),
          const SizedBox(height: 16),

          // Variants Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Variants',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToVariantForm(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Variant'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer<VariantProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.variants.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No variants added yet'),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.variants.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final variant = provider.variants[index];
                          return ListTile(
                            title: Text(
                              variant.variantType,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price: ₹${variant.price.toStringAsFixed(2)}',
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      variant.stock
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 16,
                                      color: variant.stock
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      variant.stock
                                          ? 'In Stock'
                                          : 'Out of Stock',
                                    ),
                                  ],
                                ),
                                Text('SKU: ${variant.sku}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _navigateToVariantForm(variant: variant),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteVariant(
                                    variant.id,
                                    variant.variantType,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
