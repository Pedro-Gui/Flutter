import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_uuids.dart';

/// Camada Bluetooth para comunicar com o hardware ESP32_sin sem expor detalhes
class BleRepository {
  const BleRepository();

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  Stream<BluetoothConnectionState> connectionStateStream(
    BluetoothDevice device,
  ) {
    return device.connectionState;
  }

  Future<void> startScan() async {
    if (FlutterBluePlus.isScanningNow) return;
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  Future<void> stopScan() async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    await stopScan();
    await device.connect(
      license: License.free,
      timeout: const Duration(seconds: 15),
    );
    await device.discoverServices();
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }

  // Leitura do valores
  Future<double> readStep(BluetoothDevice device) async {
    final service = _getService(device, BleUUIDs.sinService);
    final characteristic = _getChar(service, BleUUIDs.stepCharacteristic);

    final bytes = await characteristic.read();
    if (bytes.length < 8) {
      throw Exception('Payload de leitura inválido para Step');
    }

    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    return data.getFloat64(0, Endian.little);
  }

  Future<bool> readLedState(BluetoothDevice device) async {
    final service = _getService(device, BleUUIDs.ledService);
    final characteristic = _getChar(service, BleUUIDs.ledCharacteristic);

    final bytes = await characteristic.read();
    final value = utf8.decode(bytes);
    return value.contains('1');
  }

  Stream<double> subscribeToSine(BluetoothDevice device) {
    final service = _getService(device, BleUUIDs.sinService);
    final characteristic = _getChar(service, BleUUIDs.sinCharacteristic);

    return characteristic.onValueReceived.map((bytes) {
      if (bytes.length < 4) return 0.0;
      final data = Uint8List.fromList(bytes).buffer.asByteData();
      return data.getFloat32(0, Endian.little);
    });
  }

  // atuadores
  Future<void> writeStep(BluetoothDevice device, double value) async {
    final service = _getService(device, BleUUIDs.sinService);
    final characteristic = _getChar(service, BleUUIDs.stepCharacteristic);

    final byteData = ByteData(8);
    byteData.setFloat64(0, value, Endian.little);

    await characteristic.write(byteData.buffer.asUint8List());
  }

  Future<void> writeLedState(BluetoothDevice device) async {
    final service = _getService(device, BleUUIDs.ledService);
    final characteristic = _getChar(service, BleUUIDs.ledCharacteristic);
    final bool turnOn = await readLedState(device);
    final payload = utf8.encode(!turnOn ? '1' : '0');
    await characteristic.write(payload);
  }

  Future<void> setSineNotifications(BluetoothDevice device, bool enable) async {
    final service = _getService(device, BleUUIDs.sinService);
    final characteristic = _getChar(service, BleUUIDs.sinCharacteristic);
    if (characteristic.isNotifying != enable) {
      await characteristic.setNotifyValue(enable);
    }
  }

  // Métodos auxiliares
  BluetoothService _getService(BluetoothDevice device, Guid serviceUuid) {
    return device.servicesList.firstWhere(
      (s) => s.uuid == serviceUuid,
      orElse: () => throw Exception('Serviço não encontrado'),
    );
  }

  BluetoothCharacteristic _getChar(BluetoothService service, Guid charUuid) {
    return service.characteristics.firstWhere(
      (c) => c.uuid == charUuid,
      orElse: () => throw Exception('Característica não encontrada'),
    );
  }
}
