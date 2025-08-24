import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Reminder times (3 slots)
final reminderTimes = [
  const TimeOfDay(hour: 8, minute: 0), // 8 AM
  const TimeOfDay(hour: 14, minute: 0), // 2 PM
  const TimeOfDay(hour: 20, minute: 0), // 8 PM
];

Future<void> initNotifications() async {
  try {
    // Init timezone database
    tz.initializeTimeZones();

    // Get device timezone and set it properly
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print('Timezone set to: $timeZoneName');

    // Android + iOS init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // Initialize plugin
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Create notification channels
    await _createNotificationChannels();

    // Request Android 13+ notification permission
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  } catch (e) {
    print('Error initializing notifications: $e');
  }
}

Future<void> _createNotificationChannels() async {
  // Test channel
  const androidTestChannel = AndroidNotificationChannel(
    'test_channel',
    'Test Notifications',
    description: 'Channel for testing notifications',
    importance: Importance.max,
    playSound: true,
  );

  // Create channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(androidTestChannel);
}

/// Quick test: notification after 5 seconds
Future<void> testNotification() async {
  try {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    // Use simple DateTime conversion instead of complex timezone handling
    final scheduledTime = DateTime.now().add(const Duration(seconds: 5));
    final scheduledTz = tz.TZDateTime(
      tz.local,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
      scheduledTime.second,
    );

    print('Scheduling test for: $scheduledTz');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999,
      'Test Reminder',
      'This is just a test notification 🚀',
      scheduledTz,
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );

    print('Test notification scheduled successfully');
  } catch (e) {
    print('Error scheduling test notification: $e');
  }
}

/// Alternative: Show immediate notification for testing
Future<void> showImmediateTestNotification() async {
  try {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      1000,
      'Immediate Test',
      'This is an immediate test notification ✅',
      details,
    );
  } catch (e) {
    print('Error showing immediate notification: $e');
  }
}

/// Schedule habit reminders (3 times per day)
Future<void> scheduleHabitReminders(List<String> habits) async {
  try {
    if (habits.isEmpty) return;

    const androidDetails = AndroidNotificationDetails(
      'habit_channel',
      'Habit Reminders',
      channelDescription: 'Daily habit reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.cancelAll();

    final dayIndex = DateTime.now().weekday;
    final rotatedHabits = [
      ...habits.sublist(dayIndex % habits.length),
      ...habits.sublist(0, dayIndex % habits.length),
    ];
    final selectedHabits = rotatedHabits.take(3).toList();

    final now = DateTime.now();

    for (int i = 0; i < selectedHabits.length; i++) {
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTimes[i].hour,
        reminderTimes[i].minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        i,
        'Habit Reminder',
        'Don\'t forget: ${selectedHabits[i]}',
        scheduledTz,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  } catch (e) {
    print('Error scheduling habit reminders: $e');
  }
}

Future<void> debugNotificationStatus() async {
  try {
    final pending = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    print('=== DEBUG NOTIFICATION STATUS ===');
    print('Total pending: ${pending.length}');

    for (final notification in pending) {
      print('ID: ${notification.id}');
      print('Title: ${notification.title}');
      print('Body: ${notification.body}');
      print(
        'Scheduled time: ${notification.payload}',
      ); // Check if time is stored
      print('---');
    }

    // Check if we can show a notification right now
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      1001,
      'Debug Test',
      'This is a debug test - should work immediately',
      details,
    );

    print('Immediate debug notification shown');
  } catch (e) {
    print('Debug error: $e');
  }
}
