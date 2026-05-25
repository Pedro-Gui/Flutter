import 'dart:async';

import 'package:ble/models/ble_sys_device.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_ble/universal_ble.dart';

import 'ble_repository.dart';

part 'ble_controller.g.dart';

@Riverpod(keepAlive: true)
BleRepository bleRepository(Ref ref) {
  final repository = BleRepository();
  ref.onDispose(() {
    repository.dispose();
  });
  return repository;
}

@Riverpod(keepAlive: true)
class BleController extends _$BleController {
  StreamSubscription<BleConnectionState>? _connectionSubscription;

  @override
  SysBleDevice? build() {
    ref.onDispose(() {
      _connectionSubscription?.cancel();
    });
    return null;
  }

  Future<void> connect(SysBleDevice device) async {
    final repository = ref.read(bleRepositoryProvider);

    try {
      await repository.connect(device.id);
      state = device;
      _listenToConnectionChanges(device);
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  void _listenToConnectionChanges(SysBleDevice device) {
    _connectionSubscription?.cancel();

    _connectionSubscription = ref
        .read(bleRepositoryProvider)
        .connectionStateStream(device.id)
        .listen((connectionState) {
          if (connectionState == BleConnectionState.disconnected) {
            state = null;
            _connectionSubscription?.cancel();
          }
        });
  }

  Future<void> disconnect() async {
    final device = state;
    if (device == null) return;

    await ref.read(bleRepositoryProvider).disconnect(device.id);
    _connectionSubscription?.cancel();
    state = null;
  }

  Future<double> getStep() async {
    final device = _ensureConnected();
    return await ref.read(bleRepositoryProvider).readStep(device.id);
  }

  Future<bool> getLedState() async {
    final device = _ensureConnected();
    return await ref.read(bleRepositoryProvider).readLedState(device.id);
  }

  Future<void> setLed(bool turnOn) async {
    final device = _ensureConnected();
    await ref.read(bleRepositoryProvider).writeLedState(device.id, turnOn);
  }

  Future<void> setStep(double step) {
    final device = _ensureConnected();
    return ref.read(bleRepositoryProvider).writeStep(device.id, step);
  }

  SysBleDevice _ensureConnected() {
    final device = state;
    if (device == null) {
      throw StateError('Tentativa de operação BLE sem dispositivo conectado.');
    }
    return device;
  }
}

/// Expõe a situação do scan BLE.
@riverpod
Stream<bool> isBleScanning(Ref ref) {
  return ref.watch(bleRepositoryProvider).isScanning;
}

/// Controladora de varredura de dispositivos BLE.
@riverpod
class BleScanner extends _$BleScanner {
  BleRepository get _repository => ref.read(bleRepositoryProvider);

  @override
  Stream<List<SysBleDevice>> build() {
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

/// Controladora de streaming de dados em tempo real da Senoide.
@riverpod
class SineGraphData extends _$SineGraphData {
  late BleRepository _repository;
  late SysBleDevice? _device;

  StreamSubscription<double>? _subscription;
  Timer? _renderTimer;

  int _xCounter = 0;

  final List<FlSpot> _allPoints = [];
  int _windowSize = 500;
  
  @override
  List<FlSpot> build() {
    _repository = ref.read(bleRepositoryProvider);
    _device = ref.watch(bleControllerProvider);

    ref.onDispose(stop);
    return [];
  }

  Future<void> start() async {
    if (_device == null) return;

    await stop();

    _renderTimer = Timer.periodic(const Duration(milliseconds: 20), (_) {
      if (ref.mounted) {
        state = _getVisibleWindow();
      }
    });

    await _repository.setSineNotifications(_device!.id, true);

    _subscription = _repository.subscribeToSine(_device!.id).listen((yValue) {
      if (!ref.mounted) return;
      _addPoint(yValue);
    });
  }

  List<FlSpot> _getVisibleWindow() {
    if (_allPoints.length <= _windowSize) return List.unmodifiable(_allPoints);
    return List.unmodifiable(_allPoints.sublist(_allPoints.length - _windowSize));
  }

  Future<void> stop() async {
    _renderTimer?.cancel();
    _renderTimer = null;

    if (_device != null) {
      try {
        await _repository.setSineNotifications(_device!.id, false);
      } catch (_) {}
    }

    await _subscription?.cancel();
    _subscription = null;
  }

  void flush() {
    _allPoints.clear();
    state = [];
    _xCounter = 0;
  }

  void _addPoint(double yValue) {
    _xCounter += 1;
    _allPoints.add(FlSpot(_xCounter.toDouble(), yValue));
  }

  void setWindowSize(int size) {
    if (size <= 0) return;
    _windowSize = size;
    if (size > _xCounter) _windowSize = _xCounter;
    
    state = _getVisibleWindow();
  }

  List<FlSpot> get history => List.unmodifiable(_allPoints);
  int get windowSize => _windowSize;
}
