import 'package:plot_ble/components/scan_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot_ble/services/ble/ble_controller.dart';
import 'package:plot_ble/services/ble/ble_permission.dart';

class BleScannerPage extends ConsumerStatefulWidget {
  const BleScannerPage({super.key});

  @override
  ConsumerState<BleScannerPage> createState() => _BleScannerPageState();
}

class _BleScannerPageState extends ConsumerState<BleScannerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAndScan();
    });
  }

  Future<void> _checkPermissionsAndScan() async {
    final hasPermissions = await PermissionService.requestBlePermissions();
    if (hasPermissions && mounted) {
      ref.read(bleScannerProvider.notifier).startScan();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permissões de Bluetooth negadas. O app não pode prosseguir.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanResultsAsync = ref.watch(bleScannerProvider);
    final isScanningAsync = ref.watch(isBleScanningProvider);

    final isScanning = isScanningAsync.value ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(
          'Scanner BLE',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ), centerTitle: true),
      body: SafeArea(
        child: scanResultsAsync.when(
          data: (results) {
            if (results.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhum dispositivo encontrado.\nAperte o botão para escanear.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final scanResult = results[index];

                return ScanTile(
                  result: scanResult,
                  onTap: () {
                    ref.read(bleScannerProvider.notifier).stopScan();
                    ref
                        .read(bleControllerProvider.notifier)
                        .connect(scanResult);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Erro ao escanear: $error')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isScanning
            ? () => ref.read(bleScannerProvider.notifier).stopScan()
            : () =>  _checkPermissionsAndScan(),
        backgroundColor: isScanning
            ? Colors.red
            : Theme.of(context).colorScheme.primary,
        child: Icon(
          isScanning ? Icons.stop : Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}
