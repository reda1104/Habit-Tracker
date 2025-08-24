import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'package:habit_tracker/view_models/habits_view_model.dart';
import 'package:habit_tracker/views/main_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  await Hive.openBox<Habit>('habitsBox');

  await initNotifications();
  await requestNotificationPermission();

  runApp(
    ChangeNotifierProvider(
      create: (context) => HabitsViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E2E),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 0, 36, 32),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2A2A3C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A3C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.white54),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ),
      home: const MainPageWrapper(),
    );
  }
}

class MainPageWrapper extends StatefulWidget {
  const MainPageWrapper({super.key});

  @override
  State<MainPageWrapper> createState() => _MainPageWrapperState();
}

class _MainPageWrapperState extends State<MainPageWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final habitsBox = Hive.box<Habit>('habitsBox');
        final habitNames = habitsBox.values.map((h) => h.name).toList();

        // Schedule notifications safely
        for (var habit in habitNames) {
          try {
            await scheduleHabitReminders([habit]);
          } catch (e) {
            debugPrint("Could not schedule notification for '$habit': $e");
          }
        }
      } catch (e) {
        debugPrint("Could not schedule notifications: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MainPage();
  }
}

Future<void> requestNotificationPermission() async {
  // On Android 13+ ask runtime permission
  if (await Permission.notification.isDenied) {
    final status = await Permission.notification.request();
    debugPrint('Notification permission status: $status');
  } else {
    debugPrint('Notification permission already granted ✅');
  }
}
