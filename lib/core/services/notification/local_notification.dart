// lib/core/services/notification/local_notification.dart

import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/routes/app_routes.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../modules/auth/controllers/auth_controller.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle background notification tap
  print('Notification tapped in background');
}
class LocalNotificationService extends GetxService {
  static LocalNotificationService get instance => Get.find();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final AndroidInitializationSettings _androidInitializationSettings =
  const AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings _iOSInitializationSettings =
  const DarwinInitializationSettings();

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
  }

  void _initNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iOSInitializationSettings,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );

    // Create notification channels for Android
    _createNotificationChannels();
  }

  void _createNotificationChannels() {
    if (GetPlatform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
       // priority: Priority.high,
        showBadge: true,
        enableLights: true,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      );

      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      const androidChannel2 = AndroidNotificationChannel(
        'booking_channel',
        'Booking Notifications',
        description: 'Notifications about your bookings.',
        importance: Importance.high,
       // priority: Priority.high,
        showBadge: true,
      );

      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel2);

      const androidChannel3 = AndroidNotificationChannel(
        'payment_channel',
        'Payment Notifications',
        description: 'Notifications about your payments.',
        importance: Importance.high,
        //priority: Priority.high,
        showBadge: true,
      );

      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel3);

      const androidChannel4 = AndroidNotificationChannel(
        'trip_channel',
        'Trip Notifications',
        description: 'Updates about your trips.',
        importance: Importance.high,
        //priority: Priority.high,
        showBadge: true,
      );

      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel4);

      const androidChannel5 = AndroidNotificationChannel(
        'cargo_channel',
        'Cargo Notifications',
        description: 'Updates about your cargo.',
        importance: Importance.high,
        //priority: Priority.high,
        showBadge: true,
      );

      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel5);
    }
  }

  // Show a simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? channelId = 'high_importance_channel',
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId!,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      showWhen: true,
      enableVibration: true,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Show booking notification
  Future<void> showBookingNotification({
    required String ticketId,
    required String route,
    required String time,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Booking Confirmed',
      body: 'Your booking for $route at $time has been confirmed.',
      channelId: 'booking_channel',
      payload: jsonEncode({
        'type': 'booking',
        'ticketId': ticketId,
      }),
    );
  }

  // Show payment notification
  Future<void> showPaymentNotification({
    required String amount,
    required String status,
    String? ticketId,
  }) async {
    final title = status == 'success' ? 'Payment Successful' : 'Payment Failed';
    final body = status == 'success'
        ? 'Your payment of $amount has been processed successfully.'
        : 'Your payment of $amount could not be processed. Please try again.';

    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      channelId: 'payment_channel',
      payload: jsonEncode({
        'type': 'payment',
        'status': status,
        'ticketId': ticketId,
      }),
    );
  }

  // Show trip update notification
  Future<void> showTripUpdateNotification({
    required String tripId,
    required String status,
    required String message,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Trip Update',
      body: message,
      channelId: 'trip_channel',
      payload: jsonEncode({
        'type': 'trip',
        'tripId': tripId,
        'status': status,
      }),
    );
  }

  // Show cargo update notification
  Future<void> showCargoUpdateNotification({
    required String cargoId,
    required String status,
    required String message,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Cargo Update',
      body: message,
      channelId: 'cargo_channel',
      payload: jsonEncode({
        'type': 'cargo',
        'cargoId': cargoId,
        'status': status,
      }),
    );
  }

  // Show reminder notification
  Future<void> showReminderNotification({
    required String tripId,
    required String route,
    required String departureTime,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Trip Reminder',
      body: 'Your trip to $route departs at $departureTime',
      channelId: 'high_importance_channel',
      payload: jsonEncode({
        'type': 'reminder',
        'tripId': tripId,
      }),
    );
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    String? payload,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Notifications scheduled for later',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      platformChannelSpecifics,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get notification details
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;

    try {
      final payload = jsonDecode(response.payload!);
      final type = payload['type'];

      switch (type) {
        case 'booking':
        case 'ticket':
          Get.toNamed(AppRoutes.passengerTicketDetail, arguments: {
            'ticketId': payload['ticketId'],
          });
          break;
        case 'payment':
          if (payload['ticketId'] != null) {
            Get.toNamed(AppRoutes.passengerTicketDetail, arguments: {
              'ticketId': payload['ticketId'],
            });
          }
          break;
        case 'trip':
          final role = Get.find<AuthController>().userRole!;
          if (role == 'driver') {
            Get.toNamed(AppRoutes.driverTripDetail, arguments: {
              'tripId': payload['tripId'],
            });
          } else {
            Get.toNamed(AppRoutes.passengerTripDetail, arguments: {
              'tripId': payload['tripId'],
            });
          }
          break;
        case 'cargo':
          Get.toNamed(AppRoutes.passengerCargoTracking, arguments: {
            'cargoId': payload['cargoId'],
          });
          break;
        case 'reminder':
          Get.toNamed(AppRoutes.passengerTripDetail, arguments: {
            'tripId': payload['tripId'],
          });
          break;
        default:
          Get.toNamed(AppRoutes.passengerNotifications);
      }
    } catch (e) {
      print('Error handling notification tap: $e');
    }
  }

  // Helper method to get channel name
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'booking_channel':
        return 'Booking Notifications';
      case 'payment_channel':
        return 'Payment Notifications';
      case 'trip_channel':
        return 'Trip Notifications';
      case 'cargo_channel':
        return 'Cargo Notifications';
      case 'scheduled_channel':
        return 'Scheduled Notifications';
      default:
        return 'High Importance Notifications';
    }
  }

  // Helper method to get channel description
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'booking_channel':
        return 'Notifications about your bookings';
      case 'payment_channel':
        return 'Notifications about your payments';
      case 'trip_channel':
        return 'Updates about your trips';
      case 'cargo_channel':
        return 'Updates about your cargo';
      case 'scheduled_channel':
        return 'Notifications scheduled for later';
      default:
        return 'This channel is used for important notifications';
    }
  }

  // Check if notifications are enabled
  Future<bool?> areNotificationsEnabled() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled();
    }

    return true; // iOS defaults to true
  }

  // Request notification permissions (iOS)
  Future<void> requestPermissions() async {
    final iOSPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iOSPlugin != null) {
      await iOSPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
}