import 'package:uuid/uuid.dart';
import 'package:vipul_task_master/core/constants/app_constants.dart';

import 'package:vipul_task_master/domain/entities/task.dart';

import '../../domain/repositories/task_repository.dart';
import '../datasources/local/hive_service.dart';
import '../datasources/remote/firestore_service.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final HiveService _hiveService;
  final FirestoreService _firestoreService;
  final Uuid _uuid = const Uuid();

  TaskRepositoryImpl(this._hiveService,this._firestoreService);

  @override
  Future<Task> createTask(
      {required String title,
      required String description,
      required DateTime dueDate,
      required TaskPriority priority,
      required bool hasReminder}) async{
    // Create a new task with a unique ID
    final taskId = _uuid.v4();
    final now = DateTime.now();

    final taskModel = TaskModel(
      id: taskId,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      hasReminder: hasReminder,
      isCompleted: false,
      createdAt: now,
      updatedAt: null,
    );
    // Save to both local and remote
    await _hiveService.saveTask(taskModel);
    await _firestoreService.saveTask(taskModel);
    return taskModel.toEntity();
  }

  @override
  Future<bool> deleteTask(String id) async {
    try {
      await _hiveService.deleteTask(id);
      await _firestoreService.deleteTask(id);
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  @override
  Future<Task?> getTaskById(String id) async{
    // Try to get from local cache first
    final localTask = _hiveService.getTaskById(id);

    if (localTask != null) {
      return localTask.toEntity();
    }

    // Otherwise fetch from remote
    final remoteTask = await _firestoreService.getTaskById(id);

    if (remoteTask != null) {
      await _hiveService.saveTask(remoteTask);
      return remoteTask.toEntity();
    }

    return null;
  }

  @override
  Future<List<Task>> getTasks() async {
    // Try to get tasks from local cache first
    final localTasks = _hiveService.getAllTasks();

    // Return local tasks if available
    if (localTasks.isNotEmpty) {
      return localTasks.map((model) => model.toEntity()).toList();
    }

    // Otherwise fetch from remote and cache them
    final remoteTasks = await _firestoreService.getAllTasks();

    if (remoteTasks.isNotEmpty) {
      await _hiveService.saveTasks(remoteTasks);
    }

    return remoteTasks.map((model) => model.toEntity()).toList();
  }

  Future<void> syncTasks() async {
    try {
      // Get tasks from both sources
      final remoteTasks = await _firestoreService.getAllTasks();
      final localTasks = _hiveService.getAllTasks();

      // Create maps for easier lookup
      final remoteTaskMap = {for (var task in remoteTasks) task.id: task};
      final localTaskMap = {for (var task in localTasks) task.id: task};

      // Tasks to upload (exist locally but not remotely or are newer locally)
      final tasksToUpload = <TaskModel>[];

      // Tasks to download (exist remotely but not locally or are newer remotely)
      final tasksToDownload = <TaskModel>[];

      // Check local tasks
      for (final localTask in localTasks) {
        final remoteTask = remoteTaskMap[localTask.id];

        if (remoteTask == null) {
          // Task exists locally but not remotely
          tasksToUpload.add(localTask);
        } else {
          // Compare updated times
          final localUpdateTime = localTask.updatedAt ?? localTask.createdAt;
          final remoteUpdateTime = remoteTask.updatedAt ?? remoteTask.createdAt;

          if (localUpdateTime.isAfter(remoteUpdateTime)) {
            // Local task is newer
            tasksToUpload.add(localTask);
          } else if (remoteUpdateTime.isAfter(localUpdateTime)) {
            // Remote task is newer
            tasksToDownload.add(remoteTask);
          }
        }
      }

      // Check remote tasks
      for (final remoteTask in remoteTasks) {
        if (!localTaskMap.containsKey(remoteTask.id)) {
          // Task exists remotely but not locally
          tasksToDownload.add(remoteTask);
        }
      }

      // Perform uploads and downloads
      if (tasksToUpload.isNotEmpty) {
        await _firestoreService.saveTasks(tasksToUpload);
      }

      if (tasksToDownload.isNotEmpty) {
        await _hiveService.saveTasks(tasksToDownload);
      }
    } catch (e) {
      print('Error syncing tasks: $e');
      rethrow;
    }
  }

  @override
  Future<Task> toggleTaskCompletion(String id, bool isCompleted) async {
    // Get the current task
    final task = await getTaskById(id);

    if (task == null) {
      throw Exception('Task not found');
    }

    // Create an updated task with toggled completion
    final updatedTask = task.copyWith(
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
    );

    // Update the task
    return await updateTask(updatedTask);
  }

  @override
  Future<Task> updateTask(Task task) async {
    final now = DateTime.now();

    // Create an updated task model
    final updatedModel = TaskModel.fromEntity(task).copyWith(
      updatedAt: now,
    );

    // Save to both local and remote
    await _hiveService.saveTask(updatedModel);
    await _firestoreService.saveTask(updatedModel);

    return updatedModel.toEntity();
  }
}
