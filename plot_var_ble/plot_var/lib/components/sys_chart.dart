import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SysChart extends StatefulWidget {
  final Map<String, List<FlSpot>> graphPoints;
  const SysChart({super.key, required this.graphPoints});

  @override
  State<SysChart> createState() => _SysChartState();
}

class _SysChartState extends State<SysChart> {
  Map<String, bool> showLines = {
    'yk': true,
    'yc': false,
    'yf': false,
    'ya': true,
  };

  List<LineChartBarData> getLines(Map<String, List<FlSpot>> graphPoints) {
    final List<LineChartBarData> lines = [];
    if (showLines['yk']!) {
      lines.add(
        LineChartBarData(
          spots: graphPoints['yk'] ?? [],
          isCurved: false,
          color: Colors.blue,
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (showLines['yc']!) {
      lines.add(
        LineChartBarData(
          spots: graphPoints['yc'] ?? [],
          isCurved: false,
          color: Colors.orange,
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (showLines['yf']!) {
      lines.add(
        LineChartBarData(
          spots: graphPoints['yf'] ?? [],
          isCurved: false,
          color: Colors.green,
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    if (showLines['ya']!) {
      lines.add(
        LineChartBarData(
          spots: graphPoints['ya'] ?? [],
          isCurved: false,
          color: Colors.purple,
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    double minX = 0;
    double maxX = 0;
    double xInterval = 100;

    if (widget.graphPoints['yk'] != null &&
        widget.graphPoints['yk']!.isNotEmpty) {
      minX = widget.graphPoints['yk']!.first.x;
      maxX = widget.graphPoints['yk']!.last.x;

      final double diff = maxX - minX;
      xInterval = diff > 0 ? diff / 6 : 100;
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Center(
            child: Text(
              'Tendência de sinais ',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ),
        Expanded(
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
                    'Tempo (ms)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  axisNameSize: 22,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: xInterval,
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
                // EIXO Y
                leftTitles: AxisTitles(
                  axisNameWidget: const Text(
                    'Amplitude (°C)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
              lineBarsData: getLines(widget.graphPoints),
            ),
            duration: Duration.zero,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Text('Sinal compensado filtrado YF:'),
                    Checkbox(
                      value: showLines['yf'],
                      onChanged: (value) {
                        setState(() {
                          showLines['yf'] = value!;
                        });
                      },
                      activeColor: Colors.green,
                      checkColor: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    const Text('Sinal amostrado decimado YA:'),
                    Checkbox(
                      value: showLines['ya'],
                      onChanged: (value) {
                        setState(() {
                          showLines['ya'] = value!;
                        });
                      },
                      activeColor: Colors.purple,
                      checkColor: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Text('Sinal de entrada YK:'),
                     Checkbox(
                  value: showLines['yk'],
                  onChanged: (value) {
                    setState(() {
                      showLines['yk'] = value!;
                    });
                  },
                  activeColor: Colors.blue,
                  checkColor: Colors.blue,
                ),
                  ],
                ),
               
                const SizedBox(height: 15),

                Row(
                  children: [
                    const Text('Sinal compensado YC:'),
                    Checkbox(
                  value: showLines['yc'],
                  onChanged: (value) {
                    setState(() {
                      showLines['yc'] = value!;
                    });
                  },
                  activeColor: Colors.orange,
                  checkColor: Colors.orange,
                ),
                  ],
                ),
                
              ],
            ),
          ],
        ),
      ],
    );
  }
}
