class AppConstants {
  // App info
  static const String appName = 'TaskMaster';
  static const String appVersion = '1.0.0';

  // Database collections
  static const String tasksCollection = 'tasks';
  // Notification settings
  static const int notificationReminderMinutes = 15;
}


  /// Task priority levels
enum TaskPriority {
  low,
  medium,
  high,
}