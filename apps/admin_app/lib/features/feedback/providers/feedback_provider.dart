import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';
import '../../../core/config/env.dart';

class AdminFeedbackProvider extends ChangeNotifier {
  late final ApiClient _apiClient;

  List<OrderFeedback> _feedbacks = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalFeedbacks = 0;

  // Statistics
  double _averageRating = 0.0;
  Map<int, int> _ratingDistribution = {};

  AdminFeedbackProvider() {
    final tokenManager = TokenManager();
    _apiClient = ApiClient(tokenManager: tokenManager, baseUrl: Env.baseUrl);
  }

  // Getters
  List<OrderFeedback> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalFeedbacks => _totalFeedbacks;
  double get averageRating => _averageRating;
  Map<int, int> get ratingDistribution => _ratingDistribution;
  bool get hasFeedbacks => _feedbacks.isNotEmpty;

  /// Fetch all feedbacks with pagination
  Future<void> fetchFeedbacks({
    int page = 1,
    int limit = 20,
    bool refresh = false,
  }) async {
    if (refresh) {
      _feedbacks = [];
      _currentPage = 1;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '/admin/feedbacks?page=${page.toString()}&limit=${limit.toString()}',
      );

      if (response['data'] != null) {
        _feedbacks = (response['data'] as List)
            .map((json) => OrderFeedback.fromJson(json))
            .toList();
      }

      if (response['pagination'] != null) {
        _currentPage = response['pagination']['page'] ?? page;
        _totalPages = response['pagination']['pages'] ?? 1;
        _totalFeedbacks = response['pagination']['total'] ?? 0;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      _feedbacks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch feedback statistics
  Future<void> fetchStatistics() async {
    try {
      final response = await _apiClient.get('/admin/feedbacks/stats');

      if (response['data'] != null) {
        final data = response['data'];
        _averageRating = (data['averageRating'] ?? 0.0).toDouble();

        if (data['ratingDistribution'] != null) {
          _ratingDistribution = Map<int, int>.from(
            (data['ratingDistribution'] as Map).map(
              (key, value) => MapEntry(int.parse(key.toString()), value as int),
            ),
          );
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching feedback statistics: $e');
    }
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (_currentPage < _totalPages && !_isLoading) {
      await fetchFeedbacks(page: _currentPage + 1);
    }
  }

  /// Refresh feedbacks
  Future<void> refresh() async {
    await fetchFeedbacks(refresh: true);
    await fetchStatistics();
  }
}
