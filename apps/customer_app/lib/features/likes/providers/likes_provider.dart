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
        // Backend returns { data: { liked, likeCount }, message }
        final data = response['data'] as Map<String, dynamic>?;

        if (data != null) {
          final liked = data['liked'] as bool?;
          final likeCount = data['likeCount'] as int?;

          if (liked != null && likeCount != null) {
            // Update with server values
            _likeCounts[productId] = likeCount;
            if (liked) {
              _likedProductIds.add(productId);
            } else {
              _likedProductIds.remove(productId);
            }
            _error = null;
          } else {
            throw Exception('Invalid response structure');
          }
        } else {
          throw Exception('Invalid response structure');
        }
      } else {
        throw Exception('Invalid response type');
      }
    } catch (e) {
      print('Like error: $e');
      // Revert optimistic update on failure
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

      if (response is Map<String, dynamic>) {
        // Backend returns { data: [{ id, createdAt, product }, ...] }
        final data = response['data'] as List?;

        if (data != null) {
          // Clear previous data
          _likedProductIds.clear();
          _likeCounts.clear();

          // Parse the response - each item has: { id, createdAt, product }
          for (var like in data) {
            final product = like['product'] as Map<String, dynamic>?;
            if (product != null) {
              final productId = product['id'] as String?;
              final likeCount = product['likeCount'] as int? ?? 0;

              if (productId != null) {
                _likedProductIds.add(productId);
                _likeCounts[productId] = likeCount;
                print(
                  '✅ Added liked product: $productId with count $likeCount',
                );
              }
            }
          }
          _error = null;
          print('📦 Loaded ${_likedProductIds.length} liked products');
        } else {
          _error = 'Failed to fetch liked products';
          print('❌ Data is null');
        }
      } else {
        _error = 'Failed to fetch liked products';
        print('❌ Response is not a Map: ${response.runtimeType}');
      }
    } catch (e) {
      _error = 'Network error: $e';
      print('❌ Error fetching liked products: $e');
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
