import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:plot_ble/components/size_spinner.dart';
import 'package:plot_ble/services/ble/ble_controller.dart';
import 'package:plot_ble/services/export/export_service.dart';
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
  double _hState = 1.0;
  bool _ledState = false;
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
      final initialLed = await controller.getLedState();
      final _hState = await controller.getH();

      final notifier = ref.read(sineGraphDataProvider.notifier);
      final initialWindowValue = notifier.windowSize;

      if (mounted) {
        setState(() {
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

  @override
  Widget build(BuildContext context) {
    final points = ref.watch(sineGraphDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Senoide BLE - ${ref.read(bleControllerProvider)?.name ?? 'Desconectado'}',
        ),
        centerTitle: true,
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
                if (format == 'Matlab') {
                  await ExportService.exportToMatlab(points);
                }
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        onPressed: () =>
                            ref.read(sineGraphDataProvider.notifier).start(),
                        icon: Icon(
                          Icons.play_arrow,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        label: Text(
                          'Start',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        onPressed: () =>
                            ref.read(sineGraphDataProvider.notifier).stop(),
                        icon: Icon(
                          Icons.stop,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        label: Text(
                          'Stop',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        onPressed: () =>
                            ref.read(sineGraphDataProvider.notifier).flush(),
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
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizeSpinner(
                      value: _windowValue,
                      maxValue: points.isEmpty
                          ? points['yk']!.last.x.toInt()
                          : 100,
                      onSubmitted: (x) {
                        ref
                            .read(sineGraphDataProvider.notifier)
                            .setWindowSize(x);
                        setState(() {
                          _windowValue = x;
                        });
                      },
                    ),
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
                            borderData: FlBorderData(show: true),

                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              // EIXO X
                              bottomTitles: AxisTitles(
                                axisNameWidget: const Text(
                                  'Amostras',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                axisNameSize: 22,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // EIXO Y
                              leftTitles: AxisTitles(
                                axisNameWidget: const Text(
                                  'Amplitude',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                axisNameSize: 24,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        value.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: points['yk'] ?? [],
                                isCurved: false,
                                color: Colors.blue,
                                barWidth: 2,
                                isStrokeCapRound: false,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                          duration: Duration.zero,
                        ),
                      ),
              ),
            ),

            // --- Interation menu ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () async {
                      await ref
                          .read(bleControllerProvider.notifier)
                          .setLed(!_ledState);

                      setState(() {
                        _ledState = !_ledState;
                      });
                    },
                    icon: Icon(
                      _ledState ? Icons.light_mode : Icons.light_mode_outlined,
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
                    child: SizeSpinner(
                      value: _hState.toInt(),
                      maxValue: 10,
                      step: 1,
                      onSubmitted: (x) {
                        ref.read(bleControllerProvider.notifier).setH(x.toDouble());
                        setState(() {
                          _hState = x.toDouble();
                        });
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
