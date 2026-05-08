// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meteor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(meteorClient)
final meteorClientProvider = MeteorClientProvider._();

final class MeteorClientProvider
    extends $FunctionalProvider<MeteorClient, MeteorClient, MeteorClient>
    with $Provider<MeteorClient> {
  MeteorClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'meteorClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$meteorClientHash();

  @$internal
  @override
  $ProviderElement<MeteorClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MeteorClient create(Ref ref) {
    return meteorClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MeteorClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MeteorClient>(value),
    );
  }
}

String _$meteorClientHash() => r'd7f4ff99f7dad932900806a2a19d23be5adbcb43';
