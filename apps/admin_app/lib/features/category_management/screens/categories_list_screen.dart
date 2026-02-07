import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/config/constants.dart';
import '../../../routing/route_names.dart';
import '../../../routing/app_router.dart';
import '../../../shared/widgets/admin_drawer.dart';
import '../providers/category_provider.dart';

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
            final allCategories = categoryProvider.categories;

            // Get only root categories (no parent)
            final rootCategories = categories
                .where((c) => c.parentId == null)
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: rootCategories.length,
              itemBuilder: (context, index) {
                final category = rootCategories[index];
                return _buildCategoryTree(category, allCategories);
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

  Widget _buildCategoryTree(dynamic category, List<dynamic> allCategories) {
    // Get children of this category
    final children = allCategories
        .where((c) => c.parentId == category.id)
        .toList();

    final hasChildren = children.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: hasChildren
          ? Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
                leading: const Icon(
                  Icons.folder_outlined,
                  color: Color(0xFFFF9800),
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: category.isActive
                              ? const Color(0xFF4CAF50).withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11,
                            color: category.isActive
                                ? const Color(0xFF4CAF50)
                                : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${children.length} sub-categor${children.length != 1 ? 'ies' : 'y'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _navigateToForm(categoryId: category.id),
                      tooltip: 'Edit',
                      color: Colors.blue.shade700,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () =>
                          _handleDelete(category.id, category.name),
                      tooltip: 'Delete',
                      color: Colors.red.shade700,
                    ),
                  ],
                ),
                children: children
                    .map((child) => _buildCategoryTree(child, allCategories))
                    .toList(),
              ),
            )
          : ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.label_outline,
                color: Color(0xFFE91E63),
              ),
              title: Text(
                category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              subtitle: Container(
                margin: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: category.isActive
                            ? const Color(0xFF4CAF50).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 11,
                          color: category.isActive
                              ? const Color(0xFF4CAF50)
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _navigateToForm(categoryId: category.id),
                    tooltip: 'Edit',
                    color: Colors.blue.shade700,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _handleDelete(category.id, category.name),
                    tooltip: 'Delete',
                    color: Colors.red.shade700,
                  ),
                ],
              ),
            ),
    );
  }
}
