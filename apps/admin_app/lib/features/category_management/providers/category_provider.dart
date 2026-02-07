import 'package:flutter/foundation.dart';
import 'package:flutter_shared/models/category.dart' as shared_models;
import 'package:flutter_shared/api/api_client.dart';
import 'package:flutter_shared/api/endpoints.dart';
import 'package:flutter_shared/auth/token_manager.dart';
import '../../../core/config/env.dart';
import '../../../core/errors/app_exceptions.dart' as local_exceptions;

/// Category management provider
class CategoryProvider extends ChangeNotifier {
  late final ApiClient _apiClient;

  List<shared_models.Category> _categories = [];
  shared_models.Category? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  CategoryProvider() {
    final tokenManager = TokenManager();
    _apiClient = ApiClient(tokenManager: tokenManager, baseUrl: Env.baseUrl);
  }

  // Getters
  List<shared_models.Category> get categories => _categories;
  shared_models.Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get hierarchical category tree
  List<shared_models.Category> get categoryTree {
    // Build tree structure from flat list
    final rootCategories = _categories
        .where((cat) => cat.parentId == null)
        .toList();
    return _buildCategoryTree(rootCategories);
  }

  List<shared_models.Category> _buildCategoryTree(
    List<shared_models.Category> categories,
  ) {
    final result = <shared_models.Category>[];
    for (final category in categories) {
      final children = _categories
          .where((cat) => cat.parentId == category.id)
          .toList();
      result.add(category);
      if (children.isNotEmpty) {
        result.addAll(_buildCategoryTree(children));
      }
    }
    return result;
  }

  /// Fetch all categories
  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('📂 Fetching categories...');
      final response = await _apiClient.get(
        '${ApiEndpoints.categoriesRoot}?isActive=true',
      );
      print('📂 Response: $response');
      final data = (response['data'] as List<dynamic>?) ?? [];
      print('📂 Data count: ${data.length}');

      _categories = data
          .map(
            (json) =>
                shared_models.Category.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      print('📂 Categories loaded: ${_categories.length}');
      _isLoading = false;
      notifyListeners();
    } catch (e, stack) {
      print('❌ Fetch categories error: $e');
      print('❌ Stack: $stack');
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch single category by ID
  Future<shared_models.Category?> fetchCategoryById(String id) async {
    try {
      _errorMessage = null;

      final response = await _apiClient.get(
        '${ApiEndpoints.categoriesRoot}/$id',
      );
      _selectedCategory = shared_models.Category.fromJson(
        response['data'] as Map<String, dynamic>,
      );

      notifyListeners();
      return _selectedCategory;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Create new category
  Future<bool> createCategory({
    required String name,
    String? parentId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final body = {
        'name': name,
        if (parentId != null) 'parent_id': parentId,
        if (metadata != null) 'metadata': metadata,
      };

      print('📝 Creating category: $body');
      final response = await _apiClient.post(
        ApiEndpoints.categoriesRoot,
        body: body,
      );
      print('📝 Create response: $response');

      final newCategory = shared_models.Category.fromJson(
        response['data'] as Map<String, dynamic>,
      );
      _categories.add(newCategory);

      print('✅ Category created: ${newCategory.name}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stack) {
      print('❌ Create category error: $e');
      print('❌ Stack: $stack');
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update existing category
  Future<bool> updateCategory({
    required String id,
    String? name,
    String? parentId,
    Map<String, dynamic>? metadata,
    bool? isActive,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (parentId != null) body['parent_id'] = parentId;
      if (metadata != null) body['metadata'] = metadata;
      if (isActive != null) body['is_active'] = isActive;

      final response = await _apiClient.patch(
        '${ApiEndpoints.categoriesRoot}/$id',
        body: body,
      );

      final updatedCategory = shared_models.Category.fromJson(
        response['data'] as Map<String, dynamic>,
      );
      final index = _categories.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
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

  /// Delete category
  Future<bool> deleteCategory(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _apiClient.delete('${ApiEndpoints.categoriesRoot}/$id');

      _categories.removeWhere((cat) => cat.id == id);

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

  /// Clear selected category
  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is local_exceptions.UnauthorizedException) {
      return 'Session expired. Please login again.';
    } else if (error is local_exceptions.ForbiddenException) {
      return 'Access denied. Admin privileges required.';
    } else if (error is local_exceptions.ValidationException) {
      return error.message;
    } else if (error is local_exceptions.ConnectionException) {
      return 'No internet connection.';
    } else if (error is local_exceptions.AppException) {
      return error.message;
    } else {
      return 'An error occurred. Please try again.';
    }
  }
}
