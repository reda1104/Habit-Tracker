import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/view_models/habits_view_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HabitsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Habit Tracker")),
      body: ListView.builder(
        itemCount: vm.habits.length,
        itemBuilder: (context, index) {
          final habit = vm.habits[index];
          return ListTile(
            leading: CircleAvatar(
              child: Icon(
                IconData(habit.iconCode, fontFamily: 'MaterialIcons'),
              ),
            ),
            title: Text(habit.name),
            subtitle: Text(
              "Current streak : ${habit.currentStreak} 🔥 | Longest streak : ${habit.bestStreak} 🏆",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    habit.completionDates.any(
                          (d) =>
                              d.year == DateTime.now().year &&
                              d.month == DateTime.now().month &&
                              d.day == DateTime.now().day,
                        )
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                  onPressed: () {
                    context.read<HabitsViewModel>().toggleHabit(habit.id);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    ShowHabitEditDialog(context, habit);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    context.read<HabitsViewModel>().deleteHabit(habit);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddHabitDialog(context);
        },
      ),
    );
  }

  Future<dynamic> ShowHabitEditDialog(BuildContext context, Habit habit) {
    final controller = TextEditingController(text: habit.name);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Habit"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<HabitsViewModel>().editHabit(
                    habit,
                    controller.text,
                  );
                  Navigator.pop(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Error"),
                        content: const Text("Habit name cannot be empty!"),
                        actions: [
                          TextButton(
                            child: const Text("OK"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Habit"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<HabitsViewModel>().addHabit(controller.text);
                Navigator.pop(context);
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Error"),
                      content: const Text("Habit name cannot be empty!"),
                      actions: [
                        TextButton(
                          child: const Text("OK"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
