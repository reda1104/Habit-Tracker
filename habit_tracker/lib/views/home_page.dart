import 'package:flutter/material.dart';
import 'package:habit_tracker/helpers/utils.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/view_models/habits_view_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HabitsViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C28),
      appBar: AppBar(
        title: const Text("Habit Tracker"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: vm.habits.isEmpty
          ? const Center(
              child: Text(
                "No habits yet.\nTap + to add one!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.habits.length,
              itemBuilder: (context, index) {
                final habit = vm.habits[index];
                final isDoneToday = habit.completionDates.any(
                  (d) =>
                      d.year == DateTime.now().year &&
                      d.month == DateTime.now().month &&
                      d.day == DateTime.now().day,
                );

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: const Color(0xFF2A2A3C),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(
                        IconData(habit.iconCode, fontFamily: 'MaterialIcons'),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      habit.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "🔥 ${habit.currentStreak}  |  🏆 ${habit.bestStreak}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isDoneToday
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isDoneToday ? Colors.green : Colors.grey,
                          ),
                          onPressed: () {
                            context.read<HabitsViewModel>().toggleHabit(
                              habit.id,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            ShowHabitEditDialog(context, habit);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            context.read<HabitsViewModel>().deleteHabit(habit);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Habit"),
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<dynamic> ShowHabitEditDialog(BuildContext context, Habit habit) {
    final controller = TextEditingController(text: habit.name);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A3C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Edit Habit"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter habit name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<HabitsViewModel>().editHabit(
                    habit,
                    controller.text,
                  );
                  Navigator.pop(context);
                } else {
                  ShowErrorDialog(context, "Habit name cannot be empty!");
                }
              },
              child: const Text("Save"),
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
        backgroundColor: const Color(0xFF2A2A3C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("New Habit"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter habit name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<HabitsViewModel>().addHabit(controller.text);
                Navigator.pop(context);
              } else {
                ShowErrorDialog(context, "Habit name cannot be empty!");
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
