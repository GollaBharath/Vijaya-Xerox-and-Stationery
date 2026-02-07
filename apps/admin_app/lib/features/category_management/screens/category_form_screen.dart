import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/constants.dart';
import '../providers/category_provider.dart';

/// Category form screen for create/edit
class CategoryFormScreen extends StatefulWidget {
  final String? categoryId;

  const CategoryFormScreen({super.key, this.categoryId});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedParentId;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.categoryId != null;
    if (_isEditing) {
      _loadCategory();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCategory() async {
    setState(() => _isLoading = true);

    final category = await context.read<CategoryProvider>().fetchCategoryById(
      widget.categoryId!,
    );

    if (category != null && mounted) {
      _nameController.text = category.name;
      _selectedParentId = category.parentId;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final categoryProvider = context.read<CategoryProvider>();
    bool success;

    if (_isEditing) {
      success = await categoryProvider.updateCategory(
        id: widget.categoryId!,
        name: _nameController.text.trim(),
        parentId: _selectedParentId,
      );
    } else {
      success = await categoryProvider.createCategory(
        name: _nameController.text.trim(),
        parentId: _selectedParentId,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Category updated successfully'
                  : 'Category created successfully',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              categoryProvider.errorMessage ??
                  (_isEditing
                      ? 'Failed to update category'
                      : 'Failed to create category'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Category' : 'Add Category'),
      ),
      body: _isLoading && _isEditing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        hintText: 'Enter category name',
                        prefixIcon: Icon(Icons.category),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Category name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Category name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Parent category dropdown
                    Consumer<CategoryProvider>(
                      builder: (context, categoryProvider, _) {
                        final availableParents = categoryProvider.categories
                            .where((cat) => cat.id != widget.categoryId)
                            .toList();

                        return DropdownButtonFormField<String>(
                          value: _selectedParentId,
                          decoration: const InputDecoration(
                            labelText: 'Parent Category (Optional)',
                            hintText: 'Select parent category',
                            prefixIcon: Icon(Icons.account_tree),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('None (Root Category)'),
                            ),
                            ...availableParents.map((category) {
                              return DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedParentId = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.largePadding),

                    // Submit button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.defaultPadding,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _isEditing
                                  ? 'Update Category'
                                  : 'Create Category',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
