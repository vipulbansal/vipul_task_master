import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/task.dart';
import '../blocs/task/tasks_bloc.dart';
import '../widgets/priority_badge.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  final Task? task;

  const TaskDetailScreen({
    Key? key,
    required this.taskId,
    this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If task was passed as extra, use it directly
    // Otherwise fetch it using the taskId
    if (task != null) {
      return _buildTaskDetailScreen(context, task!);
    }

    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        // Handle NotificationPermissionDenied state
        if (state is NotificationPermissionDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () {
                  // This would ideally open system settings
                  // For now just dismiss the snackbar
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TasksLoading) {
          return _buildLoadingScreen();
        } else if (state is TaskLoaded && state.task.id == taskId) {
          return _buildTaskDetailScreen(context, state.task);
        } else if (state is TaskError) {
          return _buildErrorScreen(context, state.message);
        } else {
          // Fetch the task if it's not already loaded
          context.read<TaskBloc>().add(FetchTaskEvent(taskId));
          return _buildLoadingScreen();
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Task',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetailScreen(BuildContext context, Task task) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTask(context, task),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Task completion status
          Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  if (value != null) {
                    context.read<TaskBloc>().add(
                      ToggleTaskCompletionEvent(task.id, value),
                    );
                  }
                },
              ),
              Text(
                task.isCompleted ? 'Completed' : 'Pending',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: task.isCompleted 
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Task title
          Text(
            task.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              decoration: task.isCompleted 
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Priority badge
          PriorityBadge(
            priority: task.priority,
            isCompleted: task.isCompleted,
            height: 28,
            showLabel: true,
          ),
          
          const SizedBox(height: 24),
          
          // Due date and time
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              'Due Date',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(dateFormat.format(task.dueDate)),
          ),
          
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(
              'Due Time',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(timeFormat.format(task.dueDate)),
          ),
          
          // Time remaining (if not completed)
          if (!task.isCompleted)
            ListTile(
              leading: const Icon(Icons.hourglass_bottom),
              title: Text(
                'Time Remaining',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                DateTimeUtils.getTimeRemaining(task.dueDate),
                style: TextStyle(
                  color: _getTimeRemainingColor(task.dueDate, theme),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          // Reminder status
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(
              'Reminder',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              task.hasReminder 
                  ? 'Enabled (15 minutes before due time)'
                  : 'Disabled',
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Description section
          Text(
            'Description',
            style: theme.textTheme.titleLarge,
          ),
          
          const SizedBox(height: 8),
          
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                task.description.isEmpty 
                    ? 'No description provided'
                    : task.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: task.description.isEmpty 
                      ? FontStyle.italic
                      : FontStyle.normal,
                  color: task.description.isEmpty 
                      ? Colors.grey
                      : null,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Created/Updated info
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(
              'Created',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              DateFormat('MMM d, y • h:mm a').format(task.createdAt),
            ),
          ),
          
          if (task.updatedAt != null)
            ListTile(
              leading: const Icon(Icons.update),
              title: Text(
                'Last Updated',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                DateFormat('MMM d, y • h:mm a').format(task.updatedAt!),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Delete button
          OutlinedButton.icon(
            onPressed: () => _deleteTask(context, task),
            icon: const Icon(Icons.delete),
            label: const Text('Delete Task'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _editTask(BuildContext context, Task task) {
    context.push(AppConstants.editTaskRoute, extra: task);
  }

  void _deleteTask(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
              context.pop();
            },
            child: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
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