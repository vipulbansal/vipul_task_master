import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceInfoService {
  static const String _deviceIdKey = 'device_id';

  late String deviceId;
  bool _initialized = false;

  // Initialize the service
  Future<void> initialize() async {
    if (_initialized) return;
    // Get device ID from storage or generate a new one
    deviceId = await _getOrCreateDeviceId();
  }

  // Get or create a unique device ID
  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString(_deviceIdKey);
    if (storedId == null || storedId.isEmpty) {
      final newDeviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, newDeviceId);
      return newDeviceId;
    }
    return storedId;
  }
}
