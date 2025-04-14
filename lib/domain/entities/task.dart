import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

/// Task entity class - core domain object 
class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool hasReminder;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Task({
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

  @override
  List<Object?> get props => [
    id,
    title, 
    description, 
    dueDate, 
    priority, 
    hasReminder, 
    isCompleted,
    createdAt,
    updatedAt,
  ];

  // Create a copy with updated fields
  Task copyWith({
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
    return Task(
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