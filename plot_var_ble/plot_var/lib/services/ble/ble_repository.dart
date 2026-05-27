import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:plot_ble/models/ble_sys_device.dart';
import 'package:universal_ble/universal_ble.dart';
import 'ble_uuids.dart';

class BleRepository {
  final _scanResultsController =
      StreamController<List<SysBleDevice>>.broadcast();
  final _isScanningController = 
      StreamController<bool>.broadcast();
  final _connectionStateControllers =
      <String, StreamController<BleConnectionState>>{};
  final _characteristicUpdatesController =
      StreamController<_CharacteristicUpdate>.broadcast();

  final List<SysBleDevice> _currentScanResults = [];
  bool _isScanning = false;

  BleRepository() {
    _initializeCallbacks();
  }

  void _initializeCallbacks() {
    UniversalBle.onScanResult = (BleDevice result) {
      final index = _currentScanResults.indexWhere(
        (r) => r.id == result.deviceId,
      );
      final device = SysBleDevice.fromBleDevice(result);

      if (index >= 0) {
        _currentScanResults[index] = device;
      } else {
        _currentScanResults.add(device);
      }
      _scanResultsController.add(List.unmodifiable(_currentScanResults));
    };

    UniversalBle.onConnectionChange =
        (String deviceId, bool isConnected, String? error) {
          final state = isConnected
              ? BleConnectionState.connected
              : BleConnectionState.disconnected;
          _getConnectionStream(deviceId).add(state);
          
        };

    UniversalBle.onValueChange =
        (
          String deviceId,
          String characteristicId,
          Uint8List value,
          int? timestamp,
        ) {
          _characteristicUpdatesController.add(
            _CharacteristicUpdate(
              deviceId: deviceId,
              characteristicId: characteristicId,
              value: value,
            ),
          );
        };
  }

  // --- API Exposta ---

  Stream<List<SysBleDevice>> get scanResults => _scanResultsController.stream;

  Stream<bool> get isScanning => _isScanningController.stream;

  Stream<BleConnectionState> connectionStateStream(String deviceId) {
    return _getConnectionStream(deviceId).stream;
  }

  Future<void> startScan() async {
    if (_isScanning) return;

    _isScanning = true;
    _isScanningController.add(true);
    _currentScanResults.clear();
    _scanResultsController.add([]);

    await UniversalBle.startScan();

    Future.delayed(const Duration(seconds: 15), () {
      if (_isScanning) stopScan();
    });
  }

  Future<void> stopScan() async {
    if (!_isScanning) return;
    await UniversalBle.stopScan();
    _isScanning = false;
    _isScanningController.add(false);
  }

  Future<void> connect(String deviceId) async {
    await stopScan();
    await UniversalBle.connect(deviceId);
    await UniversalBle.discoverServices(deviceId);
  }

  Future<void> disconnect(String deviceId) async {
    await UniversalBle.disconnect(deviceId);
  }

  // --- Leitura de Valores ---

  Future<double> readStep(String deviceId) async {
    final bytes = await UniversalBle.read(
      deviceId,
      BleUUIDs.sinService,
      BleUUIDs.stepCharacteristic,
    );

    if (bytes.length < 4) {
      throw Exception(
        'Payload de leitura inválido para Step. Esperado 8 bytes, recebido ${bytes.length}',
      );
    }

    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    return data.getFloat32(0, Endian.little);
  }

  Future<bool> readLedState(String deviceId) async {
    final bytes = await UniversalBle.read(
      deviceId,
      BleUUIDs.ledService,
      BleUUIDs.ledCharacteristic,
    );

    final value = utf8.decode(bytes);
    return value.contains('1');
  }

  Stream<double> subscribeToSine(String deviceId) {
    return _characteristicUpdatesController.stream
        .where(
          (update) =>
              update.deviceId == deviceId &&
              update.characteristicId.toLowerCase() ==
                  BleUUIDs.sinCharacteristic.toLowerCase(),
        )
        .map((update) {
          final bytes = update.value;
          if (bytes.length < 4) return 0.0;
          final data = Uint8List.fromList(bytes).buffer.asByteData();
          return data.getFloat32(0, Endian.little);
        });
  }

  // --- Escrita de Atuadores ---

  Future<void> writeStep(String deviceId, double value) async {
    final byteData = ByteData(8);
    byteData.setFloat64(0, value, Endian.little);

    await UniversalBle.write(
      deviceId,
      BleUUIDs.sinService,
      BleUUIDs.stepCharacteristic,
      byteData.buffer.asUint8List(),
    );
  }

  Future<void> writeLedState(String deviceId, bool turnOn) async {
    final payload = Uint8List.fromList([turnOn ? 49 : 48]); // '1' ou '0' ASCII

    await UniversalBle.write(
      deviceId,
      BleUUIDs.ledService,
      BleUUIDs.ledCharacteristic,
      payload,
    );
  }

  Future<void> setSineNotifications(String deviceId, bool enable) async {
    if (enable) {
      await UniversalBle.subscribeNotifications(
        deviceId,
        BleUUIDs.sinService,
        BleUUIDs.sinCharacteristic,
      );
    } else {
      await UniversalBle.unsubscribe(
        deviceId,
        BleUUIDs.sinService,
        BleUUIDs.sinCharacteristic,
      );
    }
  }

  // --- Utilitários Internos ---

  StreamController<BleConnectionState> _getConnectionStream(String deviceId) {
    if (!_connectionStateControllers.containsKey(deviceId)) {
      _connectionStateControllers[deviceId] =
          StreamController<BleConnectionState>.broadcast();
    }
    return _connectionStateControllers[deviceId]!;
  }

  void dispose() {
    _scanResultsController.close();
    _isScanningController.close();
    _characteristicUpdatesController.close();
    for (var controller in _connectionStateControllers.values) {
      controller.close();
    }
  }
}

class _CharacteristicUpdate {
  final String deviceId;
  final String characteristicId;
  final Uint8List value;

  const _CharacteristicUpdate({
    required this.deviceId,
    required this.characteristicId,
    required this.value,
  });
}
