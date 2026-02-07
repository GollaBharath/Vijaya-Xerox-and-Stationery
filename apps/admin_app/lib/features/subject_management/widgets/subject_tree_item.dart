import 'package:flutter/material.dart';
import 'package:flutter_shared/models/subject.dart';

/// Widget to render a single subject in the tree
class SubjectTreeItem extends StatelessWidget {
  final Subject subject;
  final int depth;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubjectTreeItem({
    super.key,
    required this.subject,
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
          depth == 0 ? Icons.school : Icons.subdirectory_arrow_right,
          color: theme.primaryColor,
        ),
        title: Text(
          subject.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: depth == 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          'ID: ${subject.id}${subject.parentSubjectId != null ? ' • Parent: ${subject.parentSubjectId}' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withAlpha(
              (0.6 * 255).toInt(),
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit subject',
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: theme.colorScheme.error,
              onPressed: onDelete,
              tooltip: 'Delete subject',
            ),
          ],
        ),
      ),
    );
  }
}
