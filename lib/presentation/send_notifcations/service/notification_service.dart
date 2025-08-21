import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification channel IDs
  static const String _movieSuggestionsChannelId = 'movie_suggestions_channel';
  static const String _scheduledMovieChannelId = 'movie_suggestions_scheduled';

  static Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Enhanced Android settings for background notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    // Request all necessary permissions
    await _requestPermissions();
  }

  static Future<void> _createNotificationChannels() async {
    // High importance channel for immediate notifications
    const AndroidNotificationChannel movieSuggestionsChannel =
        AndroidNotificationChannel(
      _movieSuggestionsChannelId,
      'Movie Suggestions',
      description: 'Notifications for movie suggestions',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // High importance channel for scheduled notifications
    const AndroidNotificationChannel scheduledMovieChannel =
        AndroidNotificationChannel(
      _scheduledMovieChannelId,
      'Scheduled Movie Suggestions',
      description: 'Scheduled notifications for movie suggestions',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await plugin?.createNotificationChannel(movieSuggestionsChannel);
    await plugin?.createNotificationChannel(scheduledMovieChannel);
  }

  static Future<void> _requestPermissions() async {
    // Request notification permission for Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Request exact alarm permission for Android 12+
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    // For iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Request to disable battery optimization (Android)
    await _requestBatteryOptimizationExemption();
  }

  static Future<void> _requestBatteryOptimizationExemption() async {
    try {
      const platform = MethodChannel('battery_optimization');
      await platform.invokeMethod('requestBatteryOptimizationExemption');
    } catch (e) {
      debugPrint('Failed to request battery optimization exemption: $e');
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      final parts = response.payload!.split('|');
      if (parts.isNotEmpty && parts[0] == 'movie_suggestion') {
     
        _handleMovieSuggestionTap(parts);
      }
    }
  }

  static void _handleMovieSuggestionTap(List<String> payloadParts) {
    // Handle movie suggestion notification tap
    // You can implement navigation to specific movie suggestion screen
    debugPrint('Movie suggestion notification tapped');
    if (payloadParts.length >= 2) {
      final message = payloadParts[1];
      debugPrint('Message: $message');
    }
  }

  // Show immediate movie suggestion notification
  static Future<void> showMovieSuggestionNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _movieSuggestionsChannelId,
      'Movie Suggestions',
      channelDescription: 'Notifications for movie suggestions',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF1976D2), // Movie theme color
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.recommendation,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'movie_suggestion_category',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Show immediate notification (generic)
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await showMovieSuggestionNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );
  }

  // Schedule movie suggestion notification for future time
  static Future<void> scheduleMovieSuggestionNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Validate that the scheduled date is in the future
    if (scheduledDate.isBefore(DateTime.now())) {
      throw ArgumentError('Scheduled date must be in the future');
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _scheduledMovieChannelId,
      'Scheduled Movie Suggestions',
      channelDescription: 'Scheduled notifications for movie suggestions',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF1976D2),
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
      fullScreenIntent: true,
      autoCancel: true,
      ongoing: false,
      visibility: NotificationVisibility.public,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'scheduled_movie_category',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Schedule notification for future time (generic)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await scheduleMovieSuggestionNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );
  }

  // Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Cancel all movie suggestion notifications
  static Future<void> cancelAllMovieSuggestionNotifications() async {
    final pendingNotifications = await getPendingNotifications();
    for (final notification in pendingNotifications) {
      if (notification.payload?.startsWith('movie_suggestion') == true) {
        await cancelNotification(notification.id);
      }
    }
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  // Get pending movie suggestion notifications
  static Future<List<PendingNotificationRequest>> getPendingMovieNotifications() async {
    final allPending = await getPendingNotifications();
    return allPending.where((notification) => 
        notification.payload?.startsWith('movie_suggestion') == true).toList();
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // Request notification permissions if not granted
  static Future<bool> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}