# Habit Tracker

A modern Flutter app to help you build and maintain daily habits.  
Track your progress, visualize your activity, and stay motivated with reminders and insights.

---

## Features

- **Habit Management:**  
  - Add, edit, and delete habits.
  - Mark habits as completed for today.
  - View streaks and best streaks for each habit.

- **Statistics & Insights:**  
  - Weekly bar chart showing habit completions per day.
  - Cards for weekly completions and longest streak.
  - Insight into your most productive day.

- **Reminders & Notifications:**  
  - Daily reminders for your habits (morning, afternoon, evening).
  - Android/iOS notification support.
  - Permission handling for notifications.

- **User Experience:**  
  - Dark theme UI.
  - Empty state illustration and prompt.
  - Material 3 design.

---

## Main Methods & Logic

### Habit Management

- `addHabit(String name)`  
  Adds a new habit to the list.

- `editHabit(Habit habit, String newName)`  
  Edits the name of an existing habit.

- `deleteHabit(Habit habit)`  
  Removes a habit from the list.

- `toggleHabit(String habitId)`  
  Marks a habit as completed for today or undoes completion.

### Statistics

- **Weekly Completions Calculation:**  
  Counts completions for each weekday over the last 7 days.

- **Longest Streak Calculation:**  
  Finds the maximum streak among all habits.

- **Most Productive Day:**  
  Determines which weekday had the most completions.

### Notifications

- `initNotifications()`  
  Initializes notification plugin and timezone.

- `scheduleHabitReminders(List<String> habits)`  
  Schedules up to 3 daily reminders for habits.

- `requestNotificationPermission()`  
  Requests notification permission on Android 13+.

- `testNotification()`  
  Schedules a test notification after 5 seconds.

## Screenshots

<img width="300" height="2400" alt="Screenshot_1756992812" src="https://github.com/user-attachments/assets/12932064-6dcb-45bb-8bab-c20a4e50b839" />

<img width="300" height="2400" alt="Screenshot_1756992816" src="https://github.com/user-attachments/assets/eb1b2c91-c9ae-457b-bd39-0db3ad514a92" />

<img width="300" height="2400" alt="Screenshot_1756992820" src="https://github.com/user-attachments/assets/8b070005-18fa-48ca-b2f3-14cf1c51c172" />

## Dependencies
Flutter
Provider
Hive
fl_chart
flutter_local_notifications
permission_handler

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

Made with ❤️ using Flutter.

