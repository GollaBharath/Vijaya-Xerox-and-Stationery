import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_shared/flutter_shared.dart';
import '../providers/category_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/product_provider.dart';
import '../../likes/providers/likes_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/category_navigation.dart';
import '../../../routing/route_names.dart';

/// Main catalog screen with category/subject filters and product list
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategoryId;
  String? _selectedSubjectId;
  bool _needsRefresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    // Schedule initial data load after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Mark that we need to refresh when app resumes
      _needsRefresh = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we need to refresh (e.g., coming back from another screen)
    if (_needsRefresh) {
      _needsRefresh = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialData();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    final likesProvider = Provider.of<LikesProvider>(context, listen: false);

    // Load categories and subjects
    categoryProvider.fetchCategories();
    subjectProvider.fetchSubjects();

    // Load initial products
    productProvider.fetchProducts(reset: true);

    // Load user's liked products (if authenticated)
    likesProvider.fetchLikedProducts();
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
      _selectedSubjectId = null; // Reset subject filter when category selected
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
      _selectedCategoryId = null; // Reset category filter when subject selected
    });

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.fetchProducts(subjectId: subjectId, reset: true);
  }

  void _applyFilters(String? categoryId, String? subjectId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedSubjectId = subjectId;
    });

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.fetchProducts(
      categoryId: categoryId,
      subjectId: subjectId,
      reset: true,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedSubjectId = null;
    });

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.fetchProducts(reset: true);
  }

  void _showFilterBottomSheet() {
    String? tempCategoryId = _selectedCategoryId;
    String? tempSubjectId = _selectedSubjectId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempCategoryId = null;
                              tempSubjectId = null;
                            });
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Filter content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Categories section
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Consumer<CategoryProvider>(
                          builder: (context, categoryProvider, child) {
                            if (categoryProvider.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (categoryProvider.error != null) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  categoryProvider.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            if (categoryProvider.categories.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('No categories available'),
                              );
                            }

                            return _buildCategoryTree(
                              categoryProvider.categories,
                              tempCategoryId,
                              (categoryId) {
                                setModalState(() {
                                  tempCategoryId = categoryId;
                                  tempSubjectId = null;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        // Subjects section
                        const Text(
                          'Subjects',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Consumer<SubjectProvider>(
                          builder: (context, subjectProvider, child) {
                            if (subjectProvider.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (subjectProvider.error != null) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  subjectProvider.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            if (subjectProvider.subjects.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('No subjects available'),
                              );
                            }

                            return _buildSubjectTree(
                              subjectProvider.subjects,
                              tempSubjectId,
                              (subjectId) {
                                setModalState(() {
                                  tempSubjectId = subjectId;
                                  tempCategoryId = null;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Apply button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _applyFilters(tempCategoryId, tempSubjectId);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
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
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await context.push(RouteNames.search);
              // Force reload when returning from search
              _needsRefresh = true;
              _loadInitialData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () async {
                    await context.push(RouteNames.search);
                    // Force reload when returning from search
                    _needsRefresh = true;
                    _loadInitialData();
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[200], // Adjust color as needed for design
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[300]!, // Green border for search bar in design? Maybe green border
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Search products',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.mic, // Or filter icon? Design has filter icon on right? 
                          // Design screenshot has search icon on right? NO, left.
                          // It has a magnifier on the right actually.
                          // Let's stick to standard search look.
                          color: Theme.of(context).hintColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Category and Subject Navigation
            SliverToBoxAdapter(
              child: CategoryNavigation(
                onSelectionChanged: (categoryId, subjectId) {
                  setState(() {
                    _selectedCategoryId = categoryId;
                    _selectedSubjectId = subjectId;
                  });
                  final productProvider = Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  );
                  productProvider.fetchProducts(
                    categoryId: categoryId,
                    subjectId: subjectId,
                    reset: true,
                  );
                },
              ),
            ),

            // Products grid
            _buildProductsGrid(),

            // Loading more indicator
            SliverToBoxAdapter(child: _buildLoadingMoreIndicator()),
          ],
        ),
      ),
    );
  }

  // Old filter methods removed


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

  Widget _buildCategoryTree(
    List<Category> allCategories,
    String? selectedId,
    Function(String?) onSelect,
  ) {
    final rootCategories = allCategories
        .where((cat) => !cat.hasParent && cat.isActive)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<String?>(
          title: const Text('All Categories'),
          value: null,
          groupValue: selectedId,
          onChanged: onSelect,
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        ...rootCategories.map(
          (category) => _CategoryExpansionTile(
            category: category,
            allCategories: allCategories,
            selectedId: selectedId,
            onSelect: onSelect,
            level: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectTree(
    List<Subject> allSubjects,
    String? selectedId,
    Function(String?) onSelect,
  ) {
    final rootSubjects = allSubjects
        .where((subject) => !subject.hasParent)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<String?>(
          title: const Text('All Subjects'),
          value: null,
          groupValue: selectedId,
          onChanged: onSelect,
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        ...rootSubjects.map(
          (subject) => _SubjectExpansionTile(
            subject: subject,
            allSubjects: allSubjects,
            selectedId: selectedId,
            onSelect: onSelect,
            level: 0,
          ),
        ),
      ],
    );
  }
}

// Category expansion tile widget
class _CategoryExpansionTile extends StatefulWidget {
  final Category category;
  final List<Category> allCategories;
  final String? selectedId;
  final Function(String?) onSelect;
  final int level;

  const _CategoryExpansionTile({
    required this.category,
    required this.allCategories,
    required this.selectedId,
    required this.onSelect,
    required this.level,
  });

  @override
  State<_CategoryExpansionTile> createState() => _CategoryExpansionTileState();
}

class _CategoryExpansionTileState extends State<_CategoryExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final children = widget.allCategories
        .where((cat) => cat.parentId == widget.category.id && cat.isActive)
        .toList();

    final hasChildren = children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.level * 16.0),
          child: Row(
            children: [
              if (hasChildren)
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36),
                )
              else
                const SizedBox(width: 36),
              Expanded(
                child: RadioListTile<String?>(
                  title: Text(widget.category.name),
                  value: widget.category.id,
                  groupValue: widget.selectedId,
                  onChanged: widget.onSelect,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        if (_isExpanded && hasChildren)
          ...children.map(
            (child) => _CategoryExpansionTile(
              category: child,
              allCategories: widget.allCategories,
              selectedId: widget.selectedId,
              onSelect: widget.onSelect,
              level: widget.level + 1,
            ),
          ),
      ],
    );
  }
}

// Subject expansion tile widget
class _SubjectExpansionTile extends StatefulWidget {
  final Subject subject;
  final List<Subject> allSubjects;
  final String? selectedId;
  final Function(String?) onSelect;
  final int level;

  const _SubjectExpansionTile({
    required this.subject,
    required this.allSubjects,
    required this.selectedId,
    required this.onSelect,
    required this.level,
  });

  @override
  State<_SubjectExpansionTile> createState() => _SubjectExpansionTileState();
}

class _SubjectExpansionTileState extends State<_SubjectExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final children = widget.allSubjects
        .where((sub) => sub.parentSubjectId == widget.subject.id)
        .toList();

    final hasChildren = children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.level * 16.0),
          child: Row(
            children: [
              if (hasChildren)
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36),
                )
              else
                const SizedBox(width: 36),
              Expanded(
                child: RadioListTile<String?>(
                  title: Text(widget.subject.name),
                  value: widget.subject.id,
                  groupValue: widget.selectedId,
                  onChanged: widget.onSelect,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        if (_isExpanded && hasChildren)
          ...children.map(
            (child) => _SubjectExpansionTile(
              subject: child,
              allSubjects: widget.allSubjects,
              selectedId: widget.selectedId,
              onSelect: widget.onSelect,
              level: widget.level + 1,
            ),
          ),
      ],
    );
  }
}
