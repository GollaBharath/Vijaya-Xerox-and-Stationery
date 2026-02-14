import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';
import '../../../core/config/env.dart';

class VariantProvider with ChangeNotifier {
  late final ApiClient _apiClient;

  VariantProvider() {
    final tokenManager = TokenManager();
    _apiClient = ApiClient(tokenManager: tokenManager, baseUrl: Env.baseUrl);
  }

  List<ProductVariant> _variants = [];
  ProductVariant? _selectedVariant;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProductVariant> get variants => _variants;
  ProductVariant? get selectedVariant => _selectedVariant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch variants for a product
  Future<void> fetchVariants(String productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiClient.get(
        Endpoints.productVariants(productId),
      );

      final data = response['data'];
      if (data is List) {
        _variants = data
            .map(
              (json) => ProductVariant.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        _variants = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Create variant
  Future<ProductVariant> createVariant({
    required String productId,
    required String variantType,
    required double price,
    required bool stock,
    String? sku,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final body = {
        'variantType': variantType,
        'price': price,
        'stock': stock,
        'sku': sku,
      };

      final response = await _apiClient.post(
        Endpoints.productVariants(productId),
        body: body,
      );

      final newVariant = ProductVariant.fromJson(response['data']);
      _variants.add(newVariant);

      _isLoading = false;
      notifyListeners();

      return newVariant;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update variant
  Future<ProductVariant> updateVariant({
    required String variantId,
    String? variantType,
    double? price,
    bool? stock,
    String? sku,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final body = <String, dynamic>{};
      if (variantType != null) body['variantType'] = variantType;
      if (price != null) body['price'] = price;
      if (stock != null) body['stock'] = stock;
      if (sku != null) body['sku'] = sku;

      final response = await _apiClient.patch(
        Endpoints.variant(variantId),
        body: body,
      );

      final updatedVariant = ProductVariant.fromJson(response['data']);

      // Update in list
      final index = _variants.indexWhere((v) => v.id == variantId);
      if (index != -1) {
        _variants[index] = updatedVariant;
      }

      if (_selectedVariant?.id == variantId) {
        _selectedVariant = updatedVariant;
      }

      _isLoading = false;
      notifyListeners();

      return updatedVariant;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete variant
  Future<void> deleteVariant(String variantId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiClient.delete(Endpoints.variant(variantId));

      _variants.removeWhere((v) => v.id == variantId);
      if (_selectedVariant?.id == variantId) {
        _selectedVariant = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Select variant
  void selectVariant(ProductVariant variant) {
    _selectedVariant = variant;
    notifyListeners();
  }

  // Clear variants
  void clearVariants() {
    _variants = [];
    _selectedVariant = null;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
