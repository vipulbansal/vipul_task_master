import '../../core/constants/app_constants.dart';
import '../../data/models/task_model.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  /// Get all tasks
  Future<List<Task>> getTasks();

  /// Get a specific task by ID
  Future<Task?> getTaskById(String id);

  /// Create a new task
  Future<Task> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriorityModel priority,
    required bool hasReminder,
  });

  /// Update an existing task
  Future<Task> updateTask(Task task);

  /// Delete a task by ID
  Future<bool> deleteTask(String id);

  /// Toggle task completion status
  Future<Task> toggleTaskCompletion(String id, bool isCompleted);

  /// Sync tasks with remote storage
  Future<bool> syncTasks();
}
