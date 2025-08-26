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

    // Calculate longest streak
    final longestStreak = vm.habits.fold<int>(
      0,
      (max, h) => h.currentStreak > max ? h.currentStreak : max,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text("Your Stats"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    "Weekly Completions",
                    "$totalThisWeek",
                    Icons.check_circle,
                    const Color(0xFF7E6DFF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    "Longest Streak",
                    "$longestStreak days",
                    Icons.local_fire_department,
                    const Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Chart Title
            const Text(
              "Weekly Activity",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Habit completions by day",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),

            // 📊 Weekly bar chart (integers only on Y axis)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF232334),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: intNiceMax.toDouble(),
                    alignment: BarChartAlignment.spaceAround,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => const Color(0xFF7E6DFF),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            "${completionsPerDay[group.x.toInt()]!} habits\n${weekdays[group.x.toInt() - 1]}",
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: const Color(0xFF3A3A4A),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: intNiceMax > 10 ? 2 : 1,
                          getTitlesWidget: (value, meta) {
                            if (value % 1 != 0) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: const Color(0xFFA5A5BA),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt() - 1;
                            if (i >= 0 && i < weekdays.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  weekdays[i],
                                  style: TextStyle(
                                    color: const Color(0xFFA5A5BA),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
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
                      final isToday = dayIndex == DateTime.now().weekday;
                      return BarChartGroupData(
                        x: dayIndex,
                        barRods: [
                          BarChartRodData(
                            toY: completionsPerDay[dayIndex]!.toDouble(),
                            width: 22,
                            borderRadius: BorderRadius.circular(6),
                            color: isToday
                                ? const Color(0xFF7E6DFF)
                                : const Color(0xFF4CD964),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: intNiceMax.toDouble(),
                              color: const Color(0xFF3A3A4A),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Additional insights
            if (vm.habits.isNotEmpty) ...[
              const Text(
                "Insights",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildInsightCard(
                context,
                "Your most productive day was ${_getMostProductiveDay(completionsPerDay, weekdays)}",
                Icons.insights,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF232334),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF232334),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7E6DFF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMostProductiveDay(
    Map<int, int> completionsPerDay,
    List<String> weekdays,
  ) {
    int maxCompletions = 0;
    int mostProductiveDay = 1;

    completionsPerDay.forEach((day, completions) {
      if (completions > maxCompletions) {
        maxCompletions = completions;
        mostProductiveDay = day;
      }
    });

    return weekdays[mostProductiveDay - 1];
  }
}
