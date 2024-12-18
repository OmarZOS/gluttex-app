import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SerologyScreen extends StatefulWidget {
  const SerologyScreen({super.key});
  @override
  _SerologyScreenState createState() => _SerologyScreenState();
}

class _SerologyScreenState extends State<SerologyScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Blood Tests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          _buildLineChart('TTG-IgA', [10, 12, 14, 13, 15], Colors.blue),
          const SizedBox(height: 16.0),
          _buildLineChart('DGP-IgA and DGP-IgG', [20, 22, 21, 23, 24],
              Colors.green, [15, 18, 17, 19, 21], Colors.orange),
          const SizedBox(height: 16.0),
          _buildLineChart('EMA-IgA', [30, 32, 31, 33, 34], Colors.red),
          const SizedBox(height: 16.0),
          _buildLineChart(
              'Total Serum IgA', [40, 42, 41, 43, 44], Colors.purple),
        ],
      ),
    );
  }

  Widget _buildLineChart(String title, List<double> values, Color color,
      [List<double>? secondaryValues, Color? secondaryColor]) {
    List<FlSpot> spots = values
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    List<FlSpot>? secondarySpots;
    if (secondaryValues != null) {
      secondarySpots = secondaryValues
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 200,
          // child: LineChart(
          // LineChartData(
          //   titlesData: FlTitlesData(
          //     rightTitles: SideTitles(
          //       showTitles: true,
          //       interval: 1,
          //       getTitles: (value) {
          //         return 'Day ${value.toInt()}';
          //       },
          //     ),
          //     leftTitles: SideTitles(
          //       showTitles: true,
          //       interval: 5,
          //       getTitles: (value) {
          //         return value.toString();
          //       },
          //     ),
          //   ),
          //   gridData: FlGridData(show: true),
          //   borderData: FlBorderData(show: true),
          //   lineBarsData: [
          //     LineChartBarData(
          //       spots: spots,
          //       isCurved: true,
          //       barWidth: 4,
          //       // colors: [color],
          //       belowBarData: BarAreaData(show: false),
          //     ),
          //     if (secondarySpots != null)
          //       LineChartBarData(
          //         spots: secondarySpots,
          //         isCurved: true,
          //         barWidth: 4,
          //         // colors: [secondaryColor!],
          //         belowBarData: BarAreaData(show: false),
          //       ),
          //   ],
          // ),
          // ),
        ),
      ],
    );
  }
}
