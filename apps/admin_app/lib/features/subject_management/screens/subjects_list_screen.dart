import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/config/constants.dart';
import '../../../routing/route_names.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../../category_management/providers/category_provider.dart';
import '../providers/subject_provider.dart';

/// Subjects list screen with tree view
class SubjectsListScreen extends StatefulWidget {
  const SubjectsListScreen({super.key});

  @override
  State<SubjectsListScreen> createState() => _SubjectsListScreenState();
}

class _SubjectsListScreenState extends State<SubjectsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().fetchSubjects();
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      context.read<SubjectProvider>().fetchSubjects(),
      context.read<CategoryProvider>().fetchCategories(),
    ]);
  }

  void _navigateToForm({String? subjectId}) {
    Navigator.of(
      context,
    ).pushNamed(RouteNames.subjectForm, arguments: subjectId);
  }

  Future<void> _handleDelete(String subjectId, String subjectName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "$subjectName"?'),
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

    if (confirmed ?? false) {
      if (mounted) {
        final success = await context.read<SubjectProvider>().deleteSubject(
          subjectId,
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Subject deleted successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.read<SubjectProvider>().errorMessage ??
                      'Failed to delete subject',
                ),
              ),
            );
          }
        }
      }
    }
  }

  String _getCategoryName(String categoryId, CategoryProvider categoryProvider) {
    final category = categoryProvider.categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => categoryProvider.categories.first,
    );
    return category.name;
  }

  Widget _buildSubjectTree(
    dynamic subject,
    List<dynamic> allSubjects,
    CategoryProvider categoryProvider,
  ) {
    // Get children of this subject
    final children = allSubjects
        .where((s) => s.parentSubjectId == subject.id)
        .toList();

    final hasChildren = children.isNotEmpty;
    final categoryName = _getCategoryName(subject.categoryId, categoryProvider);

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
                  color: Color(0xFF2196F3),
                ),
                title: Text(
                  subject.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category,
                              size: 12,
                              color: const Color(0xFF9C27B0),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              categoryName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9C27B0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${children.length} sub-subject${children.length != 1 ? 's' : ''}',
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
                      onPressed: () => _navigateToForm(subjectId: subject.id),
                      tooltip: 'Edit',
                      color: Colors.blue.shade700,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _handleDelete(subject.id, subject.name),
                      tooltip: 'Delete',
                      color: Colors.red.shade700,
                    ),
                  ],
                ),
                children: children
                    .map((child) => _buildSubjectTree(child, allSubjects, categoryProvider))
                    .toList(),
              ),
            )
          : ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.article_outlined,
                color: Color(0xFF9C27B0),
              ),
              title: Text(
                subject.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              subtitle: Container(
                margin: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category,
                            size: 12,
                            color: const Color(0xFF9C27B0),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            categoryName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9C27B0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF4CAF50),
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
                    onPressed: () => _navigateToForm(subjectId: subject.id),
                    tooltip: 'Edit',
                    color: Colors.blue.shade700,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _handleDelete(subject.id, subject.name),
                    tooltip: 'Delete',
                    color: Colors.red.shade700,
                  ),
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Subjects',
      currentRoute: RouteNames.subjects,
      body: Consumer2<SubjectProvider, CategoryProvider>(
        builder: (context, subjectProvider, categoryProvider, _) {
          if ((subjectProvider.isLoading && subjectProvider.subjects.isEmpty) ||
              (categoryProvider.isLoading && categoryProvider.categories.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (subjectProvider.errorMessage != null &&
              subjectProvider.subjects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      subjectProvider.errorMessage!,
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

          if (subjectProvider.subjects.isEmpty) {
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
                      'No subjects yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'Tap the + button to create your first subject',
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
                      'No categories found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'Please create categories first',
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

          final subjects = subjectProvider.subjectTree;
          final allSubjects = subjectProvider.subjects;

          // Get only root subjects (no parent)
          final rootSubjects = subjects
              .where((s) => s.parentSubjectId == null)
              .toList();

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: rootSubjects.length,
              itemBuilder: (context, index) {
                final subject = rootSubjects[index];
                return _buildSubjectTree(subject, allSubjects, categoryProvider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        tooltip: 'Add subject',
        child: const Icon(Icons.add),
      ),
    );
  }
}
