import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/task_model.dart';
import '../../domain/entities/task.dart';

import '../blocs/task/tasks_bloc.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/priority_badge.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({
    Key? key,
    this.task,
  }) : super(key: key);

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TaskPriorityModel _priority;
  late bool _hasReminder;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    
    // Initialize values from task if editing, or defaults if creating
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    
    // Set due date to task's due date or tomorrow at 9 AM if creating new
    final now = DateTime.now();
    _dueDate = widget.task?.dueDate ?? DateTime(
      now.year, 
      now.month, 
      now.day + 1, 
      9, 
      0,
    );
    
    _priority = widget.task?.priority ?? TaskPriorityModel.medium;
    _hasReminder = widget.task?.hasReminder ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskCreated || state is TaskUpdated) {
          // If reminder was not scheduled due to permission issues, show a warning
          if (state is TaskCreated && !state.reminderScheduled ||
              state is TaskUpdated && !state.reminderScheduled) {
            // First navigate back
            context.pop();
            // Then show a snackbar about the permission issue
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Task saved but reminders won\'t be shown because notification permissions were denied.',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 5),
              ),
            );
          } else {
            // Normal success case
            context.pop();
          }
        } else if (state is NotificationPermissionDenied) {
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
        } else if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteTask,
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              
              // Due date picker
              DateTimePicker(
                initialDate: _dueDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (dateTime) {
                  setState(() {
                    _dueDate = dateTime;
                  });
                },
                label: 'Due Date & Time',
                helperText: 'When is this task due?',
              ),
              const SizedBox(height: 24),
              
              // Priority selection
              Text(
                'Priority',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriorityOption(TaskPriorityModel.low, 'Low'),
                  _buildPriorityOption(TaskPriorityModel.medium, 'Medium'),
                  _buildPriorityOption(TaskPriorityModel.high, 'High'),
                ],
              ),
              const SizedBox(height: 24),
              
              // Reminder toggle
              SwitchListTile(
                title: const Text('Set Reminder'),
                subtitle: const Text('Get notified before the due date'),
                value: _hasReminder,
                onChanged: (value) {
                  setState(() {
                    _hasReminder = value;
                  });
                },
                secondary: const Icon(Icons.notifications),
              ),
              const SizedBox(height: 40),
              
              // Save button
              ElevatedButton.icon(
                onPressed: _saveTask,
                icon: Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? 'Save Changes' : 'Add Task'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption(TaskPriorityModel priority, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _priority = priority;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _priority == priority 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              width: 2,
            ),
            color: _priority == priority
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
          ),
          child: Column(
            children: [
              PriorityBadge(
                priority: priority,
                height: 24,
                showLabel: false,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: _priority == priority
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      
      if (_isEditing) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: title,
          description: description,
          dueDate: _dueDate,
          priority: _priority,
          hasReminder: _hasReminder,
          updatedAt: DateTime.now(),
        );
        
        context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
      } else {
        // Create new task
        context.read<TaskBloc>().add(
          CreateTaskEvent(
            title: title,
            description: description,
            dueDate: _dueDate,
            priority: _priority,
            hasReminder: _hasReminder,
          ),
        );
      }
    }
  }

  void _deleteTask() {
    if (_isEditing) {
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
                context.read<TaskBloc>().add(DeleteTaskEvent(widget.task!.id));
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
  }
}