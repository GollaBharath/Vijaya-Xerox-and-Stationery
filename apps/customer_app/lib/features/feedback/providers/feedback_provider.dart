import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';

class FeedbackProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  bool _isSubmitting = false;
  String? _error;

  FeedbackProvider(this._apiClient);

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  /// Submit feedback for an order
  Future<bool> submitFeedback({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.post(
        '/orders/$orderId/feedback',
        body: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );

      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Get feedback for an order
  Future<OrderFeedback?> getFeedbackForOrder(String orderId) async {
    try {
      final response = await _apiClient.get('/orders/$orderId/feedback');
      if (response['data'] != null) {
        return OrderFeedback.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
