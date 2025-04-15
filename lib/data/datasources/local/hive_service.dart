import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/hive_constants.dart';
import '../../models/task_model.dart';

class HiveService {
  /// Get the tasks box
  Box<TaskModel> get tasksBox => Hive.box<TaskModel>(HiveConstants.taskBox);
  
  /// Get all tasks from Hive
  List<TaskModel> getAllTasks() {
    return tasksBox.values.toList();
  }

  /// Get a task by ID
  TaskModel? getTaskById(String id) {
    try {
      return tasksBox.values.firstWhere((task) => task.id == id);
    } catch (e) {
      return null; // Return null if not found
    }
  }
  
  /// Save a task to Hive
  Future<void> saveTask(TaskModel task) async {
    await tasksBox.put(task.id, task);
  }
  
  /// Delete a task from Hive
  Future<void> deleteTask(String id) async {
    await tasksBox.delete(id);
  }
  
  /// Save multiple tasks to Hive
  Future<void> saveTasks(List<TaskModel> tasks) async {
    Map<String, TaskModel> taskMap = {
      for (var task in tasks) task.id: task
    };
    await tasksBox.putAll(taskMap);
  }
  
  /// Clear all tasks from Hive
  Future<void> clearAllTasks() async {
    await tasksBox.clear();
  }
}