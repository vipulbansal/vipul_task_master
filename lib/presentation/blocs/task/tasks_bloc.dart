import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/task_model.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/usecases/task_usecases.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final GetTaskUseCase getTaskUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final NotificationService notificationService;
  final SyncTasksUseCase syncTasksUseCase;

  TaskBloc({
    required this.getTasksUseCase,
    required this.getTaskUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.notificationService,
    required this.syncTasksUseCase,
  }) : super(const TaskInitial()) {
    on<FetchTasksEvent>(_onFetchTasks);
    on<FetchTaskEvent>(_onFetchTask);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleTaskCompletionEvent>(_onToggleTaskCompletion);
    on<SyncTasksEvent>(_onSyncTasks);
  }

  // Handle fetch tasks event
  Future<void> _onFetchTasks(
      FetchTasksEvent event,
      Emitter<TaskState> emit,
      ) async {
    emit(const TasksLoading());
    try {
      final tasks = await getTasksUseCase();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // Handle fetch task event
  Future<void> _onFetchTask(
      FetchTaskEvent event,
      Emitter<TaskState> emit,
      ) async {
    emit(const TasksLoading());
    try {
      final task = await getTaskUseCase(event.taskId);
      if (task != null) {
        emit(TaskLoaded(task));
      } else {
        emit(const TaskError('Task not found'));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // Handle create task event
  Future<void> _onCreateTask(
      CreateTaskEvent event,
      Emitter<TaskState> emit,
      ) async {
    emit(const TasksLoading());
    try {
      final task = await createTaskUseCase(
        title: event.title,
        description: event.description,
        dueDate: event.dueDate,
        priority: event.priority,
        hasReminder: event.hasReminder,
      );

      // Track if reminder was successfully scheduled
      bool reminderScheduled = true;

      // Schedule notification if task has reminder
      if (task.hasReminder) {
        reminderScheduled = await notificationService.scheduleTaskReminder(task);

        // If permissions were denied, emit a permission denied state
        if (!reminderScheduled) {
          // Task is created, but let the UI know that reminders won't work
          emit(const NotificationPermissionDenied(
              'Notification permissions denied. Task created but reminders will not be shown.'
          ));
          // Then emit the task created state with reminderScheduled set to false
          emit(TaskCreated(task, reminderScheduled: false));
          // Reload tasks list
          add(const FetchTasksEvent());
          return;
        }
      }

      // Normal case - task created successfully with reminders if needed
      emit(TaskCreated(task, reminderScheduled: reminderScheduled));

      // Reload tasks list
      add(const FetchTasksEvent());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // Handle update task event
  Future<void> _onUpdateTask(
      UpdateTaskEvent event,
      Emitter<TaskState> emit,
      ) async {
    emit(const TasksLoading());
    try {
      final task = await updateTaskUseCase(event.task);

      // Track if reminder was successfully scheduled or canceled
      bool reminderScheduled = true;

      // Update notification if task has reminder
      if (task.hasReminder) {
        reminderScheduled = await notificationService.scheduleTaskReminder(task);

        // If reminder couldn't be scheduled due to permission issues
        if (!reminderScheduled) {
          // Task is updated, but let the UI know that reminders won't work
          emit(const NotificationPermissionDenied(
              'Notification permissions denied. Task updated but reminders will not be shown.'
          ));
          // Then emit the task updated state with reminderScheduled set to false
          emit(TaskUpdated(task, reminderScheduled: false));
          // Reload tasks list
          add(const FetchTasksEvent());
          return;
        }
      } else {
        // Cancel any existing reminders if reminder is turned off
        await notificationService.cancelTaskReminder(task.id);
      }

      // Normal case - task updated successfully with reminders if needed
      emit(TaskUpdated(task, reminderScheduled: reminderScheduled));

      // Reload tasks list
      add(const FetchTasksEvent());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // Handle delete task event
  Future<void> _onDeleteTask(
      DeleteTaskEvent event,
      Emitter<TaskState> emit,
      ) async {
    emit(const TasksLoading());
    try {
      final success = await deleteTaskUseCase(event.taskId);

      // Cancel notification
      await notificationService.cancelTaskReminder(event.taskId);

      if (success) {
        emit(TaskDeleted(event.taskId));

        // Reload tasks list
        add(const FetchTasksEvent());
      } else {
        emit(const TaskError('Failed to delete task'));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // Handle toggle task completion event
  Future<void> _onToggleTaskCompletion(
      ToggleTaskCompletionEvent event,
      Emitter<TaskState> emit,
      ) async {
    try {
      final task = await getTaskUseCase(event.taskId);

      if (task != null) {
        final updatedTask = task.copyWith(
          isCompleted: event.isCompleted,
        );

        await updateTaskUseCase(updatedTask);

        // If task is completed, cancel notification
        if (event.isCompleted) {
          await notificationService.cancelTaskReminder(event.taskId);
        } else if (task.hasReminder) {
          // If task is uncompleted and has reminder, reschedule notification
          bool reminderScheduled = await notificationService.scheduleTaskReminder(updatedTask);

          // If reminder couldn't be scheduled due to permission issues
          if (!reminderScheduled) {
            // Only emit the permission denial message as the tasks list will be reloaded
            emit(const NotificationPermissionDenied(
                'Notification permissions denied. Task updated but reminders will not be shown.'
            ));
          }
        }

        // Reload tasks list
        add(const FetchTasksEvent());
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // Handle sync tasks event
  Future<void> _onSyncTasks(
      SyncTasksEvent event,
      Emitter<TaskState> emit,
      ) async {
    emit(const TasksLoading());
    try {
      // For this implementation, we'll simply refetch all tasks
      // which will trigger a sync between local and remote data sources
     bool syncStatus= await syncTasksUseCase();
      emit(TaskSync(syncStatus));
      add(FetchTasksEvent());
    } catch (e) {
      emit(TaskSync(false));
    }
  }
}