import '../../core/constants/app_constants.dart';
import '../../data/models/task_model.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Get tasks use case
class GetTasksUseCase {
  final TaskRepository _repository;

  GetTasksUseCase(this._repository);

  Future<List<Task>> call() async {
    return await _repository.getTasks();
  }
}

/// Get task by id use case
class GetTaskUseCase {
  final TaskRepository _repository;

  GetTaskUseCase(this._repository);

  Future<Task?> call(String id) async {
    return await _repository.getTaskById(id);
  }
}

/// Create task use case
class CreateTaskUseCase {
  final TaskRepository _repository;

  CreateTaskUseCase(this._repository);

  Future<Task> call({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriorityModel priority,
    required bool hasReminder,
  }) async {
    return await _repository.createTask(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      hasReminder: hasReminder,
    );
  }
}

/// Update task use case
class UpdateTaskUseCase {
  final TaskRepository _repository;

  UpdateTaskUseCase(this._repository);

  Future<Task> call(Task task) async {
    return await _repository.updateTask(task);
  }
}

/// Delete task use case
class DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCase(this._repository);

  Future<bool> call(String id) async {
    return await _repository.deleteTask(id);
  }
}

/// Toggle task completion use case
class ToggleTaskCompletionUseCase {
  final TaskRepository _repository;

  ToggleTaskCompletionUseCase(this._repository);

  Future<Task> call(String id, bool isCompleted) async {
    return await _repository.toggleTaskCompletion(id, isCompleted);
  }
}

/// Sync tasks use case
class SyncTasksUseCase {
  final TaskRepository _repository;

  SyncTasksUseCase(this._repository);

  Future<void> call() async {
    await _repository.syncTasks();
  }
}