import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/hive_constants.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: HiveConstants.taskTypeId)
class TaskModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime dueDate;

  @HiveField(4)
  final TaskPriority priority;

  @HiveField(5)
  final bool hasReminder;

  @HiveField(6)
  final bool isCompleted;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.hasReminder,
    required this.isCompleted,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create TaskModel from JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      priority: _priorityFromString(json['priority'] as String),
      hasReminder: json['hasReminder'] as bool,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // Factory constructor to create TaskModel from Task entity
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      hasReminder: task.hasReminder,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  // Convert TaskModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': _priorityToString(priority),
      'hasReminder': hasReminder,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Convert TaskModel to Task entity
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      hasReminder: hasReminder,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Private helper method to convert string to TaskPriority enum
  static TaskPriority _priorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      default:
        return TaskPriority.medium;
    }
  }

  // Private helper method to convert TaskPriority enum to string
  static String _priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
    }
  }

  // Create a copy with updated fields
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? hasReminder,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      hasReminder: hasReminder ?? this.hasReminder,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Hive adapter for TaskPriority enum
@HiveType(typeId: HiveConstants.taskPriorityTypeId)
enum TaskPriorityModel {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}