import 'dart:async';
import 'dart:ffi';

import 'package:plot_ble/models/ble_sys_device.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:plot_ble/services/ble/ble_uuids.dart';
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

  Future<double> getH() async {
    final device = _ensureConnected();
    return await ref
        .read(bleRepositoryProvider)
        .readCharacteristic<double>(
          device.id,
          BleUUIDs.CONTROL_UUID,
          BleUUIDs.H_UUID,
        );
  }

  Future<bool> getLedState() async {
    final device = _ensureConnected();
    return await ref
        .read(bleRepositoryProvider)
        .readCharacteristic<bool>(
          device.id,
          BleUUIDs.LED_ACTUATOR_UUID,
          BleUUIDs.LED_CARAC_UUID,
        );
  }

  Future<void> setLed(bool turnOn) async {
    final device = _ensureConnected();
    await ref
        .read(bleRepositoryProvider)
        .writeOnCaracteristic<bool>(
          device.id,
          BleUUIDs.LED_ACTUATOR_UUID,
          BleUUIDs.LED_CARAC_UUID,
          turnOn,
        );
  }

  Future<void> setH(double h) {
    final device = _ensureConnected();
    return ref
        .read(bleRepositoryProvider)
        .writeOnCaracteristic<double>(
          device.id,
          BleUUIDs.CONTROL_UUID,
          BleUUIDs.H_UUID,
          h,
        );
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

/// Controladora de streaming de dados em tempo real para o grafico.
@riverpod
class SineGraphData extends _$SineGraphData {
  late BleRepository _repository;
  late SysBleDevice? _device;

  final List<StreamSubscription> _subscriptions = [];
  Timer? _renderTimer;

  // Janela móvel de plotagem.
  int _windowSize = 500;
  int get windowSize => _windowSize;
  // Buffer de auxiliares
  int? _currentT;
  double? _currentYk;
  double? _currentYc;
  double? _currentYf;
  double? _currentYa;

  // Histórico de pontos por linha
  final List<FlSpot> _ykPoints = [];
  final List<FlSpot> _ycPoints = [];
  final List<FlSpot> _yfPoints = [];
  final List<FlSpot> _yaPoints = [];

  @override
  Map<String, List<FlSpot>> build() {
    _repository = ref.read(bleRepositoryProvider);
    _device = ref.watch(bleControllerProvider);

    ref.onDispose(stop);
    return _getEmptyState();
  }

  Map<String, List<FlSpot>> _getEmptyState() {
    return {'yk': [], 'yc': [], 'yf': [], 'ya': []};
  }

  Future<void> start() async {
    if (_device == null) return;
    await stop();

    _renderTimer = Timer.periodic(const Duration(milliseconds: 20), (_) {
      if (ref.mounted) {
        state = _getVisibleWindow();
      }
    });

    final deviceId = _device!.id;

    await _enableNotifications(deviceId, true);

    _subscriptions.add(
      _repository
          .subscribeToCarac<int>(
            deviceId,
            BleUUIDs.SAMPLE_UUID,
            BleUUIDs.T_UUID,
          )
          .listen((val) {
            _processSample(t: val);
          }),
    );

    _subscriptions.add(
      _repository
          .subscribeToCarac<double>(
            deviceId,
            BleUUIDs.SAMPLE_UUID,
            BleUUIDs.YK_UUID,
          )
          .listen((val) {
            _processSample(yk: val);
          }),
    );

    _subscriptions.add(
      _repository
          .subscribeToCarac<double>(
            deviceId,
            BleUUIDs.SAMPLE_UUID,
            BleUUIDs.YC_UUID,
          )
          .listen((val) {
            _processSample(yc: val);
          }),
    );

    _subscriptions.add(
      _repository
          .subscribeToCarac<double>(
            deviceId,
            BleUUIDs.SAMPLE_UUID,
            BleUUIDs.YF_UUID,
          )
          .listen((val) {
            _processSample(yf: val);
          }),
    );

    _subscriptions.add(
      _repository
          .subscribeToCarac<double>(
            deviceId,
            BleUUIDs.SAMPLE_UUID,
            BleUUIDs.YA_UUID,
          )
          .listen((val) {
            _processSample(ya: val);
          }),
    );
  }

  void _processSample({
    int? t,
    double? yk,
    double? yc,
    double? yf,
    double? ya,
  }) {
    if (t != null) {
      if (_currentT != null) {
        final double tAux = _currentT!.toDouble();
        _ykPoints.add(FlSpot(tAux, _currentYk ?? 0.0));
        _ycPoints.add(FlSpot(tAux, _currentYc ?? 0.0));
        _yfPoints.add(FlSpot(tAux, _currentYf ?? 0.0));
        _yaPoints.add(FlSpot(tAux, _currentYa ?? 0.0));
      }
      _currentT = t;
    }

    if (yk != null) _currentYk = yk;
    if (yc != null) _currentYc = yc;
    if (yf != null) _currentYf = yf;
    if (ya != null) _currentYa = ya;
  }

  Map<String, List<FlSpot>> _getVisibleWindow() {
    return {
      'yk': _sliceWindow(_ykPoints),
      'yc': _sliceWindow(_ycPoints),
      'yf': _sliceWindow(_yfPoints),
      'ya': _sliceWindow(_yaPoints),
    };
  }

  List<FlSpot> _sliceWindow(List<FlSpot> list) {
    if (list.length <= _windowSize) return List.unmodifiable(list);
    return List.unmodifiable(list.sublist(list.length - _windowSize));
  }

  Future<void> stop() async {
    _renderTimer?.cancel();
    _renderTimer = null;

    if (_device != null) {
      try {
        await _enableNotifications(_device!.id, false);
      } catch (_) {}
    }

    for (var sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
  }

  Future<void> _enableNotifications(String deviceId, bool enable) async {
    await _repository.setNotifications(
      deviceId,
      BleUUIDs.SAMPLE_UUID,
      BleUUIDs.T_UUID,
      enable,
    );
    await _repository.setNotifications(
      deviceId,
      BleUUIDs.SAMPLE_UUID,
      BleUUIDs.YK_UUID,
      enable,
    );
    await _repository.setNotifications(
      deviceId,
      BleUUIDs.SAMPLE_UUID,
      BleUUIDs.YC_UUID,
      enable,
    );
    await _repository.setNotifications(
      deviceId,
      BleUUIDs.SAMPLE_UUID,
      BleUUIDs.YF_UUID,
      enable,
    );
    await _repository.setNotifications(
      deviceId,
      BleUUIDs.SAMPLE_UUID,
      BleUUIDs.YA_UUID,
      enable,
    );
  }

  void flush() {
    _ykPoints.clear();
    _ycPoints.clear();
    _yfPoints.clear();
    _yaPoints.clear();
    _currentT = null;
    state = _getEmptyState();
  }

  void setWindowSize(int size) {
    if (size <= 0) return;
    _windowSize = size;
    state = _getVisibleWindow();
  }
}
