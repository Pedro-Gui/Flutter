// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bleRepository)
final bleRepositoryProvider = BleRepositoryProvider._();

final class BleRepositoryProvider
    extends $FunctionalProvider<BleRepository, BleRepository, BleRepository>
    with $Provider<BleRepository> {
  BleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleRepositoryHash();

  @$internal
  @override
  $ProviderElement<BleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BleRepository create(Ref ref) {
    return bleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BleRepository>(value),
    );
  }
}

String _$bleRepositoryHash() => r'f92c1235ae5bdf09ce867ad2d00a433049c2ae1a';

/// Controladora de conexão com o dispositivo BLE  ESP32_sin

@ProviderFor(BleController)
final bleControllerProvider = BleControllerProvider._();

/// Controladora de conexão com o dispositivo BLE  ESP32_sin
final class BleControllerProvider
    extends $NotifierProvider<BleController, BluetoothDevice?> {
  /// Controladora de conexão com o dispositivo BLE  ESP32_sin
  BleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleControllerHash();

  @$internal
  @override
  BleController create() => BleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BluetoothDevice? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BluetoothDevice?>(value),
    );
  }
}

String _$bleControllerHash() => r'e545bb8b8707d060c9b193a0ad25db890599c5c4';

/// Controladora de conexão com o dispositivo BLE  ESP32_sin

abstract class _$BleController extends $Notifier<BluetoothDevice?> {
  BluetoothDevice? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BluetoothDevice?, BluetoothDevice?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BluetoothDevice?, BluetoothDevice?>,
              BluetoothDevice?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Expõe a situação do scan BLE

@ProviderFor(isBleScanning)
final isBleScanningProvider = IsBleScanningProvider._();

/// Expõe a situação do scan BLE

final class IsBleScanningProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Expõe a situação do scan BLE
  IsBleScanningProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isBleScanningProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isBleScanningHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return isBleScanning(ref);
  }
}

String _$isBleScanningHash() => r'89549ab49b63b834e98ba7099042de18cc228a3c';

/// Controladora de varredura de dispositivos BLE

@ProviderFor(BleScanner)
final bleScannerProvider = BleScannerProvider._();

/// Controladora de varredura de dispositivos BLE
final class BleScannerProvider
    extends $StreamNotifierProvider<BleScanner, List<ScanResult>> {
  /// Controladora de varredura de dispositivos BLE
  BleScannerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleScannerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleScannerHash();

  @$internal
  @override
  BleScanner create() => BleScanner();
}

String _$bleScannerHash() => r'62b932ed21e4a774e80808f26b72a92a095f1f81';

/// Controladora de varredura de dispositivos BLE

abstract class _$BleScanner extends $StreamNotifier<List<ScanResult>> {
  Stream<List<ScanResult>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ScanResult>>, List<ScanResult>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ScanResult>>, List<ScanResult>>,
              AsyncValue<List<ScanResult>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SineGraphData)
final sineGraphDataProvider = SineGraphDataProvider._();

final class SineGraphDataProvider
    extends $NotifierProvider<SineGraphData, List<FlSpot>> {
  SineGraphDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sineGraphDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sineGraphDataHash();

  @$internal
  @override
  SineGraphData create() => SineGraphData();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<FlSpot> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<FlSpot>>(value),
    );
  }
}

String _$sineGraphDataHash() => r'2d4fa4f3ec2cad1180402d78ff27d1286b209636';

abstract class _$SineGraphData extends $Notifier<List<FlSpot>> {
  List<FlSpot> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<FlSpot>, List<FlSpot>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<FlSpot>, List<FlSpot>>,
              List<FlSpot>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
