import 'package:universal_ble/universal_ble.dart';

class SysBleDevice {
  final String id;
  final String name;
  final int rssi;

  SysBleDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });
  
  SysBleDevice.fromBleDevice(BleDevice device)
      : id = device.deviceId,
        name = device.name ?? 'Unknown Device',
        rssi = device.rssi ?? -100;


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SysBleDevice &&
        other.id == id &&
        other.name == name &&
        other.rssi == rssi;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ rssi.hashCode;
}