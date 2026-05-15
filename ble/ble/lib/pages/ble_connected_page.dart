import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ble/services/ble/ble_controller.dart';
import 'package:ble/services/export/export_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BleConnectedPage extends ConsumerStatefulWidget {
  const BleConnectedPage({super.key});

  @override
  ConsumerState<BleConnectedPage> createState() => _BleConnectedPageState();
}

class _BleConnectedPageState extends ConsumerState<BleConnectedPage> {
  double _sliderValue = 0.0;
  bool _ledState = false;
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
      final initialStep = await controller.getStep();
      final initialLed = await controller.getLedState();

      if (mounted) {
        setState(() {
          _sliderValue = initialStep;
          _ledState = initialLed;
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
    final points = ref.watch(sineGraphDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Senoide BLE'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(bleControllerProvider.notifier).disconnect();
            },
            icon: const Icon(Icons.bluetooth_disabled),
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            tooltip: 'Exportar Dados',
            onSelected: (String format) async {
              final points = ref.read(sineGraphDataProvider);

              if (points.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nenhum dado para exportar!')),
                );
                return;
              }
              try {
                if (format == 'Matlab')await ExportService.exportToMatlab(points);
                if (format == 'txt') await ExportService.exportToTxt(points);
                if (format == 'xml') await ExportService.exportToXml(points);
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(sineGraphDataProvider.notifier).start(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(sineGraphDataProvider.notifier).stop(),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(sineGraphDataProvider.notifier).flush(),
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Flush'),
                  ),
                ],
              ),
            ),

            // --- Área do Gráfico ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: points.isEmpty
                    ? const Center(child: Text('Nenhum dado recebido ainda...'))
                    : RepaintBoundary(
                        key: _chartKey,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: points,
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                          duration: Duration.zero,
                        ),
                      ),
              ),
            ),

            // --- Interation menu: STEP, LED STATE ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ref
                          .read(bleControllerProvider.notifier)
                          .toggleLed();

                      setState(() {
                        _ledState = !_ledState;
                      });
                    },
                    icon: Icon(
                      _ledState ? Icons.light_mode : Icons.light_mode_outlined,
                    ),
                    label: const Text('Toggle LED'),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Slider(
                      min: 0,
                      max: 1,
                      value: _sliderValue,
                      showValueIndicator: ShowValueIndicator.alwaysVisible,
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                        });
                      },
                      onChangeEnd: (value) {
                        ref.read(bleControllerProvider.notifier).setStep(value);
                      },
                    ),
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
