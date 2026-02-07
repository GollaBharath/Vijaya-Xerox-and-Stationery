import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/config/constants.dart';
import '../../../routing/route_names.dart';
import '../providers/subject_provider.dart';
import '../widgets/subject_tree_item.dart';

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
    });
  }

  Future<void> _handleRefresh() async {
    await context.read<SubjectProvider>().fetchSubjects();
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

  int _getSubjectDepth(String subjectId, List<SubjectData> subjects) {
    int depth = 0;
    String? currentId = subjectId;

    while (currentId != null) {
      final subject = subjects.firstWhere(
        (s) => s.id == currentId,
        orElse: () => SubjectData(id: '', name: '', parentSubjectId: null),
      );
      if (subject.name.isEmpty) break;
      currentId = subject.parentSubjectId;
      depth++;
    }

    return depth - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: Consumer<SubjectProvider>(
        builder: (context, subjectProvider, _) {
          if (subjectProvider.isLoading && subjectProvider.subjects.isEmpty) {
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

          final subjects = subjectProvider.subjectTree;
          final subjectDataList = subjectProvider.subjects
              .map(
                (s) => SubjectData(
                  id: s.id,
                  name: s.name,
                  parentSubjectId: s.parentSubjectId,
                ),
              )
              .toList();

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final depth = _getSubjectDepth(subject.id, subjectDataList);

                return SubjectTreeItem(
                  subject: subject,
                  depth: depth,
                  onEdit: () => _navigateToForm(subjectId: subject.id),
                  onDelete: () => _handleDelete(subject.id, subject.name),
                );
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

/// Helper class for depth calculation
class SubjectData {
  final String id;
  final String name;
  final String? parentSubjectId;

  SubjectData({
    required this.id,
    required this.name,
    required this.parentSubjectId,
  });
}
