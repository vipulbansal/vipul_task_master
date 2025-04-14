import 'package:uuid/uuid.dart';
import 'package:vipul_task_master/core/constants/app_constants.dart';

import 'package:vipul_task_master/domain/entities/task.dart';

import '../../domain/repositories/task_repository.dart';
import '../datasources/local/hive_service.dart';

class TaskRepositoryImpl implements TaskRepository {
  final HiveService _hiveService;
  final Uuid _uuid = const Uuid();

  TaskRepositoryImpl(this._hiveService);

  @override
  Future<Task> createTask(
      {required String title,
      required String description,
      required DateTime dueDate,
      required TaskPriority priority,
      required bool hasReminder}) {
    // TODO: implement createTask
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteTask(String id) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Future<Task?> getTaskById(String id) {
    // TODO: implement getTaskById
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getTasks() {
    // TODO: implement getTasks
    throw UnimplementedError();
  }

  @override
  Future<void> syncTasks() {
    // TODO: implement syncTasks
    throw UnimplementedError();
  }

  @override
  Future<Task> toggleTaskCompletion(String id, bool isCompleted) {
    // TODO: implement toggleTaskCompletion
    throw UnimplementedError();
  }

  @override
  Future<Task> updateTask(Task task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
}
