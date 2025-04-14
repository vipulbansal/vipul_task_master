import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/device_info_service.dart';

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

}