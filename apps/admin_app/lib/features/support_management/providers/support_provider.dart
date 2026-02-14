// Support Provider

import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';
import '../../../core/config/env.dart';

class SupportProvider with ChangeNotifier {
  final ApiClient _apiClient;

  SupportProvider({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          ApiClient(baseUrl: Env.baseUrl, tokenManager: TokenManager());

  SupportInfo? _supportInfo;
  bool _isLoading = false;
  String? _errorMessage;

  SupportInfo? get supportInfo => _supportInfo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch support information
  Future<void> fetchSupportInfo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/admin/support');

      if (response['success'] == true && response['data'] != null) {
        _supportInfo = SupportInfo.fromJson(response['data']);
        _errorMessage = null;
      } else {
        _errorMessage = response['error'] ?? 'Failed to fetch support info';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      debugPrint('Error fetching support info: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update support information
  Future<bool> updateSupportInfo(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.patch('/admin/support', body: data);

      if (response['success'] == true && response['data'] != null) {
        _supportInfo = SupportInfo.fromJson(response['data']);
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['error'] ?? 'Failed to update support info';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      debugPrint('Error updating support info: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
