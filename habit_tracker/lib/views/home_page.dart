import 'package:flutter/material.dart';
import 'package:habit_tracker/helpers/utils.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'package:habit_tracker/view_models/habits_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/main.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HabitsViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text("Habit Tracker"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: vm.habits.isEmpty
          ? _buildEmptyState(context)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text(
                    "Your Habits",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
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

                      return _buildHabitCard(context, habit, isDoneToday, vm);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          "Add Habit",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF7E6DFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF232334),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 50,
              color: Color(0xFF7E6DFF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No habits yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Start building good habits by adding your first one!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFFA5A5BA)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(
    BuildContext context,
    Habit habit,
    bool isDoneToday,
    HabitsViewModel vm,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF232334),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF7E6DFF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            IconData(habit.iconCode, fontFamily: 'MaterialIcons'),
            color: const Color(0xFF7E6DFF),
            size: 26,
          ),
        ),
        title: Text(
          habit.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              _buildStreakIndicator("🔥 ${habit.currentStreak}"),
              const SizedBox(width: 12),
              _buildStreakIndicator("🏆 ${habit.bestStreak}"),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDoneToday
                    ? const Color(0xFF4CD964).withOpacity(0.2)
                    : const Color(0xFF232334),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDoneToday
                      ? const Color(0xFF4CD964)
                      : const Color(0xFF3A3A4A),
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  isDoneToday ? Icons.check : Icons.add,
                  size: 20,
                  color: isDoneToday
                      ? const Color(0xFF4CD964)
                      : const Color(0xFFA5A5BA),
                ),
                onPressed: () {
                  context.read<HabitsViewModel>().toggleHabit(habit.id);
                },
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFFA5A5BA)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: const [
                      Icon(Icons.edit, color: Color(0xFFA5A5BA), size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: const [
                      Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  ShowHabitEditDialog(context, habit);
                } else if (value == 'delete') {
                  context.read<HabitsViewModel>().deleteHabit(habit);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakIndicator(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A4A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFFA5A5BA),
        ),
      ),
    );
  }

  Future<dynamic> ShowHabitEditDialog(BuildContext context, Habit habit) {
    final controller = TextEditingController(text: habit.name);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232334),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Edit Habit"),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter habit name",
              hintStyle: const TextStyle(color: Color(0xFFA5A5BA)),
              filled: true,
              fillColor: const Color(0xFF1A1A25),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFFA5A5BA)),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E6DFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
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
        backgroundColor: const Color(0xFF232334),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("New Habit"),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter habit name",
            hintStyle: const TextStyle(color: Color(0xFFA5A5BA)),
            filled: true,
            fillColor: const Color(0xFF1A1A25),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xFFA5A5BA)),
            ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E6DFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Create", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
