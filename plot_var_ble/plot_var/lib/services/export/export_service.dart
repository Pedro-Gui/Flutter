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
        text: 'Aqui estão os dados da Senoide BLE!',
        files: [XFile(file.path, mimeType: mimeType)],
      ),
    );
  }

  static Future<void> exportToTxt(List<FlSpot> points) async {
    final sb = StringBuffer();
    sb.writeln('Tempo(x); Valor(y)');
    for (var p in points) {
      sb.writeln('${p.x.toStringAsFixed(2)}; ${p.y.toStringAsFixed(4)}');
    }
    await _shareFile(
      'senoide_dados.txt',
      sb.toString().codeUnits,
      'text/plain',
    );
  }

  static Future<void> exportToXml(List<FlSpot> points) async {
    final sb = StringBuffer();
    sb.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sb.writeln('<SensorData>');
    for (var p in points) {
      sb.writeln(
        '  <Point x="${p.x.toStringAsFixed(2)}" y="${p.y.toStringAsFixed(4)}" />',
      );
    }
    sb.writeln('</SensorData>');
    await _shareFile('senoide_dados.xml', sb.toString().codeUnits, 'text/xml');
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
            pw.Text(
              'Senoide (BLE)',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            
            if (chartImage != null) ...[
              pw.Image(chartImage),
              pw.SizedBox(height: 20),
            ],
          ];
        },
      ),
    );
    final bytes = await pdf.save();
    await _shareFile('senoide_dados.pdf', bytes, 'application/pdf');
  }

  static Future<void> exportToPng(Uint8List? imageBytes) async {
    if (imageBytes == null) throw Exception('Falha ao capturar imagem do gráfico');

    await _shareFile(
      'senoide_grafico.png', 
      imageBytes, 
      'image/png'
    );
  }

  static Future<void> exportToMatlab(List<FlSpot> points) async {
    final dateStr = DateTime.now().toString();

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('%Nova Amostragem');
    buffer.writeln('%$dateStr');
    buffer.writeln('Z=[');
    for (var p in points) {
      buffer.writeln('${p.x.toStringAsFixed(6)} ${p.y.toStringAsFixed(6)}');
    }

    buffer.writeln('];');
    await _shareFile(
      'senoide_dados.m',
      utf8.encode(buffer.toString()),
      'text/plain',
    );
  }
}
