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

String _$bleRepositoryHash() => r'f3f568b099dd27a7f8446a37b995b58f7e00d510';

@ProviderFor(BleController)
final bleControllerProvider = BleControllerProvider._();

final class BleControllerProvider
    extends $NotifierProvider<BleController, SysBleDevice?> {
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
  Override overrideWithValue(SysBleDevice? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SysBleDevice?>(value),
    );
  }
}

String _$bleControllerHash() => r'a042c292b56d809f8a69d553a332c99badab9aef';

abstract class _$BleController extends $Notifier<SysBleDevice?> {
  SysBleDevice? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SysBleDevice?, SysBleDevice?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SysBleDevice?, SysBleDevice?>,
              SysBleDevice?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Expõe a situação do scan BLE.

@ProviderFor(isBleScanning)
final isBleScanningProvider = IsBleScanningProvider._();

/// Expõe a situação do scan BLE.

final class IsBleScanningProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Expõe a situação do scan BLE.
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

/// Controladora de varredura de dispositivos BLE.

@ProviderFor(BleScanner)
final bleScannerProvider = BleScannerProvider._();

/// Controladora de varredura de dispositivos BLE.
final class BleScannerProvider
    extends $StreamNotifierProvider<BleScanner, List<SysBleDevice>> {
  /// Controladora de varredura de dispositivos BLE.
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

String _$bleScannerHash() => r'7b9b422b1ba6bfb0a44fea7011bb5813531502fa';

/// Controladora de varredura de dispositivos BLE.

abstract class _$BleScanner extends $StreamNotifier<List<SysBleDevice>> {
  Stream<List<SysBleDevice>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SysBleDevice>>, List<SysBleDevice>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SysBleDevice>>, List<SysBleDevice>>,
              AsyncValue<List<SysBleDevice>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Controladora de streaming de dados em tempo real para o grafico.

@ProviderFor(SineGraphData)
final sineGraphDataProvider = SineGraphDataProvider._();

/// Controladora de streaming de dados em tempo real para o grafico.
final class SineGraphDataProvider
    extends $NotifierProvider<SineGraphData, Map<String, List<FlSpot>>> {
  /// Controladora de streaming de dados em tempo real para o grafico.
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
  Override overrideWithValue(Map<String, List<FlSpot>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<FlSpot>>>(value),
    );
  }
}

String _$sineGraphDataHash() => r'1e897616c6467bb3d6b84690aa4bc0fbe4eeb556';

/// Controladora de streaming de dados em tempo real para o grafico.

abstract class _$SineGraphData extends $Notifier<Map<String, List<FlSpot>>> {
  Map<String, List<FlSpot>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<String, List<FlSpot>>, Map<String, List<FlSpot>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, List<FlSpot>>, Map<String, List<FlSpot>>>,
              Map<String, List<FlSpot>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
