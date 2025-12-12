import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/certificate_model.dart';

/// Service for handling push notifications
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification service (mobile only)
  static Future<void> initialize() async {
    // Skip on web - Firebase Messaging doesn't work on web
    if (kIsWeb) {
      print('NotificationService: Skipping initialization on web');
      return;
    }

    try {
      // Request permission for iOS
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      }

      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Get FCM token
      String? token = await _messaging.getToken();
      print('FCM Token: $token');
    } catch (e) {
      print('NotificationService initialization error: $e');
      // Continue anyway - notifications are not critical
    }
  }

  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    // Navigate to appropriate screen based on notification payload
    print('Notification tapped: ${response.payload}');
  }

  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification when app is in foreground
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'barangay_channel',
          'Barangay Notifications',
          channelDescription: 'Notifications for reports and announcements',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data.toString(),
    );
  }

  /// Handle background messages
  static void _handleBackgroundMessage(RemoteMessage message) {
    // Navigate to appropriate screen
    print('Background message received: ${message.data}');
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Send local notification
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'barangay_channel',
          'Barangay Notifications',
          channelDescription: 'Notifications for reports and announcements',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// Notify user about report status change
  static Future<void> notifyReportStatusChange({
    required String reportId,
    required String status,
    required String issueType,
  }) async {
    await showLocalNotification(
      title: 'Report Status Updated',
      body: 'Your $issueType report is now $status',
      payload: 'report:$reportId',
    );
  }

  /// Notify user about new announcement
  static Future<void> notifyNewAnnouncement({
    required String title,
  }) async {
    await showLocalNotification(
      title: 'New Announcement',
      body: title,
      payload: 'announcement',
    );
  }

  /// Notify user about new event
  static Future<void> notifyNewEvent({
    required String eventTitle,
  }) async {
    await showLocalNotification(
      title: 'New Barangay Event',
      body: eventTitle,
      payload: 'event',
    );
  }

  /// Notify user about service request update
  static Future<void> notifyServiceRequestUpdate({
    required String serviceType,
    required String status,
  }) async {
    await showLocalNotification(
      title: 'Service Request Updated',
      body: 'Your $serviceType request is now $status',
      payload: 'service_request',
    );
  }

  /// Notify user about event reminder
  static Future<void> notifyEventReminder({
    required String eventTitle,
    required DateTime eventDate,
  }) async {
    await showLocalNotification(
      title: 'Event Reminder',
      body: '$eventTitle is happening soon!',
      payload: 'event_reminder',
    );
  }

  /// Notify admins about certificate request
  static Future<void> sendCertificateRequestNotification({
    required String certificateId,
    required String userName,
    required String certificateType,
  }) async {
    await showLocalNotification(
      title: 'New Certificate Request',
      body: '$userName requested a ${CertificateTypes.getDisplayName(certificateType)}',
      payload: 'certificate:$certificateId',
    );
  }

  /// Notify user about certificate status update
  static Future<void> sendCertificateStatusUpdateNotification({
    required String userId,
    required String certificateType,
    required String status,
  }) async {
    final statusText = status == CertificateStatus.approved
        ? 'approved'
        : status == CertificateStatus.issued
            ? 'issued'
            : status == CertificateStatus.rejected
                ? 'rejected'
                : status;
    
    await showLocalNotification(
      title: 'Certificate Status Updated',
      body: 'Your ${CertificateTypes.getDisplayName(certificateType)} has been $statusText',
      payload: 'certificate:$status',
    );
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

