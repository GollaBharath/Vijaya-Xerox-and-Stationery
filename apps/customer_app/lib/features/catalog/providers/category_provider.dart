import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_shared/flutter_shared.dart';

/// Provider for managing categories
class CategoryProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  // State
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetch;

  // Cache duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);

  CategoryProvider(this._apiClient);

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCategories => _categories.isNotEmpty;

  /// Fetch categories from API with caching
  Future<void> fetchCategories({bool forceRefresh = false}) async {
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
      final response = await _apiClient.get(ApiEndpoints.categories);

      if (response is Map<String, dynamic> &&
          response['data'] is Map<String, dynamic>) {
        final data = response['data'] as Map<String, dynamic>;

        if (data['categories'] is List) {
          _categories = (data['categories'] as List)
              .map((json) => Category.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } else if (response is List) {
        // Fallback if API returns list directly
        _categories = response
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      _lastFetch = DateTime.now();
      _error = null;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('CategoryProvider: Error fetching categories - $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get active categories only
  List<Category> get activeCategories {
    return _categories.where((cat) => cat.isActive).toList();
  }

  /// Get root categories (no parent)
  List<Category> get rootCategories {
    return _categories.where((cat) => !cat.hasParent && cat.isActive).toList();
  }

  /// Get child categories by parent ID
  List<Category> getChildCategories(String parentId) {
    return _categories
        .where((cat) => cat.parentId == parentId && cat.isActive)
        .toList();
  }

  /// Get category by ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
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
    return 'Failed to load categories. Please try again.';
  }
}
