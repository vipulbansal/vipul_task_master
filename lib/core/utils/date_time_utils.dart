import 'package:intl/intl.dart';

class DateTimeUtils {
  /// Format the due date relative to today
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    
    final dueDate = DateTime(date.year, date.month, date.day);
    
    if (dueDate == today) {
      return 'Today';
    } else if (dueDate == tomorrow) {
      return 'Tomorrow';
    } else if (dueDate == yesterday) {
      return 'Yesterday';
    } else {
      // Format based on how far in the future/past
      final difference = dueDate.difference(today).inDays;
      
      if (difference > 0 && difference < 7) {
        // Within a week in the future
        return DateFormat('EEEE').format(date); // Weekday name
      } else {
        // More than a week away or in the past
        return DateFormat('MMM d').format(date); // e.g., "Jan 15"
      }
    }
  }
  
  /// Get a human-readable time remaining string
  static String getTimeRemaining(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.isNegative) {
      // Overdue task
      final Duration overdue = difference.abs();
      
      if (overdue.inDays > 0) {
        final days = overdue.inDays;
        return 'Overdue by $days ${days == 1 ? 'day' : 'days'}';
      } else if (overdue.inHours > 0) {
        final hours = overdue.inHours;
        return 'Overdue by $hours ${hours == 1 ? 'hour' : 'hours'}';
      } else {
        final minutes = overdue.inMinutes;
        return 'Overdue by $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      }
    } else {
      // Upcoming task
      if (difference.inDays > 0) {
        final days = difference.inDays;
        return '$days ${days == 1 ? 'day' : 'days'} remaining';
      } else if (difference.inHours > 0) {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? 'hour' : 'hours'} remaining';
      } else {
        final minutes = difference.inMinutes;
        if (minutes == 0) {
          return 'Due now';
        }
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} remaining';
      }
    }
  }
  
  /// Format date for display in lists and details
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
  
  /// Format time for display in lists and details
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }
  
  /// Format date and time for display
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, y • h:mm a').format(date);
  }
}