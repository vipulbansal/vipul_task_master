import 'package:flutter/material.dart';
import 'package:vipul_task_master/presentation/widgets/priority_badge.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/models/task_model.dart';
import '../../domain/entities/task.dart';


class TaskItem extends StatelessWidget {
  final Task task;
  final Function(Task) onTap;
  final Function(String, bool) onToggleCompletion;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onToggleCompletion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Determine card color based on priority and completion status
    Color cardColor = theme.cardColor;
    if (!task.isCompleted) {
      switch (task.priority) {
        case TaskPriorityModel.high:
          cardColor = isDarkMode ? Colors.red.shade900 : Colors.red.shade50;
          break;
        case TaskPriorityModel.medium:
          cardColor = isDarkMode ? Colors.orange.shade900 : Colors.orange.shade50;
          break;
        case TaskPriorityModel.low:
          cardColor = isDarkMode ? Colors.green.shade900 : Colors.green.shade50;
          break;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: cardColor,
      child: InkWell(
        onTap: () => onTap(task),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox for completion status
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  shape: const CircleBorder(),
                  value: task.isCompleted,
                  onChanged: (value) {
                    if (value != null) {
                      onToggleCompletion(task.id, value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task title with strike-through if completed
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task.isCompleted ? Colors.grey : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Task description (if not empty)
                    if (task.description.isNotEmpty) ...[
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Due date and priority row
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: task.isCompleted ? Colors.grey : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateTimeUtils.formatRelativeDate(task.dueDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: task.isCompleted ? Colors.grey : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PriorityBadge(priority: task.priority, isCompleted: task.isCompleted),
                        if (task.hasReminder) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.notifications_active,
                            size: 14,
                            color: task.isCompleted ? Colors.grey : Colors.amber,
                          ),
                        ],
                      ],
                    ),
                    // Time remaining for non-completed tasks
                    if (!task.isCompleted) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateTimeUtils.getTimeRemaining(task.dueDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getTimeRemainingColor(task.dueDate, theme),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get color for time remaining text based on due date
  Color _getTimeRemainingColor(DateTime dueDate, ThemeData theme) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.isNegative) {
      return Colors.red; // Overdue
    } else if (difference.inHours < 24) {
      return Colors.orange; // Due within 24 hours
    } else {
      return theme.colorScheme.primary; // Due in more than 24 hours
    }
  }
}