import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import 'package:hive/hive.dart';

class HabitsViewModel extends ChangeNotifier {
  late Box<Habit> _habitsBox;
  List<Habit> get habits => _habitsBox.values.toList();

  HabitsViewModel() {
    _habitsBox = Hive.box<Habit>('habitsBox');
  }

  void addHabit(String name) {
    final habit = Habit(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      iconCode: Icons.calendar_today.codePoint,
    );
    _habitsBox.put(habit.id, habit);

    notifyListeners();
  }

  void toggleHabit(String id) {
    final habit = _habitsBox.get(id);
    if (habit != null) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      if (habit.completionDates.any(
        (d) =>
            d.year == todayDate.year &&
            d.month == todayDate.month &&
            d.day == todayDate.day,
      )) {
        // already marked today → remove it
        habit.completionDates.removeWhere(
          (d) =>
              d.year == todayDate.year &&
              d.month == todayDate.month &&
              d.day == todayDate.day,
        );
      } else {
        // mark as done
        habit.completionDates.add(todayDate);
      }
      habit.save();
      notifyListeners();
    }
  }

  void deleteHabit(Habit habit) {
    habit.delete();
    notifyListeners();
  }

  void editHabit(Habit habit, String newName) {
    habit.name = newName;
    habit.save();
    notifyListeners();
  }
}
