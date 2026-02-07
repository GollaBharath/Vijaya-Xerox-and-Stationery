import 'package:flutter/foundation.dart';
import 'package:flutter_shared/api/api_client.dart';
import 'package:flutter_shared/api/endpoints.dart';
import 'package:flutter_shared/auth/token_manager.dart';
import '../../../core/config/env.dart';

class SettingsProvider extends ChangeNotifier {
  late final ApiClient _apiClient;

  Map<String, dynamic> _settings = {};
  bool _isLoading = false;
  String? _errorMessage;

  SettingsProvider() {
    final tokenManager = TokenManager();
    _apiClient = ApiClient(tokenManager: tokenManager, baseUrl: Env.baseUrl);
  }

  Map<String, dynamic> get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSettings() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.get(Endpoints.adminSettings);
      if (response['success'] != true) {
        throw response['error']?['message'] ?? 'Failed to load settings';
      }

      final data = response['data'] as List<dynamic>;
      final updated = <String, dynamic>{};
      for (final item in data) {
        final setting = item as Map<String, dynamic>;
        final key = setting['key'] as String;
        updated[key] = setting['valueJson'];
      }

      _settings = updated;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading settings: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateSetting(String key, Map<String, dynamic> valueJson) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.post(
        Endpoints.adminSettings,
        body: {'key': key, 'valueJson': valueJson},
      );

      if (response['success'] != true) {
        throw response['error']?['message'] ?? 'Failed to update setting';
      }

      _settings = {..._settings, key: valueJson};

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error updating setting: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  bool getBool(String key, {bool defaultValue = false}) {
    final value = _settings[key];
    if (value is Map<String, dynamic> && value['enabled'] is bool) {
      return value['enabled'] as bool;
    }
    return defaultValue;
  }

  int getInt(String key, {int defaultValue = 0}) {
    final value = _settings[key];
    if (value is Map<String, dynamic>) {
      final raw = value['value'];
      if (raw is int) return raw;
      if (raw is String) return int.tryParse(raw) ?? defaultValue;
      if (raw is double) return raw.toInt();
    }
    return defaultValue;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
