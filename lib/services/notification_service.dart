import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:myapp/models/habit.dart';

/// Service for handling local notifications.
class NotificationService {
  /// Flutter Local Notifications Plugin instance.
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  /// Initializes the notification service.
  Future<void> initialize() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();

    // Initialize notification settings for Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize notification settings for iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize notification settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Handles notification tap events.
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap based on the payload
    // TODO: Replace with proper logging framework
    // For now, using debugPrint which is acceptable in development
    debugPrint('Notification tapped: ${response.payload}');
    
    // You can add custom handling here, such as navigating to a specific screen
    // based on the notification payload
  }

  /// Requests notification permissions.
  Future<bool> requestPermissions() async {
    // Request permissions for iOS
    final ios = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Request permissions for Android (Android 13+)
    final android = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return ios ?? android ?? false;
  }

  /// Schedules a notification for a habit reminder.
  Future<void> scheduleHabitReminder(Habit habit) async {
    if (!habit.notificationsEnabled || habit.reminderTime == null) {
      return;
    }

    // Create notification details for Android
    final androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Notifications for habit reminders',
      importance: Importance.high,
      priority: Priority.high,
      color: habit.color,
    );

    // Create notification details for iOS
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Create notification details
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Calculate the next occurrence of the habit
    final scheduledDate = _getNextOccurrence(habit);
    if (scheduledDate == null) {
      return;
    }

    // Schedule the notification
    await _notifications.zonedSchedule(
      habit.id.hashCode, // Use the habit ID as the notification ID
      'Habit Reminder: ${habit.title}',
      habit.description ?? 'Time to complete your habit!',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _getDateTimeComponents(habit),
      payload: habit.id, // Use the habit ID as the payload
    );
  }

  /// Cancels a scheduled notification for a habit.
  Future<void> cancelHabitReminder(Habit habit) async {
    await _notifications.cancel(habit.id.hashCode);
  }

  /// Gets the next occurrence of a habit based on its frequency.
  tz.TZDateTime? _getNextOccurrence(Habit habit) {
    if (habit.reminderTime == null) {
      return null;
    }

    final now = tz.TZDateTime.now(tz.local);

    // Create a TZDateTime for the reminder time today
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      habit.reminderTime!.hour,
      habit.reminderTime!.minute,
    );

    // If the reminder time has already passed today, schedule for the next occurrence
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Adjust the date based on the habit frequency
    switch (habit.frequency) {
      case HabitFrequency.daily:
        // No adjustment needed for daily habits
        return scheduledDate;

      case HabitFrequency.weekly:
        // Find the next day of the week that matches the habit's schedule
        if (habit.daysOfWeek == null || habit.daysOfWeek!.isEmpty) {
          return null;
        }

        // Sort the days of the week
        final sortedDays = List<int>.from(habit.daysOfWeek!)..sort();

        // Find the next day of the week
        int daysToAdd = 0;
        bool found = false;

        for (int i = 0; i < 7; i++) {
          final checkDay = (now.weekday + i) % 7;
          if (sortedDays.contains(checkDay == 0 ? 7 : checkDay)) {
            daysToAdd = i;
            found = true;
            break;
          }
        }

        if (!found) {
          return null;
        }

        return scheduledDate.add(Duration(days: daysToAdd));

      case HabitFrequency.monthly:
        // Schedule for the same day of the month
        final targetDay = habit.createdAt.day;
        
        // If today is after the target day, schedule for next month
        if (now.day > targetDay) {
          // Move to the next month
          scheduledDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month + 1,
            targetDay,
            habit.reminderTime!.hour,
            habit.reminderTime!.minute,
          );
        } else if (now.day < targetDay) {
          // Schedule for later this month
          scheduledDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            targetDay,
            habit.reminderTime!.hour,
            habit.reminderTime!.minute,
          );
        }
        
        return scheduledDate;

      case HabitFrequency.specificDaysOfYear:
        // Find the next specific date in the year
        if (habit.specificYearDates == null || habit.specificYearDates!.isEmpty) {
          return null;
        }

        // Convert specific dates to TZDateTime for this year
        final currentYear = now.year;
        final specificDates = habit.specificYearDates!
            .map((date) => tz.TZDateTime(
                  tz.local,
                  currentYear,
                  date.month,
                  date.day,
                  habit.reminderTime!.hour,
                  habit.reminderTime!.minute,
                ))
            .where((date) => date.isAfter(now))
            .toList()
          ..sort();

        if (specificDates.isNotEmpty) {
          return specificDates.first;
        }

        // If no dates this year, try next year
        final nextYearDates = habit.specificYearDates!
            .map((date) => tz.TZDateTime(
                  tz.local,
                  currentYear + 1,
                  date.month,
                  date.day,
                  habit.reminderTime!.hour,
                  habit.reminderTime!.minute,
                ))
            .toList()
          ..sort();

        return nextYearDates.isNotEmpty ? nextYearDates.first : null;

      case HabitFrequency.someTimesPerPeriod:
        // For "some times per period", treat like daily for notifications
        return scheduledDate;
        
      case HabitFrequency.repeat:
        // For "repeat", treat like daily for notifications
        return scheduledDate;
        
      case HabitFrequency.custom:
        // Custom frequency would need custom logic
        return scheduledDate;
    }
  }

  /// Gets the date time components to match for recurring notifications.
  DateTimeComponents? _getDateTimeComponents(Habit habit) {
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return DateTimeComponents.time;
      case HabitFrequency.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case HabitFrequency.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case HabitFrequency.specificDaysOfYear:
        return DateTimeComponents.dateAndTime;
      case HabitFrequency.someTimesPerPeriod:
        return DateTimeComponents.time;
      case HabitFrequency.repeat:
        return DateTimeComponents.time;
      case HabitFrequency.custom:
        return DateTimeComponents.time;
    }
  }

  /// Shows a test notification.
  Future<void> showTestNotification() async {
    // Create notification details for Android
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      channelDescription: 'Channel for test notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    // Create notification details for iOS
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Create notification details
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show the notification
    await _notifications.show(
      0,
      'Test Notification',
      'This is a test notification from HabitAI',
      details,
    );
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
