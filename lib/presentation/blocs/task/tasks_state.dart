part of 'tasks_bloc.dart';

// States
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TasksLoading extends TaskState {
  const TasksLoading();
}

class TasksLoaded extends TaskState {
  final List<Task> tasks;

  const TasksLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class TaskLoaded extends TaskState {
  final Task task;

  const TaskLoaded(this.task);

  @override
  List<Object> get props => [task];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}

class TaskCreated extends TaskState {
  final Task task;
  final bool reminderScheduled;  // Indicates if reminder was successfully scheduled

  const TaskCreated(this.task, {this.reminderScheduled = true});

  @override
  List<Object> get props => [task, reminderScheduled];
}

class TaskUpdated extends TaskState {
  final Task task;
  final bool reminderScheduled;  // Indicates if reminder was successfully scheduled

  const TaskUpdated(this.task, {this.reminderScheduled = true});

  @override
  List<Object> get props => [task, reminderScheduled];
}

class TaskDeleted extends TaskState {
  final String taskId;

  const TaskDeleted(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class NotificationPermissionDenied extends TaskState {
  final String message;

  const NotificationPermissionDenied(this.message);

  @override
  List<Object> get props => [message];
}