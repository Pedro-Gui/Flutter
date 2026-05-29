import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plot_ble/components/sys_spinner.dart';
import 'package:plot_ble/components/sys_chart.dart';
import 'package:plot_ble/services/ble/ble_controller.dart';
import 'package:plot_ble/services/export/export_service.dart';
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
  bool _ledState = true;
  int _windowValue = 0;
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
      final initialLed = await controller.getLed();
      final initialH = await controller.getH();
      final initialWindowValue = ref
          .read(sineGraphDataProvider.notifier)
          .windowSize;

      if (mounted) {
        setState(() {
          _hState = initialH;
          _ledState = initialLed;
          _windowValue = initialWindowValue;
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

  Widget getConectionButton() {
    final connectedDevice = ref.watch(bleControllerProvider);
    final bleController = ref.watch(bleControllerProvider.notifier);

    if (bleController.isConnecting) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    if (connectedDevice != null) {
      return IconButton(
        tooltip: 'Desconectar Dispositivo',
        icon: const Icon(Icons.bluetooth_disabled),
        onPressed: () async {
          await bleController.disconnect();
          if (mounted) {
            context.go('/scanner');
          }
        },
      );
    }

    if (bleController.hasLastDevice) {
      return IconButton(
        tooltip: 'Reconectar ao Microcontrolador',
        icon: const Icon(Icons.bluetooth_connected),
        onPressed: () async {
          try {
            await bleController.reconnect();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Falha ao reconectar: $e')),
              );
            }
          }
        },
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final graphPoints = ref.watch(sineGraphDataProvider);
    final graphDataNotifier = ref.watch(sineGraphDataProvider.notifier);
    final bleController = ref.read(bleControllerProvider);
    final bleControllerNotifier = ref.read(bleControllerProvider.notifier);
    final bool isActive = graphDataNotifier.isListening;

    
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
          getConectionButton(),

          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            tooltip: 'Exportar Dados',
            onSelected: (String format) async {
              if (graphPoints.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nenhum dado para exportar!')),
                );
                return;
              }
              try {
                if (format == 'Matlab') {
                  await ExportService.exportToMatlab(graphPoints);
                }
                if (format == 'txt') {
                  await ExportService.exportToTxt(graphPoints);
                }
                if (format == 'xml') {
                  await ExportService.exportToXml(graphPoints);
                }
                if (format == 'pdf') {
                  final imageBytes = await _captureChart();
                  await ExportService.exportToPdf(imageBytes);
                }
                if (format == 'png') {
                  final imageBytes = await _captureChart();
                  await ExportService.exportToPng(imageBytes);
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro na exportação: $e')),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Matlab',
                child: ListTile(
                  leading: Icon(Icons.calculate, color: Colors.blue),
                  title: Text('Exportar como MATLAB'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'txt',
                child: ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Exportar como TXT'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'xml',
                child: ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Exportar como XML'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'pdf',
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text('Exportar como Imagem (PDF)'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'png',
                child: ListTile(
                  leading: Icon(Icons.image, color: Colors.green),
                  title: Text('Exportar como Imagem (PNG)'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Painel de Controle do Gráfico ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Divider(thickness: 0.5, color: Colors.grey[400]),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
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
                        label: Text(isActive ? 'Stop' : 'Start'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        onPressed: () => graphDataNotifier.flush(),
                        icon: Icon(
                          Icons.delete_sweep,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        label: Text(
                          'Flush',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      SysSpinner<int>(
                        value: _windowValue,
                        title: 'N° Pontos:',
                        maxValue:
                            (graphPoints['yk'] != null &&
                                graphPoints['yk']!.isNotEmpty)
                            ? graphPoints['yk']!.last.x.toInt()
                            : 100,
                        step: 100,
                        onSubmitted: (x) {
                          graphDataNotifier.setWindowSize(x);
                          setState(() {
                            _windowValue = x;
                          });
                        },
                      ),
                    ],
                  ),

                  
                ],
              ),
            ),

            // --- Área do Gráfico ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: graphPoints.isEmpty
                    ? const Center(child: Text('Nenhum dado recebido ainda...'))
                    : RepaintBoundary(
                        key: _chartKey,
                        child: SysChart(graphPoints: graphPoints)
                      ),
              ),
            ),

            // --- Interation menu ---
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                children: [
                  Divider(thickness: 0.5, color: Colors.grey[400]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        onPressed: () async {
                          await bleControllerNotifier.setLed(!_ledState);
                          setState(() {
                            _ledState = !_ledState;
                          });
                        },
                        icon: Icon(
                          _ledState
                              ? Icons.light_mode
                              : Icons.light_mode_outlined,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        label: Text(
                          'Toggle LED',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SysSpinner<double>(
                          value: _hState,
                          title: 'Intervalo de amostragem H:',
                          maxValue: 10,
                          step: 0.1,
                          onSubmitted: (x) {
                            bleControllerNotifier.setH(x);
                            setState(() {
                              _hState = x;
                            });
                          },
                        ),
                      ),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        onPressed: () async {
                          await bleControllerNotifier.setOK(true);
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        label: Text(
                          'SEND',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
