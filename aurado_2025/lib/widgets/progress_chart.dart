import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_data.dart';
import '../models/task.dart';

class ProgressChart extends StatelessWidget {
  final List<TaskModel>? tasks;

  const ProgressChart({this.tasks, super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int todayCount = 0;
    int upcomingCount = 0;
    int completedCount = 0;
    int missedCount = 0;

    if (tasks != null) {
      for (var task in tasks!) {
        final taskDate = DateTime(task.dueDateTime.year, task.dueDateTime.month, task.dueDateTime.day);

        if (task.isCompleted) {
          completedCount++;
        } else if (task.dueDateTime.isBefore(now)) {
          missedCount++;
        } else if (taskDate == today) {
          todayCount++;
        } else if (taskDate.isAfter(today)) {
          upcomingCount++;
        }
      }
    }

    final totalTasks = todayCount + upcomingCount + completedCount + missedCount;
    print('ProgressChart: Rendering at $now - Today: $todayCount, Upcoming: $upcomingCount, Completed: $completedCount, Missed: $missedCount, Total: $totalTasks');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Task Status Distribution',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12.0),
          totalTasks == 0
              ? Container(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pie_chart_outline,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'No tasks available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
              : SizedBox(
            width: 300,
            height: 300,
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.wrap,
                position: LegendPosition.bottom,
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              series: <CircularSeries>[
                PieSeries<ChartData, String>(
                  dataSource: [
                    ChartData('Today', todayCount.toDouble()),
                    ChartData('Upcoming', upcomingCount.toDouble()),
                    ChartData('Completed', completedCount.toDouble()),
                    ChartData('Missed', missedCount.toDouble()),
                  ],
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  dataLabelMapper: (ChartData data, _) => data.y > 0 ? data.y.toString() : '', // Hide label if value is 0
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.inside,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  pointColorMapper: (ChartData data, _) {
                    switch (data.x) {
                      case 'Today':
                        return Color(0xFF42A5F5); // Vibrant Blue
                      case 'Upcoming':
                        return Color(0xFFAB47BC); // Vibrant Purple
                      case 'Completed':
                        return Color(0xFF66BB6A); // Vibrant Green
                      case 'Missed':
                        return Color(0xFFEF5350); // Vibrant Red
                      default:
                        return Colors.grey;
                    }
                  },
                  radius: '90%',
                  explode: true,
                  explodeAll: true,
                  explodeOffset: '5%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14.0),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16.0,
            runSpacing: 8.0,
            children: [
              _buildCountChip('Today', todayCount, Color(0xFF42A5F5)),
              _buildCountChip('Upcoming', upcomingCount, Color(0xFFAB47BC)),
              _buildCountChip('Completed', completedCount, Color(0xFF66BB6A)),
              _buildCountChip('Missed', missedCount, Color(0xFFEF5350)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: $count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}