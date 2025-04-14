import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/device_info_service.dart';
import '../../models/task_model.dart';

class FirestoreService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoService _deviceInfoService;

  FirestoreService(this._deviceInfoService);

  /// Get a reference to the tasks collection for the current device
  CollectionReference<Map<String, dynamic>> get _tasksCollection {
    return _firestore
        .collection('devices')
        .doc(_deviceInfoService.deviceId)
        .collection(AppConstants.tasksCollection);
  }

  /// Get all tasks from Firestore
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final querySnapshot = await _tasksCollection.get();
      return querySnapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // Handle errors or return empty list
      print('Error fetching tasks from Firestore: $e');
      return [];
    }
  }

  /// Get a task by ID
  Future<TaskModel?> getTaskById(String id) async {
    try {
      final docSnapshot = await _tasksCollection.doc(id).get();
      if (docSnapshot.exists) {
        return TaskModel.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching task from Firestore: $e');
      return null;
    }
  }

  /// Save a task to Firestore
  Future<void> saveTask(TaskModel task) async {
    try {
      await _tasksCollection.doc(task.id).set(task.toJson());
    } catch (e) {
      print('Error saving task to Firestore: $e');
      rethrow;
    }
  }

  /// Delete a task from Firestore
  Future<void> deleteTask(String id) async {
    try {
      await _tasksCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting task from Firestore: $e');
      rethrow;
    }
  }

  /// Save multiple tasks to Firestore
  Future<void> saveTasks(List<TaskModel> tasks) async {
    // Create a batch for bulk operations
    final batch = _firestore.batch();

    for (var task in tasks) {
      final docRef = _tasksCollection.doc(task.id);
      batch.set(docRef, task.toJson());
    }

    try {
      await batch.commit();
    } catch (e) {
      print('Error saving tasks to Firestore: $e');
      rethrow;
    }
  }

}