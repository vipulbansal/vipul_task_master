part of 'tasks_bloc.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class FetchTasksEvent extends TaskEvent {
  const FetchTasksEvent();
}

class FetchTaskEvent extends TaskEvent {
  final String taskId;

  const FetchTaskEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class CreateTaskEvent extends TaskEvent {
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriorityModel priority;
  final bool hasReminder;

  const CreateTaskEvent({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.hasReminder,
  });

  @override
  List<Object> get props => [title, description, dueDate, priority, hasReminder];
}

class UpdateTaskEvent extends TaskEvent {
  final Task task;

  const UpdateTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  const DeleteTaskEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class ToggleTaskCompletionEvent extends TaskEvent {
  final String taskId;
  final bool isCompleted;

  const ToggleTaskCompletionEvent(this.taskId, this.isCompleted);

  @override
  List<Object> get props => [taskId, isCompleted];
}

class SyncTasksEvent extends TaskEvent {
  const SyncTasksEvent();
}
