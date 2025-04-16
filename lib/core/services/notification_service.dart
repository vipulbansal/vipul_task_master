import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/task.dart';
import '../constants/app_constants.dart';



@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle notification interaction when app is in the background or terminated
  print('Background notification tapped: ${notificationResponse.payload}');
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Initialize the service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize notification settings for Android
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize notification settings for iOS
    const iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize notification settings for all platforms
    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    _initialized = true;
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse details) {
    // Handle navigation here if needed
    print('Notification tapped: ${details.payload}');
  }

  // Request notification permissions (especially important for iOS)
  // Returns true if all necessary permissions are granted, false otherwise
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();
    bool permissionsGranted = true;

    // Request permissions for iOS
    final ios = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final result = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      // iOS returns false if any of the permissions are denied
      if (result!= true) {
        print('Some iOS notification permissions denied');
        permissionsGranted = false;
      }
    }

    // Request permissions for Android (Android 13+)
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      // Request notification permissions
      final bool? granted = await android.requestNotificationsPermission();
      if (granted != true) {
        print('Android notification permissions denied');
        permissionsGranted = false;
      }

      // Request exact alarm permissions for Android 14+
      try {
        final bool? exactAlarmsGranted = await android.requestExactAlarmsPermission();
        if (exactAlarmsGranted != true) {
          print('Android exact alarms permission denied');
          // This permission is important for reminders, but app can still function
          // with less precise notifications
          permissionsGranted = false;
        }
      } catch (e) {
        print('Error requesting exact alarms permission: $e');
        // Continue anyway as this might not be supported on all Android versions
      }
    }

    return permissionsGranted;
  }

  // Check if we have the necessary permissions to show notifications
  Future<bool> checkPermissions() async {
    if (!_initialized) await initialize();

    // Check permissions on Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final bool? arePermissionsGranted = await android.areNotificationsEnabled();
        return arePermissionsGranted ?? false;
      }
    }

    // iOS doesn't have a direct way to check permissions, so we return true
    // as the requestPermissions will handle this for iOS when needed
    return true;
  }

  // Schedule a notification for a task
  // Returns true if notification was scheduled successfully, false otherwise
  Future<bool> scheduleTaskReminder(Task task) async {
    if (!_initialized) await initialize();
    if (!task.hasReminder) return false;

    // First check if we have permissions to schedule notifications
    final hasPermissions = await checkPermissions();
    if (!hasPermissions) {
      print('Cannot schedule notification: permissions not granted');
      // Attempt to request permissions if they're not granted
      final permissionsGranted = await requestPermissions();
      if (!permissionsGranted) {
        print('User denied notification permissions. Cannot schedule reminders.');
        return false;
      }
    }

    // Cancel existing notification if any
    await cancelTaskReminder(task.id);

    // Calculate notification time (15 minutes before due time)
    final dueDate = task.dueDate;
    final reminderTime = dueDate.subtract(
      Duration(minutes: AppConstants.notificationReminderMinutes),
    );

    // Only schedule if reminder time is in the future
    final now = DateTime.now();
    if (reminderTime.isBefore(now)) return false;

    try {
      // Create Android notification details
      const androidDetails = AndroidNotificationDetails(
        'task_reminders',
        'Task Reminders',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
        color: Color.fromARGB(255, 33, 150, 243),
      );

      // Create iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Create platform-specific notification details
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule the notification
      await _notificationsPlugin.zonedSchedule(
        task.id.hashCode, // Use hash code of task ID as notification ID
        'Task Reminder: ${task.title}',
        task.description,
        tz.TZDateTime.from(reminderTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: task.id,
      );

      return true;
    } catch (e) {
      print('Error scheduling notification: $e');
      return false;
    }
  }

  // Cancel notification for a task
  Future<void> cancelTaskReminder(String taskId) async {
    if (!_initialized) await initialize();
    await _notificationsPlugin.cancel(taskId.hashCode);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) await initialize();
    await _notificationsPlugin.cancelAll();
  }
}