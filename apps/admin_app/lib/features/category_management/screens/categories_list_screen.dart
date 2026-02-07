import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/config/constants.dart';
import '../../../routing/route_names.dart';
import '../../../routing/app_router.dart';
import '../../../shared/widgets/admin_drawer.dart';
import '../providers/category_provider.dart';
import '../widgets/category_tree_item.dart';

/// Categories list screen with tree view
class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  Future<void> _handleRefresh() async {
    await context.read<CategoryProvider>().fetchCategories();
  }

  void _navigateToForm({String? categoryId}) {
    AppRouter.push(
      context,
      RouteNames.categoryForm,
      arguments: categoryId,
    ).then((_) {
      // Refresh list after form
      _handleRefresh();
    });
  }

  Future<void> _handleDelete(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<CategoryProvider>().deleteCategory(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted successfully')),
          );
        } else {
          final errorMessage =
              context.read<CategoryProvider>().errorMessage ??
              'Failed to delete category';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: RouteNames.categories),
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, _) {
            if (categoryProvider.isLoading &&
                categoryProvider.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (categoryProvider.errorMessage != null &&
                categoryProvider.categories.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Text(
                        categoryProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      ElevatedButton(
                        onPressed: _handleRefresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (categoryProvider.categories.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Text(
                        'No categories yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Tap the + button to create your first category',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final categories = categoryProvider.categoryTree;

            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final depth = _getCategoryDepth(
                  category,
                  categoryProvider.categories,
                );

                return CategoryTreeItem(
                  category: category,
                  depth: depth,
                  onEdit: () => _navigateToForm(categoryId: category.id),
                  onDelete: () => _handleDelete(category.id, category.name),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }

  int _getCategoryDepth(dynamic category, List<dynamic> allCategories) {
    int depth = 0;
    String? currentParentId = category.parentId;

    while (currentParentId != null) {
      depth++;
      try {
        final parent = allCategories.firstWhere(
          (cat) => cat.id == currentParentId,
        );
        currentParentId = parent.parentId;
      } catch (e) {
        // Parent not found, break loop
        break;
      }
    }

    return depth;
  }
}
