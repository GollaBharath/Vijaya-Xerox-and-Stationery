import 'package:flutter/material.dart';
import 'package:flutter_shared/api/api_client.dart';
import '../models/user_profile.dart';

/// Profile Provider for managing user profile data
class ProfileProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  ProfileProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch user profile from API
  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/api/v1/me/profile');

      if (response['success'] == true && response['data'] != null) {
        _profile = UserProfile.fromJson(response['data']['user']);
        _error = null;
      } else {
        _error = response['message'] ?? 'Failed to load profile';
      }
    } catch (e) {
      _error = e.toString();
      print('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (city != null) updateData['city'] = city;
      if (state != null) updateData['state'] = state;
      if (pincode != null) updateData['pincode'] = pincode;
      if (landmark != null) updateData['landmark'] = landmark;

      final response = await _apiClient.patch(
        '/api/v1/me/profile',
        body: updateData,
      );

      if (response['success'] == true && response['data'] != null) {
        _profile = UserProfile.fromJson(response['data']['user']);
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update profile';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print('Error updating profile: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear profile data
  void clear() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
