import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  List<DateTime> completionDates = [];

  @HiveField(4)
  int iconCode;

  Habit({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.iconCode,
    List<DateTime>? completionDates,
  }) : completionDates = completionDates ?? [];
}

extension HabitStats on Habit {
  int get currentStreak {
    if (completionDates.isEmpty) return 0;

    completionDates.sort((a, b) => b.compareTo(a)); // latest first
    int streak = 0;
    DateTime today = DateTime.now();
    DateTime day = DateTime(today.year, today.month, today.day);

    for (final date in completionDates..sort((a, b) => b.compareTo(a))) {
      if (date.isAtSameMomentAs(day)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else if (date.isAtSameMomentAs(day.subtract(const Duration(days: 1)))) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int get bestStreak {
    if (completionDates.isEmpty) return 0;

    final sorted = completionDates.toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    int maxStreak = 1;
    int streak = 1;

    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
        streak++;
        if (streak > maxStreak) maxStreak = streak;
      } else {
        streak = 1;
      }
    }

    return maxStreak;
  }
}
