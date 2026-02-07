import 'package:flutter/foundation.dart';
import 'package:flutter_shared/models/subject.dart' as shared_models;
import 'package:flutter_shared/api/api_client.dart';
import 'package:flutter_shared/api/endpoints.dart';
import 'package:flutter_shared/auth/token_manager.dart';
import '../../../core/config/env.dart';
import '../../../core/errors/app_exceptions.dart' as local_exceptions;

/// Subject management provider
class SubjectProvider extends ChangeNotifier {
  late final ApiClient _apiClient;

  List<shared_models.Subject> _subjects = [];
  shared_models.Subject? _selectedSubject;
  bool _isLoading = false;
  String? _errorMessage;

  SubjectProvider() {
    final tokenManager = TokenManager();
    _apiClient = ApiClient(tokenManager: tokenManager, baseUrl: Env.baseUrl);
  }

  // Getters
  List<shared_models.Subject> get subjects => _subjects;
  shared_models.Subject? get selectedSubject => _selectedSubject;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get hierarchical subject tree
  List<shared_models.Subject> get subjectTree {
    // Build tree structure from flat list
    final rootSubjects = _subjects
        .where((subj) => subj.parentSubjectId == null)
        .toList();
    return _buildSubjectTree(rootSubjects);
  }

  List<shared_models.Subject> _buildSubjectTree(
    List<shared_models.Subject> subjects,
  ) {
    final result = <shared_models.Subject>[];
    for (final subject in subjects) {
      final children = _subjects
          .where((subj) => subj.parentSubjectId == subject.id)
          .toList();
      result.add(subject);
      if (children.isNotEmpty) {
        result.addAll(_buildSubjectTree(children));
      }
    }
    return result;
  }

  /// Fetch all subjects
  Future<void> fetchSubjects() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.get(ApiEndpoints.subjectsRoot);
      final data = (response['data'] as List<dynamic>?) ?? [];

      _subjects = data
          .map(
            (json) =>
                shared_models.Subject.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch single subject by ID
  Future<shared_models.Subject?> fetchSubjectById(String id) async {
    try {
      _errorMessage = null;

      final response = await _apiClient.get('${ApiEndpoints.subjectsRoot}/$id');
      _selectedSubject = shared_models.Subject.fromJson(
        response['data'] as Map<String, dynamic>,
      );

      notifyListeners();
      return _selectedSubject;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Create new subject
  Future<bool> createSubject({
    required String name,
    String? parentSubjectId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final body = {
        'name': name,
        if (parentSubjectId != null) 'parent_subject_id': parentSubjectId,
      };

      final response = await _apiClient.post(
        ApiEndpoints.subjectsRoot,
        body: body,
      );

      final newSubject = shared_models.Subject.fromJson(
        response['data'] as Map<String, dynamic>,
      );
      _subjects.add(newSubject);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update existing subject
  Future<bool> updateSubject({
    required String id,
    String? name,
    String? parentSubjectId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (parentSubjectId != null) body['parent_subject_id'] = parentSubjectId;

      final response = await _apiClient.patch(
        '${ApiEndpoints.subjectsRoot}/$id',
        body: body,
      );

      final updatedSubject = shared_models.Subject.fromJson(
        response['data'] as Map<String, dynamic>,
      );
      final index = _subjects.indexWhere((subj) => subj.id == id);
      if (index != -1) {
        _subjects[index] = updatedSubject;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete subject
  Future<bool> deleteSubject(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _apiClient.delete('${ApiEndpoints.subjectsRoot}/$id');

      _subjects.removeWhere((subj) => subj.id == id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is local_exceptions.NetworkException) {
      return error.message;
    } else if (error is local_exceptions.ValidationException) {
      return error.message;
    } else if (error is local_exceptions.ServerException) {
      return error.message;
    } else if (error is local_exceptions.UnauthorizedException) {
      return 'Unauthorized access';
    } else if (error is local_exceptions.NotFoundException) {
      return 'Subject not found';
    } else {
      return 'An error occurred';
    }
  }
}
