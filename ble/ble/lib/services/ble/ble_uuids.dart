import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleUUIDs {
  static final Guid sinService = Guid(
    '4fafc201-1fb5-459e-8fcc-c5c9c331914b');
  static final Guid sinCharacteristic = Guid(
    'beb5483e-36e1-4688-b7f5-ea07361b26a8',
  );
  static final Guid stepCharacteristic = Guid(
    'bec5483e-36e1-4688-b7f5-ea07361b26a8',
  );
  static final Guid ledService = Guid(
    '4fbfc201-1fb5-459e-8fcc-c5c9c331914b');
  static final Guid ledCharacteristic = Guid(
    'beb9483e-36e1-4688-b7f5-ea07361b26a8',
  );
}
