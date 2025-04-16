class AppConstants {
  // App info
  static const String appName = 'TaskMaster';
  static const String appVersion = '1.0.0';

  // Database collections
  static const String tasksCollection = 'tasks';
  // Notification settings
  static const int notificationReminderMinutes = 15;

  // Routes
  static const String homeRoute = '/';
  static const String addTaskRoute = '/add-task';
  static const String editTaskRoute = '/edit-task';
  static const String taskDetailRoute = '/task';
}


  /// Task priority levels
enum TaskPriority {
  low,
  medium,
  high,
}