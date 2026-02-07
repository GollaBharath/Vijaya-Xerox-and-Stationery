import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shared/flutter_shared.dart';
import '../../../routing/route_names.dart';
import '../../../shared/widgets/admin_drawer.dart';
import '../providers/product_provider.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({Key? key}) : super(key: key);

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategoryId;
  String? _selectedSubjectId;
  bool? _filterIsActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
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
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = context.read<ProductProvider>();
      if (provider.hasMore && !provider.isLoading) {
        provider.loadMoreProducts(
          categoryId: _selectedCategoryId,
          subjectId: _selectedSubjectId,
          isActive: _filterIsActive,
        );
      }
    }
  }

  Future<void> _loadProducts() async {
    try {
      await context.read<ProductProvider>().fetchProducts(
        categoryId: _selectedCategoryId,
        subjectId: _selectedSubjectId,
        isActive: _filterIsActive,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProduct(String productId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$title"?'),
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
        await context.read<ProductProvider>().deleteProduct(productId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting product: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToProductForm({Product? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    ).then((_) => _loadProducts());
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    ).then((_) => _loadProducts());
  }

  String _getFileTypeBadge(Product product) {
    if (product.fileType == 'image') {
      return '📷';
    } else if (product.fileType == 'pdf') {
      return '📄';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: RouteNames.products),
      appBar: AppBar(
        title: const Text('Product Management'),
        actions: [
          PopupMenuButton<bool?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterIsActive = value;
              });
              _loadProducts();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All Products')),
              const PopupMenuItem(value: true, child: Text('Active Only')),
              const PopupMenuItem(value: false, child: Text('Inactive Only')),
            ],
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProducts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No products found'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToProductForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProducts,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.products.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final product = provider.products[index];
                final fileTypeBadge = _getFileTypeBadge(product);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: product.isActive
                          ? Colors.green.shade100
                          : Colors.grey.shade300,
                      child: Text(
                        fileTypeBadge.isNotEmpty ? fileTypeBadge : '📦',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '₹${product.basePrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!product.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Inactive',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            if (fileTypeBadge.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  product.fileType == 'image' ? 'Image' : 'PDF',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 20),
                              SizedBox(width: 8),
                              Text('View'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'view':
                            _navigateToProductDetail(product);
                            break;
                          case 'edit':
                            _navigateToProductForm(product: product);
                            break;
                          case 'delete':
                            _deleteProduct(product.id, product.title);
                            break;
                        }
                      },
                    ),
                    onTap: () => _navigateToProductDetail(product),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToProductForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
