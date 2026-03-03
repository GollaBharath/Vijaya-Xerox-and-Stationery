import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Provider that manages company branding information fetched from the backend.
/// Used throughout the customer app for dynamic company name, tagline, etc.
class BrandingProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  SupportInfo? _supportInfo;
  bool _isLoading = false;
  bool _isInitialized = false;

  BrandingProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  // Getters
  SupportInfo? get supportInfo => _supportInfo;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  /// Company name — falls back to 'Company Name' if not set
  String get companyName => _supportInfo?.shopName ?? 'Company Name';

  /// Tagline — falls back to 'Your One-Stop Shop' if not set
  String get tagline => _supportInfo?.shopTagline ?? 'Your One-Stop Shop';

  /// Copyright text
  String get copyright => '\u00a9 ${DateTime.now().year} $companyName';

  /// Initialize: load from cache first, then fetch fresh data
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load from cache immediately for fast UI
    await _loadFromCache();
    _isInitialized = true;
    notifyListeners();

    // Then fetch fresh from API in background
    await fetchBranding();
  }

  /// Fetch branding info from the API
  Future<void> fetchBranding() async {
    if (_isLoading) return;

    _isLoading = true;
    // Don't notify here to avoid unnecessary rebuilds during background fetch

    try {
      final response = await _apiClient.get('/api/v1/support');

      if (response['success'] == true && response['data'] != null) {
        _supportInfo = SupportInfo.fromJson(response['data']);
        await _saveToCache();
      }
    } catch (e) {
      debugPrint('BrandingProvider: Error fetching branding info: $e');
      // Silently fail — cached or default values will be used
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load cached branding data from SharedPreferences
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('branding_support_info');
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        _supportInfo = SupportInfo.fromJson(json);
      }
    } catch (e) {
      debugPrint('BrandingProvider: Error loading from cache: $e');
    }
  }

  /// Save branding data to SharedPreferences
  Future<void> _saveToCache() async {
    try {
      if (_supportInfo != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'branding_support_info',
          jsonEncode(_supportInfo!.toJson()),
        );
      }
    } catch (e) {
      debugPrint('BrandingProvider: Error saving to cache: $e');
    }
  }
}
