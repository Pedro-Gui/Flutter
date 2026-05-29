import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportService {
  static Future<void> _shareFile(
    String fileName,
    List<int> bytes,
    String mimeType,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');

    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(
        text: 'Aqui estão os dados!',
        files: [XFile(file.path, mimeType: mimeType)],
      ),
    );
  }

  static Future<void> exportToTxt(Map<String, List<FlSpot>> dataMap) async {
    final yk = dataMap['yk'] ?? [];
    final yc = dataMap['yc'] ?? [];
    final yf = dataMap['yf'] ?? [];
    final ya = dataMap['ya'] ?? [];

    final sb = StringBuffer();
    sb.writeln('Tempo(T); yk; yc; yf; ya');

    for (int i = 0; i < yk.length; i++) {
      final t = yk[i].x.toStringAsFixed(3);
      final valYk = yk[i].y.toStringAsFixed(4);
      final valYc = i < yc.length ? yc[i].y.toStringAsFixed(4) : '0.0000';
      final valYf = i < yf.length ? yf[i].y.toStringAsFixed(4) : '0.0000';
      final valYa = i < ya.length ? ya[i].y.toStringAsFixed(4) : '0.0000';

      sb.writeln('$t; $valYk; $valYc; $valYf; $valYa');
    }

    await _shareFile(
      'telemetria_dados.txt',
      utf8.encode(sb.toString()),
      'text/plain',
    );
  }

  static Future<void> exportToXml(Map<String, List<FlSpot>> dataMap) async {
    final yk = dataMap['yk'] ?? [];
    final yc = dataMap['yc'] ?? [];
    final yf = dataMap['yf'] ?? [];
    final ya = dataMap['ya'] ?? [];

    final sb = StringBuffer();
    sb.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sb.writeln('<TelemetryData>');

    for (int i = 0; i < yk.length; i++) {
      final t = yk[i].x.toStringAsFixed(3);
      final valYk = yk[i].y.toStringAsFixed(4);
      final valYc = i < yc.length ? yc[i].y.toStringAsFixed(4) : '0.0000';
      final valYf = i < yf.length ? yf[i].y.toStringAsFixed(4) : '0.0000';
      final valYa = i < ya.length ? ya[i].y.toStringAsFixed(4) : '0.0000';

      sb.writeln(
        '  <Sample t="$t" yk="$valYk" yc="$valYc" yf="$valYf" ya="$valYa" />',
      );
    }

    sb.writeln('</TelemetryData>');
    
    await _shareFile(
      'telemetria_dados.xml', 
      utf8.encode(sb.toString()), 
      'text/xml',
    );
  }

  static Future<void> exportToPdf(Uint8List? imageBytes) async {
    final pdf = pw.Document();

    pw.MemoryImage? chartImage;
    if (imageBytes != null) {
      chartImage = pw.MemoryImage(imageBytes);
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            
            if (chartImage != null) ...[
              pw.Image(chartImage),
              pw.SizedBox(height: 20),
            ],
          ];
        },
      ),
    );
    final bytes = await pdf.save();
    await _shareFile('dados.pdf', bytes, 'application/pdf');
  }

  static Future<void> exportToPng(Uint8List? imageBytes) async {
    if (imageBytes == null) throw Exception('Falha ao capturar imagem do gráfico');

    await _shareFile(
      'grafico.png', 
      imageBytes, 
      'image/png'
    );
  }

  static Future<void> exportToMatlab(Map<String, List<FlSpot>> dataMap) async {
    final yk = dataMap['yk'] ?? [];
    final yc = dataMap['yc'] ?? [];
    final yf = dataMap['yf'] ?? [];
    final ya = dataMap['ya'] ?? [];
    final dateStr = DateTime.now().toIso8601String();

    final sb = StringBuffer();
    sb.writeln('% CompDin Telemetry Sample');
    sb.writeln('% Timestamp: $dateStr');
    sb.writeln('% Columns: [ Time(T) | yk | yc | yf | ya ]');
    sb.writeln('Z = [');

    for (int i = 0; i < yk.length; i++) {
      final t = yk[i].x.toStringAsFixed(6);
      final valYk = yk[i].y.toStringAsFixed(6);
      final valYc = i < yc.length ? yc[i].y.toStringAsFixed(6) : '0.000000';
      final valYf = i < yf.length ? yf[i].y.toStringAsFixed(6) : '0.000000';
      final valYa = i < ya.length ? ya[i].y.toStringAsFixed(6) : '0.000000';

      sb.writeln('  $t $valYk $valYc $valYf $valYa;');
    }
    sb.writeln('];');

    await _shareFile(
      'telemetria_dados.m',
      utf8.encode(sb.toString()),
      'text/plain',
    );
  }
}