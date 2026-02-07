import 'package:flutter/material.dart';
import 'package:flutter_shared/api/api_client.dart';
import 'package:flutter_shared/api/endpoints.dart';
import 'package:flutter_shared/auth/token_manager.dart';
import 'package:flutter_shared/models/user.dart';
import '../../../core/config/env.dart';

/// Provider for managing users in the admin panel
/// Handles fetching, viewing, updating, and deleting user accounts
class UserProvider extends ChangeNotifier {
  final TokenManager _tokenManager = TokenManager();
  late final ApiClient _apiClient;

  // State properties
  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  String _roleFilter = 'ALL'; // ALL, CUSTOMER, ADMIN
  bool? _isActiveFilter; // null = all, true = active, false = inactive

  // Getters
  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;
  String get roleFilter => _roleFilter;
  bool? get isActiveFilter => _isActiveFilter;

  UserProvider() {
    _apiClient = ApiClient(baseUrl: Env.baseUrl, tokenManager: _tokenManager);
  }

  /// Fetch all users with pagination and filters
  /// [page] - Page number (1-based)
  /// [limit] - Items per page (default 20)
  /// [roleFilter] - Filter by user role (CUSTOMER, ADMIN, or ALL)
  /// [isActive] - Filter by active/inactive status
  Future<void> fetchAllUsers({
    int page = 1,
    int limit = 20,
    String? roleFilter,
    bool? isActive,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      _currentPage = page;
      _roleFilter = roleFilter ?? 'ALL';
      _isActiveFilter = isActive;
      notifyListeners();

      // Build query parameters
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (roleFilter != null && roleFilter != 'ALL') {
        params['role'] = roleFilter;
      }
      if (isActive != null) {
        params['isActive'] = isActive.toString();
      }

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final endpoint = queryString.isNotEmpty
          ? '${Endpoints.adminUsers}?$queryString'
          : Endpoints.adminUsers;

      final response = await _apiClient.get(endpoint);

      // Handle different response structures
      List<dynamic> usersData = [];
      int totalPages = 1;

      if (response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          // Structure: { success: true, data: [...] }
          final data = response['data'];
          if (data is List) {
            usersData = data;
          } else if (data is Map<String, dynamic> && data['users'] is List) {
            // Structure: { success: true, data: { users: [...] } }
            usersData = data['users'] as List;
          }

          final pagination = response['pagination'] as Map<String, dynamic>?;
          totalPages = pagination?['totalPages'] as int? ?? 1;
        } else if (response['users'] is List) {
          // Structure: { users: [...] }
          usersData = response['users'] as List;
        }
      } else if (response is List) {
        // Direct list response
        usersData = response;
      }

      _totalPages = totalPages;
      _hasMore = page < _totalPages;

      if (page == 1) {
        _users = usersData
            .map((u) => User.fromJson(u as Map<String, dynamic>))
            .toList();
      } else {
        _users.addAll(
          usersData
              .map((u) => User.fromJson(u as Map<String, dynamic>))
              .toList(),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching users: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Fetch details for a specific user
  /// [userId] - ID of the user to fetch
  Future<void> fetchUserDetails(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiClient.get(Endpoints.adminUser(userId));

      if (response['success'] == true) {
        _selectedUser = User.fromJson(response['data']);
        _isLoading = false;
        notifyListeners();
      } else {
        throw response['error']?['message'] ?? 'Failed to fetch user details';
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching user details: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Update user details
  /// [userId] - ID of the user to update
  /// [name] - User name (optional)
  /// [email] - User email (optional)
  /// [phone] - User phone (optional)
  /// [role] - User role: CUSTOMER or ADMIN (optional)
  /// [isActive] - User active status (optional)
  /// [password] - New password (optional)
  Future<void> updateUser(
    String userId, {
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    String? password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (role != null) body['role'] = role;
      if (isActive != null) body['isActive'] = isActive;
      if (password != null) body['password'] = password;

      final response = await _apiClient.patch(
        Endpoints.adminUser(userId),
        body: body,
      );

      if (response['success'] == true) {
        final updatedUser = User.fromJson(response['data']);

        // Update selected user if it's the one being edited
        if (_selectedUser?.id == userId) {
          _selectedUser = updatedUser;
        }

        // Update in list
        final index = _users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          _users[index] = updatedUser;
        }

        _isLoading = false;
        notifyListeners();
      } else {
        throw response['error']?['message'] ?? 'Failed to update user';
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error updating user: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Delete (deactivate) a user
  /// [userId] - ID of the user to delete
  Future<void> deleteUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiClient.delete(Endpoints.adminUser(userId));

      if (response['success'] == true) {
        // Remove from list
        _users.removeWhere((u) => u.id == userId);

        // Clear selected if it was the deleted user
        if (_selectedUser?.id == userId) {
          _selectedUser = null;
        }

        _isLoading = false;
        notifyListeners();
      } else {
        throw response['error']?['message'] ?? 'Failed to delete user';
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error deleting user: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Clear the selected user
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  /// Clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
