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
          selectedItemColor: Color(0xFF7E6DFF),
          unselectedItemColor: Color(0xFFA5A5BA),
          type: BottomNavigationBarType.fixed,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7E6DFF),
          brightness: Brightness.dark,
          background: const Color(0xFF13131A),
          surface: const Color(0xFF232334),
          onSurface: Colors.white,
          primary: const Color(0xFF7E6DFF),
          secondary: const Color(0xFF4CD964),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A25),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF232334),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF7E6DFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF232334),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Color(0xFFA5A5BA)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(fontSize: 16, color: Color(0xFFA5A5BA)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF232334),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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
