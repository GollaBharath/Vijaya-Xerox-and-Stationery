import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'dart:convert';
import '../../../core/config/env.dart';

class ProductProvider with ChangeNotifier {
  late final ApiClient _apiClient;

  ProductProvider() {
    final tokenManager = TokenManager();
    _apiClient = ApiClient(tokenManager: tokenManager, baseUrl: Env.baseUrl);
  }

  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  // Getters
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;

  // Fetch products with pagination and filters
  Future<void> fetchProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? subjectId,
    bool? isActive,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        _isLoading = true;
        _error = null;
        notifyListeners();
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (subjectId != null) queryParams['subjectId'] = subjectId;
      // Only add isActive filter if explicitly set (null means show all)
      if (isActive != null) queryParams['isActive'] = isActive.toString();

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final endpoint = queryString.isNotEmpty
          ? '${Endpoints.products}?$queryString'
          : Endpoints.products;

      final response = await _apiClient.get(endpoint);

      // Handle nested response structure
      List<Product> productsList;
      if (response['data'] is Map<String, dynamic>) {
        final data = response['data'] as Map<String, dynamic>;
        productsList = (data['products'] as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response['data'] is List) {
        // Fallback for direct list response
        productsList = (response['data'] as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected response format');
      }

      if (loadMore) {
        _products.addAll(productsList);
      } else {
        _products = productsList;
      }

      final pagination = response['pagination'] as Map<String, dynamic>? ?? {};
      _currentPage = pagination['page'] as int? ?? 1;
      _totalPages = pagination['totalPages'] as int? ?? 1;
      _hasMore = _currentPage < _totalPages;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Fetch single product with variants
  Future<void> fetchProductDetails(String productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiClient.get(Endpoints.product(productId));
      _selectedProduct = Product.fromJson(response['data']);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Create product
  Future<Product> createProduct({
    required String title,
    required String description,
    String? isbn,
    required double basePrice,
    required String subjectId,
    required String fileType, // 'image', 'pdf', or 'none'
    List<String>? categoryIds,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final body = {
        'title': title,
        'description': description,
        'isbn': isbn,
        'basePrice': basePrice,
        'subjectId': subjectId,
        'fileType': fileType,
        'categoryIds': categoryIds ?? [],
      };

      final response = await _apiClient.post(Endpoints.products, body: body);
      final newProduct = Product.fromJson(response['data']);

      // Only add to list if it doesn't already exist (avoid duplicates)
      final existingIndex = _products.indexWhere((p) => p.id == newProduct.id);
      if (existingIndex == -1) {
        _products.insert(0, newProduct);
      }

      _isLoading = false;
      notifyListeners();

      return newProduct;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update product
  Future<Product> updateProduct({
    required String productId,
    String? title,
    String? description,
    String? isbn,
    double? basePrice,
    String? subjectId,
    String? fileType,
    List<String>? categoryIds,
    bool? isActive,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (isbn != null) body['isbn'] = isbn;
      if (basePrice != null) body['basePrice'] = basePrice;
      if (subjectId != null) body['subjectId'] = subjectId;
      if (fileType != null) body['fileType'] = fileType;
      if (categoryIds != null) body['categoryIds'] = categoryIds;
      if (isActive != null) body['isActive'] = isActive;

      final response = await _apiClient.patch(
        Endpoints.product(productId),
        body: body,
      );

      final updatedProduct = Product.fromJson(response['data']);

      // Update in list
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      if (_selectedProduct?.id == productId) {
        _selectedProduct = updatedProduct;
      }

      _isLoading = false;
      notifyListeners();

      return updatedProduct;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Toggle product active status
  Future<void> toggleProductActive(String productId, bool isActive) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await updateProduct(productId: productId, isActive: isActive);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiClient.delete(Endpoints.product(productId));

      _products.removeWhere((p) => p.id == productId);
      if (_selectedProduct?.id == productId) {
        _selectedProduct = null;
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

  // Upload product image (for stationery)
  Future<String> uploadProductImage(String productId, File imageFile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final uri = Uri.parse('${_apiClient.baseUrl}${Endpoints.uploadImage}');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      final tokenManager = TokenManager();
      final token = await tokenManager.getAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file and productId
      final mimeType = _getMimeType(imageFile.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: mimeType != null
              ? http_parser.MediaType.parse(mimeType)
              : null,
        ),
      );
      request.fields['productId'] = productId;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        final imageUrl = data['imageUrl'] as String;

        // Update product in list
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = _products[index].copyWith(imageUrl: imageUrl);
        }

        if (_selectedProduct?.id == productId) {
          _selectedProduct = _selectedProduct!.copyWith(imageUrl: imageUrl);
        }

        _isLoading = false;
        notifyListeners();

        return imageUrl;
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Upload product PDF (for books)
  Future<String> uploadProductPDF(String productId, File pdfFile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final uri = Uri.parse('${_apiClient.baseUrl}${Endpoints.uploadPdf}');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      final tokenManager = TokenManager();
      final token = await tokenManager.getAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file and productId
      request.files.add(
        await http.MultipartFile.fromPath('file', pdfFile.path),
      );
      request.fields['productId'] = productId;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        final pdfUrl = data['pdfUrl'] as String;

        // Update product in list
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = _products[index].copyWith(pdfUrl: pdfUrl);
        }

        if (_selectedProduct?.id == productId) {
          _selectedProduct = _selectedProduct!.copyWith(pdfUrl: pdfUrl);
        }

        _isLoading = false;
        notifyListeners();

        return pdfUrl;
      } else {
        throw Exception('Failed to upload PDF: ${response.body}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete product files
  Future<void> deleteProductFiles(String productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiClient.delete(Endpoints.productFiles(productId));

      // Update product in list
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(
          imageUrl: null,
          pdfUrl: null,
        );
      }

      if (_selectedProduct?.id == productId) {
        _selectedProduct = _selectedProduct!.copyWith(
          imageUrl: null,
          pdfUrl: null,
        );
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

  // Load more products (pagination)
  Future<void> loadMoreProducts({
    String? categoryId,
    String? subjectId,
    bool? isActive,
  }) async {
    if (!_hasMore || _isLoading) return;

    await fetchProducts(
      page: _currentPage + 1,
      categoryId: categoryId,
      subjectId: subjectId,
      isActive: isActive,
      loadMore: true,
    );
  }

  // Clear products
  void clearProducts() {
    _products = [];
    _selectedProduct = null;
    _currentPage = 1;
    _totalPages = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper method to get MIME type from file extension
  String? _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return null;
    }
  }
}
