import 'package:flutter/foundation.dart';
import 'package:flutter_shared/models/product.dart';
import 'package:flutter_shared/api/api_client.dart';

class LikesProvider with ChangeNotifier {
  final ApiClient apiClient;

  LikesProvider({required this.apiClient});

  Set<String> _likedProductIds = {};
  Map<String, int> _likeCounts = {};
  bool _isLoading = false;
  String? _error;

  Set<String> get likedProductIds => _likedProductIds;
  Map<String, int> get likeCounts => _likeCounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isLiked(String productId) => _likedProductIds.contains(productId);
  int getLikeCount(String productId) => _likeCounts[productId] ?? 0;

  Future<void> toggleLike(Product product) async {
    // Check if user is authenticated
    final token = await apiClient.tokenManager.getAccessToken();
    if (token == null) {
      _error = 'You must be logged in to like products';
      notifyListeners();
      return;
    }

    final productId = product.id;
    final wasLiked = isLiked(productId);

    // Optimistic update
    if (wasLiked) {
      _likedProductIds.remove(productId);
      _likeCounts[productId] = (_likeCounts[productId] ?? 1) - 1;
    } else {
      _likedProductIds.add(productId);
      _likeCounts[productId] = (_likeCounts[productId] ?? 0) + 1;
    }
    notifyListeners();

    try {
      final response = await apiClient.post('/api/v1/products/$productId/like');

      if (response is Map<String, dynamic>) {
        _likeCounts[productId] = response['likeCount'] as int;
        if (response['liked'] == true) {
          _likedProductIds.add(productId);
        } else {
          _likedProductIds.remove(productId);
        }
        _error = null;
      } else {
        // Revert optimistic update
        if (wasLiked) {
          _likedProductIds.add(productId);
          _likeCounts[productId] = (_likeCounts[productId] ?? 0) + 1;
        } else {
          _likedProductIds.remove(productId);
          _likeCounts[productId] = (_likeCounts[productId] ?? 1) - 1;
        }
        _error = 'Failed to update like';
      }
    } catch (e) {
      // Revert optimistic update
      if (wasLiked) {
        _likedProductIds.add(productId);
        _likeCounts[productId] = (_likeCounts[productId] ?? 0) + 1;
      } else {
        _likedProductIds.remove(productId);
        _likeCounts[productId] = (_likeCounts[productId] ?? 1) - 1;
      }
      _error = 'Network error: $e';
    }

    notifyListeners();
  }

  Future<void> fetchLikedProducts() async {
    final token = await apiClient.tokenManager.getAccessToken();
    if (token == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiClient.get('/api/v1/me/likes');

      if (response is List) {
        _likedProductIds = response.map((p) => p['id'] as String).toSet();
        for (var product in response) {
          _likeCounts[product['id']] = product['likeCount'] ?? 0;
        }
        _error = null;
      } else {
        _error = 'Failed to fetch liked products';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFromProduct(Product product) {
    if (product.isLikedByUser) {
      _likedProductIds.add(product.id);
    }
    _likeCounts[product.id] = product.likeCount;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
