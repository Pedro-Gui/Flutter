import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../pages/ble_connected_page.dart';
import '../../pages/ble_scanner_page.dart';
import '../ble/ble_controller.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final bleStateNotifier = ValueNotifier<bool>(false);
  ref.listen<BluetoothDevice?>(bleControllerProvider, (_, next) {
    bleStateNotifier.value = next != null;
  });

  ref.onDispose(() {
    bleStateNotifier.dispose();
  });

  return GoRouter(
    initialLocation: '/scanner',
    refreshListenable: bleStateNotifier,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (context, state) => const BleScannerPage(),
      ),
      GoRoute(
        path: '/connected',
        name: 'connected',
        builder: (context, state) => const BleConnectedPage(),
      ),
    ],
    redirect: (context, state) {
      final isConnected = ref.read(bleControllerProvider) != null;
      final isScannerRoute = state.uri.path == '/scanner';
      if (!isConnected && !isScannerRoute) {
        return '/scanner';
      }

      if (isConnected && isScannerRoute) {
        return '/connected';
      }

      return null;
    },
  );
}
