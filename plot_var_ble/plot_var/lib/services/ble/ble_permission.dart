import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static Future<bool> requestBlePermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      final isAndroid12OrHigher = androidInfo.version.sdkInt >= 31;

      if (isAndroid12OrHigher) {
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();

        final scanGranted = statuses[Permission.bluetoothScan] == PermissionStatus.granted;
        final connectGranted = statuses[Permission.bluetoothConnect] == PermissionStatus.granted;

        return scanGranted && connectGranted;
      } else {
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan, 
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
        ].request();

        final scanGranted = statuses[Permission.bluetoothScan] == PermissionStatus.granted;
        final connectGranted = statuses[Permission.bluetoothConnect] == PermissionStatus.granted;
        final locationGranted = statuses[Permission.locationWhenInUse] == PermissionStatus.granted;

        return scanGranted && connectGranted && locationGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.bluetooth.request();
      return status == PermissionStatus.granted;
    }
    return false;
  }
}
