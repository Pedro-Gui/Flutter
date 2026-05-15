import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_repository.dart';

part 'ble_controller.g.dart';

@Riverpod(keepAlive: true)
BleRepository bleRepository(Ref ref) => const BleRepository();

/// Controladora de conexão com o dispositivo BLE  ESP32_sin
@Riverpod(keepAlive: true)
class BleController extends _$BleController {
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  @override
  BluetoothDevice? build() {
    ref.onDispose(() {
      _connectionSubscription?.cancel();
    });
    return null;
  }

  Future<void> connect(BluetoothDevice device) async {
    final repository = ref.read(bleRepositoryProvider);

    try {
      await repository.connect(device);
      state = device;
      _listenToConnectionChanges(device);
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  void _listenToConnectionChanges(BluetoothDevice device) {
    _connectionSubscription?.cancel();

    _connectionSubscription = ref
        .read(bleRepositoryProvider)
        .connectionStateStream(device)
        .listen((connectionState) {
          if (connectionState == BluetoothConnectionState.disconnected) {
            state = null;
            _connectionSubscription?.cancel();
          }
        });
  }

  Future<void> disconnect() async {
    final device = state;
    if (device == null) return;

    await ref.read(bleRepositoryProvider).disconnect(device);
    _connectionSubscription?.cancel();
    state = null;
  }

  Future<double> getStep() async {
    final device = _ensureConnected();
    return await ref.read(bleRepositoryProvider).readStep(device);
  }

  Future<bool> getLedState() async {
    final device = _ensureConnected();
    return await ref.read(bleRepositoryProvider).readLedState(device);
  }

  Future<void> toggleLed() {
    final device = _ensureConnected();
    return ref.read(bleRepositoryProvider).writeLedState(device);
  }

  Future<void> setStep(double step) {
    final device = _ensureConnected();
    return ref.read(bleRepositoryProvider).writeStep(device, step);
  }

  BluetoothDevice _ensureConnected() {
    final device = state;
    if (device == null) {
      throw StateError('Tentativa de operação BLE sem dispositivo conectado.');
    }
    return device;
  }
}

/// Expõe a situação do scan BLE
@riverpod
Stream<bool> isBleScanning(Ref ref) {
  return ref.watch(bleRepositoryProvider).isScanning;
}

/// Controladora de varredura de dispositivos BLE
@riverpod
class BleScanner extends _$BleScanner {
  BleRepository get _repository => ref.read(bleRepositoryProvider);

  @override
  Stream<List<ScanResult>> build() {
    return _repository.scanResults;
  }

  Future<void> startScan() async {
    try {
      await _repository.startScan();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stopScan() async {
    try {
      await _repository.stopScan();
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
class SineGraphData extends _$SineGraphData {
  late BleRepository _repository;
  late BluetoothDevice? _device;

  StreamSubscription<double>? _subscription;
  double _xCounter = 0;

  @override
  List<FlSpot> build() {
    _repository = ref.read(bleRepositoryProvider);
    _device = ref.read(bleControllerProvider);

    ref.onDispose(() {
      stop();
    });
    return [];
  }

  Future<void> start() async {
    if (_device == null) return;
    await _subscription?.cancel();

    await _repository.setSineNotifications(_device!, true);
    _subscription = _repository.subscribeToSine(_device!).listen((yValue) {
      if (!ref.mounted) return;
      _addPoint(yValue);
    });
  }

  Future<void> stop() async {
    if (_device != null) {
      await _repository.setSineNotifications(_device!, false);
    }

    await _subscription?.cancel();
    _subscription = null;
  }

  void flush() {
    state = [];
    _xCounter = 0;
  }

  void _addPoint(double yValue) {
    if (!ref.mounted) return;
    _xCounter += 1;
    final currentSpots = List<FlSpot>.from(state);
    currentSpots.add(FlSpot(_xCounter, yValue));

    state = currentSpots;
  }
}
