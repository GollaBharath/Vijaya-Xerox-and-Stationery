import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/services/notification_service.dart';

/// Provider for managing notification state and actions
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  /// Stream of incoming notifications (for foreground messages)
  Stream<RemoteMessage>? _messageStream;

  /// Get the message stream
  Stream<RemoteMessage>? get messageStream => _messageStream;

  /// Initialize notifications
  Future<void> initialize() async {
    await _notificationService.initialize();
    
    // Set up message stream for foreground notifications
    _messageStream = FirebaseMessaging.onMessage;
    
    notifyListeners();
  }

  /// Get FCM token
  String? get fcmToken => _notificationService.fcmToken;

  /// Clear all notifications
  Future<void> clearNotifications() async {
    await _notificationService.clearNotifications();
  }

  /// Handle notification tap navigation
  /// This should be called from the main app when a notification is tapped
  void handleNotificationNavigation(RemoteMessage message) {
    final data = message.data;
    
    if (data['type'] == 'order_status_update' && data['orderId'] != null) {
      // Navigation logic will be handled by the app
      // Emit event or use navigation service
      debugPrint('Should navigate to order: ${data['orderId']}');
    }
  }
}
