import 'dart:async';
import 'dart:typed_data';
import 'package:plot_ble/models/ble_sys_device.dart';
import 'package:universal_ble/universal_ble.dart';

class BleRepository {
  final _scanResultsController =
      StreamController<List<SysBleDevice>>.broadcast();
  final _isScanningController = StreamController<bool>.broadcast();
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

    Future.delayed(const Duration(seconds: 20), () {
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

  // --- Leitura e Escrita de Valores ---

  Future<T> readCharacteristic<T>(
    String deviceId,
    String serviceId,
    String characteristicId,
  ) async {
    final bytes = await UniversalBle.read(
      deviceId,
      serviceId,
      characteristicId,
    );

    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));

    switch (T) {
      case == double:
        if (byteData.lengthInBytes < 8) {
          throw Exception(
            'Leitura inválida. Esperado 8 bytes, recebido ${bytes.length}',
          );
        }
        return byteData.getFloat64(0, Endian.little) as T;

      case == int:
        if (byteData.lengthInBytes < 4) {
          throw Exception(
            'Leitura inválida. Esperado 4 bytes, recebido ${bytes.length}',
          );
        }
        return byteData.getInt32(0, Endian.little) as T;
      case == bool:
        if (bytes.isEmpty) {
          throw Exception('Leitura inválida para bool. Nenhum byte recebido.');
        }
        return (bytes[0] != 0) as T;

      default:
        throw Exception('$T não suportado');
    }
  }

  Stream<T> subscribeToCarac<T>(
    String deviceId,
    String serviceId,
    String characteristicId,
  ) {
    return _characteristicUpdatesController.stream
        .where(
          (update) =>
              update.deviceId == deviceId &&
              update.characteristicId.toLowerCase() ==
                  characteristicId.toLowerCase(),
        )
        .map((update) {
          final bytes = update.value;
          final byteData = ByteData.sublistView(Uint8List.fromList(bytes));

          switch (T) {
            case == double:
              if (byteData.lengthInBytes < 8) return 0.0 as T;
              return byteData.getFloat64(0, Endian.little) as T;

            case == int:
              if (byteData.lengthInBytes < 4) return 0 as T;
              return byteData.getUint32(0, Endian.little) as T;

            default:
              throw Exception('$T não suportado');
          }
        });
  }

  Future<void> writeOnCaracteristic<T>(
    String deviceId,
    String serviceId,
    String characteristicId,
    T value,
  ) async {
    Uint8List payload;

    switch (T) {
      case == double:
        final byteData = ByteData(8);
        byteData.setFloat64(0, value as double, Endian.little);
        payload = byteData.buffer.asUint8List();
        break;

      case == int:
        final byteData = ByteData(4);
        byteData.setUint32(0, value as int, Endian.little);
        payload = byteData.buffer.asUint8List();
        break;

      case == bool:
        final isTrue = value as bool;
        payload = Uint8List.fromList([isTrue ? 1 : 0]);
        break;

      default:
        throw Exception('$T não suportado');
    }

    await UniversalBle.write(deviceId, serviceId, characteristicId, payload);
  }

  Future<void> setNotifications(
    String deviceId,
    String serviceId,
    String characteristicId,
    bool enable,
  ) async {
    if (enable) {
      await UniversalBle.subscribeNotifications(
        deviceId,
        serviceId,
        characteristicId,
      );
    } else {
      await UniversalBle.unsubscribe(deviceId, serviceId, characteristicId);
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
