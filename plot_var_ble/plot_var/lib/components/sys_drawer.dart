import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plot_ble/components/sys_spinner.dart';
import 'package:plot_ble/services/ble/ble_controller.dart';
import 'package:plot_ble/services/export/export_service.dart';

class SysDrawer extends StatelessWidget {
  final Future<Uint8List?> Function() captureChart;

  const SysDrawer({super.key, required this.captureChart});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const _DrawerHeaderConnectedDevice(),
                  const _DrawerGraphPointsSpinner(),
                  _DrawerExportTile(captureChart: captureChart),
                ],
              ),
            ),
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(thickness: 0.5),
                _DrawerFlushDataTile(),
                _DrawerConnectionStateTile(),
                SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeaderConnectedDevice extends ConsumerWidget {
  const _DrawerHeaderConnectedDevice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceName = ref.watch(
      bleControllerProvider.select((device) => device?.name ?? 'Desconectado'),
    );

    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Center(
        child: Text(
          deviceName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _DrawerGraphPointsSpinner extends ConsumerWidget {
  const _DrawerGraphPointsSpinner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windowSize = ref.watch(graphDataProvider.notifier).windowSize;
    final lastXValue = ref.watch(
      graphDataProvider.select((data) {
        final points = data['yk'];
        if (points != null && points.isNotEmpty) {
          return points.last.x.toInt();
        }
        return 100;
      }),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SysSpinner<int>(
        value: windowSize,
        title: 'N° Pontos:',
        maxValue: lastXValue,
        step: 100,
        onSubmitted: (value) {
          ref.read(graphDataProvider.notifier).setWindowSize(value);
        },
      ),
    );
  }
}

class _DrawerExportTile extends ConsumerWidget {
  final Future<Uint8List?> Function() captureChart;

  const _DrawerExportTile({required this.captureChart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGraphEmpty = ref.watch(graphDataProvider.select((data) => data.isEmpty));

    return ListTile(
      leading: const Icon(Icons.share),
      title: const Text('Exportar Dados'),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.arrow_drop_down),
        tooltip: 'Formatos de Exportação',
        onSelected: (String format) async {
          if (isGraphEmpty) {
            _showSnackBar(context, 'Nenhum dado para exportar!');
            return;
          }

          try {
            final currentPoints = ref.read(graphDataProvider);

            switch (format) {
              case 'Matlab':
                await ExportService.exportToMatlab(currentPoints);
                break;
              case 'txt':
                await ExportService.exportToTxt(currentPoints);
                break;
              case 'xml':
                await ExportService.exportToXml(currentPoints);
                break;
              case 'pdf':
                final imageBytes = await captureChart();
                await ExportService.exportToPdf(imageBytes);
                break;
              case 'png':
                final imageBytes = await captureChart();
                await ExportService.exportToPng(imageBytes);
                break;
            }
            if (context.mounted) _showSnackBar(context, 'Exportado com sucesso!');
          } catch (e) {
            if (context.mounted) _showSnackBar(context, 'Erro na exportação: $e');
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'Matlab',
                              child: ListTile(
                                leading: Icon(
                                  Icons.calculate,
                                  color: Colors.blue,
                                ),
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
                                leading: Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                ),
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
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DrawerFlushDataTile extends ConsumerWidget {
  const _DrawerFlushDataTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.delete_sweep),
      title: const Text('Flush Dados'),
      onTap: () {
        ref.read(graphDataProvider.notifier).flush();
        context.pop();
      },
    );
  }
}

class _DrawerConnectionStateTile extends ConsumerWidget {
  const _DrawerConnectionStateTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectedDevice = ref.watch(bleControllerProvider);
    final bleController = ref.watch(bleControllerProvider.notifier);

    if (bleController.isConnecting) {
      return const ListTile(
        leading: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
        title: Text('Conectando...'),
      );
    }

    if (connectedDevice != null) {
      return ListTile(
        leading: const Icon(Icons.bluetooth_disabled, color: Colors.red),
        title: const Text('Desconectar Dispositivo'),
        onTap: () async {
          await bleController.disconnect();
          if (context.mounted) context.go('/scanner');
        },
      );
    }

    if (bleController.hasLastDevice) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.bluetooth_connected, color: Colors.green),
            title: const Text('Reconectar Dispositivo'),
            onTap: () async {
              try {
                await bleController.reconnect();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Falha ao reconectar: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: const Text('Voltar ao scanner'),
            onTap: () async {
              await bleController.disconnect();
              if (context.mounted) context.go('/scanner');
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}