import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_shared/auth/token_manager.dart';
import '../config/env.dart';
import '../config/api_config.dart';

/// Background message handler (top-level function required)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
}

/// Notification Service for handling FCM push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _firebaseMessaging;
  String? _fcmToken;
  
  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging and request permissions
  Future<void> initialize() async {
    try {
      // Try to get FirebaseMessaging instance
      _firebaseMessaging = FirebaseMessaging.instance;
      
      if (_firebaseMessaging == null) {
        debugPrint('FirebaseMessaging not available');
        return;
      }

      // Request permission for iOS
      NotificationSettings settings = await _firebaseMessaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional notification permission');
      } else {
        debugPrint('User declined or has not accepted notification permission');
      }

      // Get FCM token
      _fcmToken = await _firebaseMessaging!.getToken();
      if (_fcmToken != null) {
        debugPrint('FCM Token: $_fcmToken');
        await _registerTokenWithBackend(_fcmToken!);
      }

      // Listen for token refresh
      _firebaseMessaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token refreshed: $newToken');
        _registerTokenWithBackend(newToken);
      });

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message received: ${message.messageId}');
        _handleMessage(message);
      });

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification tapped: ${message.messageId}');
        _handleNotificationTap(message);
      });

    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  /// Register FCM token with backend
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final tokenManager = TokenManager();
      final accessToken = await tokenManager.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('No access token available, skipping FCM token registration');
        return;
      }

      final response = await http.put(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.fcmToken)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM token registered with backend successfully');
      } else {
        debugPrint('Failed to register FCM token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error registering FCM token with backend: $e');
    }
  }

  /// Handle incoming message (foreground)
  void _handleMessage(RemoteMessage message) {
    // Extract notification data
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      debugPrint('Notification Title: ${notification.title}');
      debugPrint('Notification Body: ${notification.body}');
    }

    if (data.isNotEmpty) {
      debugPrint('Message Data: $data');
    }

    // Show in-app notification dialog or snackbar
    // This will be handled by the NotificationProvider
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    
    if (data['type'] == 'order_status_update' && data['orderId'] != null) {
      // Navigate to order details
      debugPrint('Navigate to order: ${data['orderId']}');
      // Navigation will be handled by NotificationProvider
    }
  }

  /// Clear all notifications
  Future<void> clearNotifications() async {
    // Any cleanup logic here
  }
}
