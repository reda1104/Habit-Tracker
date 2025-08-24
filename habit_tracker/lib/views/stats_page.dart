import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/view_models/habits_view_model.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HabitsViewModel>();
    final today = DateTime.now();

    // Count completions per weekday (Mon=1 … Sun=7)
    final Map<int, int> completionsPerDay = {for (var i = 1; i <= 7; i++) i: 0};
    for (var habit in vm.habits) {
      for (var d in habit.completionDates) {
        if (d.isAfter(today.subtract(const Duration(days: 6)))) {
          completionsPerDay[d.weekday] =
              (completionsPerDay[d.weekday] ?? 0) + 1;
        }
      }
    }

    final weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final totalThisWeek = completionsPerDay.values.fold<int>(
      0,
      (a, b) => a + b,
    );

    // Compute nice integer Y range
    final maxCount = completionsPerDay.values.fold<int>(
      0,
      (m, v) => v > m ? v : m,
    );
    // round up to a multiple of 5 for cleaner axis (min 5)
    final intNiceMax = (maxCount <= 5) ? 5 : ((maxCount + 4) ~/ 5) * 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Stats"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "✅ $totalThisWeek habits completed this week!",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              "🔥 Current streak: ${vm.habits.fold<int>(0, (max, h) => h.currentStreak > max ? h.currentStreak : max)} days",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // 📊 Weekly bar chart (integers only on Y axis)
            Expanded(
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: intNiceMax.toDouble(),
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1, // grid every 1
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1, // tick every 1
                        getTitlesWidget: (value, meta) {
                          // show only whole numbers
                          if (value % 1 != 0) return const SizedBox.shrink();
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt() - 1;
                          if (i >= 0 && i < weekdays.length) {
                            return Text(weekdays[i]);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: List.generate(7, (i) {
                    final dayIndex = i + 1; // 1..7
                    return BarChartGroupData(
                      x: dayIndex,
                      barRods: [
                        BarChartRodData(
                          toY: completionsPerDay[dayIndex]!.toDouble(),
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
