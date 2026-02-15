import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';

/// Provider for managing subjects
class SubjectProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  // State
  List<Subject> _subjects = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetch;

  // Cache duration (10 minutes)
  static const Duration _cacheDuration = Duration(minutes: 10);

  SubjectProvider(this._apiClient);

  // Getters
  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSubjects => _subjects.isNotEmpty;

  /// Fetch subjects from API with caching
  Future<void> fetchSubjects({bool forceRefresh = false}) async {
    // Check if cache is still valid
    if (!forceRefresh &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      return; // Use cached data
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.subjects);

      if (response is Map<String, dynamic>) {
        if (response['data'] is List) {
          // Case 1: data is a list of subjects
          _subjects = (response['data'] as List)
              .map((json) => Subject.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (response['data'] is Map<String, dynamic>) {
          // Case 2: data is a map containing subjects key
          final data = response['data'] as Map<String, dynamic>;
          if (data['subjects'] is List) {
            _subjects = (data['subjects'] as List)
                .map((json) => Subject.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }
      } else if (response is List) {
        // Fallback if API returns list directly
        _subjects = response
            .map((json) => Subject.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      _lastFetch = DateTime.now();
      _error = null;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('SubjectProvider: Error fetching subjects - $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get root subjects (no parent)
  List<Subject> get rootSubjects {
    return _subjects.where((subj) => !subj.hasParent).toList();
  }

  /// Get child subjects by parent ID
  List<Subject> getChildSubjects(String parentId) {
    return _subjects.where((subj) => subj.parentSubjectId == parentId).toList();
  }

  /// Get subjects by category ID (top-level subjects for a category)
  List<Subject> getSubjectsByCategoryId(String categoryId) {
    return _subjects
        .where(
          (subj) =>
              subj.categoryId == categoryId &&
              subj.parentSubjectId == null,
        )
        .toList();
  }

  /// Get subject by ID
  Subject? getSubjectById(String id) {
    try {
      return _subjects.firstWhere((subj) => subj.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Build hierarchical subject tree
  List<SubjectNode> buildSubjectTree() {
    final nodes = <SubjectNode>[];
    final rootSubjs = rootSubjects;

    for (final subject in rootSubjs) {
      nodes.add(_buildSubjectNode(subject));
    }

    return nodes;
  }

  SubjectNode _buildSubjectNode(Subject subject) {
    final children = getChildSubjects(subject.id);
    return SubjectNode(
      subject: subject,
      children: children.map(_buildSubjectNode).toList(),
    );
  }

  /// Clear cache
  void clearCache() {
    _lastFetch = null;
  }

  /// Format error message
  String _formatError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Failed to load subjects. Please try again.';
  }
}

/// Hierarchical subject node for tree structure
class SubjectNode {
  final Subject subject;
  final List<SubjectNode> children;

  SubjectNode({required this.subject, this.children = const []});

  bool get hasChildren => children.isNotEmpty;
}
