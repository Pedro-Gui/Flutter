import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'package:plot_ble/components/sys_drawer.dart';
import 'package:plot_ble/components/sys_edit_painel.dart';
import 'package:plot_ble/components/sys_chart.dart';
import 'package:plot_ble/services/ble/ble_controller.dart';
import 'package:plot_ble/services/ble/ble_uuids.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BleConnectedPage extends ConsumerStatefulWidget {
  const BleConnectedPage({super.key});

  @override
  ConsumerState<BleConnectedPage> createState() => _BleConnectedPageState();
}

class _BleConnectedPageState extends ConsumerState<BleConnectedPage> {
  double _hState = 1.0;
  double _aState = 2.0;
  double _bState = 10.0;
  int _mState = 1;
  bool _ledState = true;

  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHardwareState();
    });
  }

  Future<void> _loadHardwareState() async {
    try {
      final controller = ref.read(bleControllerProvider.notifier);

      final initialLed = await controller.readCarac<bool>(
        BleUUIDs.LED_ACTUATOR_UUID,
        BleUUIDs.LED_CARAC_UUID,
      );
      final initialH = await controller.readCarac<double>(
        BleUUIDs.CONTROL_UUID,
        BleUUIDs.H_UUID,
      );
      final initialM = await controller.readCarac<int>(
        BleUUIDs.CONTROL_UUID,
        BleUUIDs.M_UUID,
      );
      final initialA = await controller.readCarac<double>(
        BleUUIDs.CONTROL_UUID,
        BleUUIDs.A_UUID,
      );
      final initialB = await controller.readCarac<double>(
        BleUUIDs.CONTROL_UUID,
        BleUUIDs.B_UUID,
      );

      if (mounted) {
        setState(() {
          _hState = initialH;
          _aState = initialA;
          _bState = initialB;
          _ledState = initialLed;
          _mState = initialM;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao ler estado do hardware: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<Uint8List?> _captureChart() async {
    try {
      final boundary =
          _chartKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Erro ao capturar gráfico: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final graphPoints = ref.watch(graphDataProvider);
    final graphDataNotifier = ref.watch(graphDataProvider.notifier);
    final bleController = ref.read(bleControllerProvider);
    final bleControllerNotifier = ref.watch(bleControllerProvider.notifier);
    final bool isActive = ref.watch(graphDataProvider.select((_) => graphDataNotifier.isListening));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          bleController?.name ?? 'Desconectado',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),

        centerTitle: true,
        actions: [
          if(bleController?.name.isNotEmpty ?? false) 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: isActive
                    ? Theme.of(context).colorScheme.onError
                    : Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                  if (isActive) {
                  graphDataNotifier.stop();
                } else {
                  graphDataNotifier.start();
                }
              },
              icon: Icon(isActive ? Icons.stop : Icons.play_arrow),
              label: Text(isActive ? 'Pause' : 'Start'),
                        ),
            )
          else Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () async{
                  try {
                    await bleControllerNotifier.reconnect();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Falha ao reconectar: $e')),
                      );
                    }
                  }
              },
              icon:const Icon(Icons.bluetooth_connected),
              label: const Text('Reconectar'),
            ),
          ),
        ],
      ),
      drawer: SysDrawer(captureChart: _captureChart),

      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 62.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: graphPoints.isEmpty
                    ? const Center(
                        child: Text('Nenhum dado recebido ainda...'),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: constraints.maxHeight - 62.0,
                            ),
                            child: RepaintBoundary(
                              key: _chartKey,
                              child: SysChart(graphPoints: graphPoints),
                            ),
                          );
                        },
                      ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SysEditPainel(
                hState: _hState,
                mState: _mState,
                aState: _aState,
                bState: _bState,
                ledState: _ledState,
                ref: ref,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
