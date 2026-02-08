import 'package:flutter/foundation.dart';
import 'package:flutter_shared/api/api_client.dart';
import 'package:flutter_shared/api/endpoints.dart';
import 'package:flutter_shared/auth/token_manager.dart';
import '../../../core/config/env.dart';
import '../../../core/errors/app_exceptions.dart' as local_exceptions;

/// Dashboard statistics model
class DashboardStats {
  final int totalUsers;
  final int totalOrders;
  final double totalRevenue;
  final List<RecentOrder> recentOrders;

  DashboardStats({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalRevenue,
    required this.recentOrders,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      recentOrders:
          (json['recentOrders'] as List<dynamic>?)
              ?.map((e) => RecentOrder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Recent order model for dashboard
class RecentOrder {
  final String id;
  final String userName;
  final String status;
  final double totalPrice;
  final DateTime createdAt;

  RecentOrder({
    required this.id,
    required this.userName,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      id: json['id'] as String,
      userName: (json['userName'] ?? json['user_name']) as String? ?? 'Unknown',
      status: (json['status'] ?? 'UNKNOWN') as String,
      totalPrice:
          ((json['totalPrice'] ?? json['total_price']) as num?)?.toDouble() ??
          0.0,
      createdAt: DateTime.parse(
        (json['createdAt'] ?? json['created_at']) as String,
      ),
    );
  }
}

/// Dashboard provider for admin statistics
class DashboardProvider extends ChangeNotifier {
  late final ApiClient _apiClient;

  DashboardStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardProvider() {
    final tokenManager = TokenManager();
    _apiClient = ApiClient(tokenManager: tokenManager, baseUrl: Env.baseUrl);
  }

  // Getters
  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch dashboard statistics
  Future<void> fetchDashboardStats() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.get(ApiEndpoints.adminDashboard);

      _stats = DashboardStats.fromJson(
        response['data'] as Map<String, dynamic>,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
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
    } else if (error is local_exceptions.ConnectionException) {
      return 'No internet connection.';
    } else if (error is local_exceptions.AppException) {
      return error.message;
    } else {
      return 'Failed to load dashboard data.';
    }
  }
}
