import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';

/// Main catalog screen with category/subject filters and product list
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategoryId;
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final subjectProvider = Provider.of<SubjectProvider>(
      context,
      listen: false,
    );
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // Load categories and subjects
    categoryProvider.fetchCategories();
    subjectProvider.fetchSubjects();

    // Load initial products
    productProvider.fetchProducts(reset: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when scrolled to 80%
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      if (!productProvider.isLoadingMore && productProvider.hasMore) {
        productProvider.loadMore();
      }
    }
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedSubjectId = null; // Reset subject filter
    });

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.fetchProducts(categoryId: categoryId, reset: true);
  }

  void _onSubjectSelected(String? subjectId) {
    setState(() {
      _selectedSubjectId = subjectId;
      _selectedCategoryId = null; // Reset category filter
    });

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.fetchProducts(subjectId: subjectId, reset: true);
  }

  Future<void> _onRefresh() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final subjectProvider = Provider.of<SubjectProvider>(
      context,
      listen: false,
    );
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      categoryProvider.fetchCategories(forceRefresh: true),
      subjectProvider.fetchSubjects(forceRefresh: true),
      productProvider.fetchProducts(
        categoryId: _selectedCategoryId,
        subjectId: _selectedSubjectId,
        reset: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search screen
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Category filters
            SliverToBoxAdapter(child: _buildCategoryFilters()),

            // Subject filters
            SliverToBoxAdapter(child: _buildSubjectFilters()),

            // Products grid
            _buildProductsGrid(),

            // Loading more indicator
            SliverToBoxAdapter(child: _buildLoadingMoreIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading && !categoryProvider.hasCategories) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (categoryProvider.error != null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading categories: ${categoryProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final categories = categoryProvider.rootCategories;
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              CategoryChip(
                label: 'All Categories',
                isSelected: _selectedCategoryId == null,
                onSelected: () => _onCategorySelected(null),
              ),
              const SizedBox(width: 8),
              ...categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    label: category.name,
                    isSelected: _selectedCategoryId == category.id,
                    onSelected: () => _onCategorySelected(category.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubjectFilters() {
    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, child) {
        if (subjectProvider.isLoading && !subjectProvider.hasSubjects) {
          return const SizedBox.shrink();
        }

        if (subjectProvider.error != null) {
          return const SizedBox.shrink();
        }

        final subjects = subjectProvider.rootSubjects;
        if (subjects.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              CategoryChip(
                label: 'All Subjects',
                isSelected: _selectedSubjectId == null,
                onSelected: () => _onSubjectSelected(null),
              ),
              const SizedBox(width: 8),
              ...subjects.map(
                (subject) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    label: subject.name,
                    isSelected: _selectedSubjectId == subject.id,
                    onSelected: () => _onSubjectSelected(subject.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsGrid() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading && !productProvider.hasProducts) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (productProvider.error != null && !productProvider.hasProducts) {
          return SliverFillRemaining(
            child: Center(
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
                    onPressed: () {
                      productProvider.fetchProducts(
                        categoryId: _selectedCategoryId,
                        subjectId: _selectedSubjectId,
                        reset: true,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final products = productProvider.activeProducts;
        if (products.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No products found')),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return ProductCard(product: products[index]);
            }, childCount: products.length),
          ),
        );
      },
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (!productProvider.isLoadingMore) {
          return const SizedBox.shrink();
        }

        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
