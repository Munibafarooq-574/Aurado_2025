import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/task.dart';
import '../models/chart_data.dart'; // Adjust path if needed

class ProgressChart extends StatelessWidget {
  final List<Task>? tasks; // Allow null to handle edge cases

  const ProgressChart({this.tasks, super.key});

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks?.where((task) => task.isCompleted).length ?? 0;
    final totalTasks = tasks?.length ?? 0;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 150,
        height: 150,
        child: SfCircularChart(
          title: ChartTitle(text: "${completionRate.toStringAsFixed(1)}% Done"),
          series: <CircularSeries>[
            PieSeries<ChartData, String>(
              dataSource: [
                ChartData('Completed', completedTasks.toDouble()),
                ChartData('Pending', (totalTasks - completedTasks).toDouble()),
              ],
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              pointColorMapper: (ChartData data, _) =>
              data.x == 'Completed' ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}