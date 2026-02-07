import 'package:flutter/material.dart';
import 'package:flutter_shared/models/category.dart';

/// Widget to render a single category in the tree
class CategoryTreeItem extends StatelessWidget {
  final Category category;
  final int depth;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryTreeItem({
    super.key,
    required this.category,
    required this.depth,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indentation = depth * 24.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.only(
          left: 16 + indentation,
          right: 8,
          top: 4,
          bottom: 4,
        ),
        leading: Icon(
          depth == 0 ? Icons.folder : Icons.subdirectory_arrow_right,
          color: theme.primaryColor,
        ),
        title: Text(
          category.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: depth == 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          'ID: ${category.id}${category.parentId != null ? ' • Parent: ${category.parentId}' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withAlpha(
              (0.6 * 255).toInt(),
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: category.isActive
                    ? Colors.green.withAlpha((0.1 * 255).toInt())
                    : Colors.grey.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category.isActive ? 'Active' : 'Inactive',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: category.isActive
                      ? Colors.green[700]
                      : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit category',
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: theme.colorScheme.error,
              onPressed: onDelete,
              tooltip: 'Delete category',
            ),
          ],
        ),
      ),
    );
  }
}
