import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/services/notification_service.dart';

/// Provider for managing notification state and displaying in-app notifications
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  RemoteMessage? _latestNotification;
  String? _notificationMessage;
  
  /// Get the latest notification message
  String? get notificationMessage => _notificationMessage;
  
  /// Get the latest notification
  RemoteMessage? get latestNotification => _latestNotification;

  /// Initialize notification service
  Future<void> initialize() async {
    await _notificationService.initialize();
    
    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _latestNotification = message;
      if (message.notification != null) {
        _notificationMessage = message.notification!.body;
        notifyListeners();
      }
    });
  }

  /// Clear notification message
  void clearNotification() {
    _notificationMessage = null;
    _latestNotification = null;
    notifyListeners();
  }

  /// Get FCM token
  String? get fcmToken => _notificationService.fcmToken;
}
