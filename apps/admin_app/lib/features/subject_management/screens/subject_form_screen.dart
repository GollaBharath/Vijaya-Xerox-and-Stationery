import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/constants.dart';
import '../../../routing/route_names.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../providers/subject_provider.dart';

/// Subject form screen for create/edit
class SubjectFormScreen extends StatefulWidget {
  final String? subjectId;

  const SubjectFormScreen({super.key, this.subjectId});

  @override
  State<SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends State<SubjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedParentId;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.subjectId != null;
    if (_isEditing) {
      _loadSubject();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSubject() async {
    setState(() => _isLoading = true);

    final subject = await context.read<SubjectProvider>().fetchSubjectById(
      widget.subjectId!,
    );

    if (subject != null && mounted) {
      _nameController.text = subject.name;
      _selectedParentId = subject.parentSubjectId;
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

    final subjectProvider = context.read<SubjectProvider>();
    bool success;

    if (_isEditing) {
      success = await subjectProvider.updateSubject(
        id: widget.subjectId!,
        name: _nameController.text.trim(),
        parentSubjectId: _selectedParentId,
      );
    } else {
      success = await subjectProvider.createSubject(
        name: _nameController.text.trim(),
        parentSubjectId: _selectedParentId,
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
                  ? 'Subject updated successfully'
                  : 'Subject created successfully',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              subjectProvider.errorMessage ??
                  (_isEditing
                      ? 'Failed to update subject'
                      : 'Failed to create subject'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: _isEditing ? 'Edit Subject' : 'Add Subject',
      currentRoute: RouteNames.subjects,
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
                        labelText: 'Subject Name',
                        hintText: 'Enter subject name',
                        prefixIcon: Icon(Icons.school),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Subject name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Subject name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Parent subject dropdown
                    Consumer<SubjectProvider>(
                      builder: (context, subjectProvider, _) {
                        final availableParents = subjectProvider.subjects
                            .where((subj) => subj.id != widget.subjectId)
                            .toList();

                        return DropdownButtonFormField<String>(
                          initialValue: _selectedParentId,
                          decoration: const InputDecoration(
                            labelText: 'Parent Subject (Optional)',
                            hintText: 'Select parent subject',
                            prefixIcon: Icon(Icons.account_tree),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('None (Root Subject)'),
                            ),
                            ...availableParents.map((subject) {
                              return DropdownMenuItem(
                                value: subject.id,
                                child: Text(subject.name),
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
                              _isEditing ? 'Update Subject' : 'Create Subject',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
