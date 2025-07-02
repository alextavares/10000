import 'dart:convert'; // Para codificar/decodificar o payload
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/utils/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
// import 'package:myapp/main.dart'; // Evitar import de main.dart em services
// import 'package:myapp/services/service_provider.dart'; // Evitar dependência direta se possível em callbacks de background

// É importante que este callback seja uma função de nível superior ou estática.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // O ideal é que este handler seja leve.
  // Para ações complexas, considere usar um plugin de processamento em background.
  Logger.info(
      'Notification Tapped (Background Handler): Payload: ${notificationResponse.payload}, ActionID: ${notificationResponse.actionId}');

  if (notificationResponse.actionId == NotificationService.snoozeActionId &&
      notificationResponse.payload != null) {

    // Recriar e inicializar uma instância SÍNCRONA para reagendar.
    // Esta é uma simplificação e pode ter limitações em cenários de background complexos.
    final FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    // Não podemos usar await aqui, pois é um callback síncrono de background.
    // Usamos .then() para continuar a lógica após a inicialização.
    localNotificationsPlugin.initialize(initializationSettings).then((_) async {
      try {
        final payloadData = json.decode(notificationResponse.payload!);
        final String? habitId = payloadData['habitId'];
        final String? title = payloadData['title'];
        final String? body = payloadData['body'];
        final int? colorValue = payloadData['color'];
        // final String? originalReminderTimeStr = payloadData['originalReminderTime'];

        if (habitId == null || title == null || body == null || colorValue == null) {
                  Logger.warning("BackgroundSnooze: Incomplete payload.");
          return;
        }

        // Cancelar a notificação original que disparou o snooze
        // O ID da notificação original é habit.id.hashCode
        // Precisamos converter o habitId (String) para o hashCode int.
        // Se o payloadData tiver o 'idHash' seria mais direto.
        // Assumindo que o `habitId` do payload é o `habit.id` string.
        await localNotificationsPlugin.cancel(habitId.hashCode);
                Logger.info("BackgroundSnooze: Cancelled original notification $habitId");


        final tz.TZDateTime snoozedTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 10));

        final androidDetailsSnooze = AndroidNotificationDetails(
          NotificationService.habitChannelIdSnooze, // Canal diferente para snoozed
          'Lembretes Adiados',
          channelDescription: 'Canal para lembretes de hábitos adiados.',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(colorValue ?? 0xFFFFFFFF),
          icon: '@mipmap/ic_launcher',
        );
        const iosDetailsSnooze = DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);
        final detailsSnooze = NotificationDetails(
            android: androidDetailsSnooze, iOS: iosDetailsSnooze);

        // Usar um ID único para a notificação adiada para não colidir com o original recorrente
        final snoozedNotificationId = ("${habitId}_snooze_${DateTime.now().millisecondsSinceEpoch}").hashCode;

        await localNotificationsPlugin.zonedSchedule(
            snoozedNotificationId,
            "Adiado: $title",
            body,
            snoozedTime,
            detailsSnooze,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

            payload: notificationResponse.payload // Reutilizar payload original
            );
        Logger.info("BackgroundSnooze: Notification for $habitId snoozed to $snoozedTime (ID: $snoozedNotificationId)");
      } catch (e, s) {
        Logger.error("Error in background snooze handler: $e", e, s);
      }
    });
  }
}


/// Service for handling local notifications.
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static const String habitChannelId = 'habit_reminders_channel_id';
  static const String habitChannelName = 'Lembretes de Hábitos';
  static const String habitChannelDescription = 'Canal para lembretes de hábitos.';
  static const String habitChannelIdSnooze = 'habit_snooze_channel_id';


  // Action IDs
  static const String snoozeActionId = 'SNOOZE_10M_ACTION';
  // static const String completeActionId = 'COMPLETE_HABIT_ACTION'; // Para o futuro

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    final List<DarwinNotificationCategory> darwinNotificationCategories = [
      DarwinNotificationCategory(
        'HABIT_REMINDER_CATEGORY', // Identificador da categoria
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(snoozeActionId, 'Adiar (10 min)'),
          // DarwinNotificationAction.plain(completeActionId, 'Concluído'),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.customDismissAction,
        },
      )
    ];

    final androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: darwinNotificationCategories,
    );
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    Logger.info("NotificationService initialized with actions.");
  }

  Future<void> _onNotificationResponse(NotificationResponse response) async {
    Logger.info(
        'Notification response received. Payload: ${response.payload}, ActionID: ${response.actionId}, Input: ${response.input}');

    if (response.payload == null || response.payload!.isEmpty) {
      Logger.warning('Notification response with empty payload.');
      return;
    }

    try {
      final payloadData = json.decode(response.payload!);
      final String? habitId = payloadData['habitId'];

      if (habitId == null) {
        Logger.warning('Habit ID not found in payload.');
        return;
      }

      if (response.actionId == snoozeActionId) {
        Logger.info("Snooze action tapped for habit $habitId");
        await _handleSnoozeAction(payloadData);
      } else {
        Logger.info("Notification tapped (not an action) for habit $habitId. Consider navigation.");
        // Ex: GlobalNavigator.navigateToHabitDetails(habitId); // Implementar com um service de navegação global
      }
    } catch (e, s) {
      Logger.error("Error processing notification response: $e", e, s);
    }
  }

  Future<void> _handleSnoozeAction(Map<String, dynamic> payloadData) async {
    final String? habitId = payloadData['habitId'];
    final String? title = payloadData['title'];
    final String? body = payloadData['body']; // Este é o 'description' do hábito ou mensagem padrão
    final int? colorValue = payloadData['color'];
    // originalReminderTime não é estritamente necessário para a lógica de snooze simples,
    // mas pode ser útil para lógicas mais complexas ou para reconstruir o hábito.

    if (habitId == null || title == null || body == null || colorValue == null) {
      Logger.warning("Snooze action called with incomplete payload: $payloadData");
      return;
    }

    // Cancelar a notificação original que foi tocada.
    // A notificação original tem o ID habit.id.hashCode.
    // As notificações de snooze terão IDs diferentes.
    await _notifications.cancel(habitId.hashCode);
    Logger.info("Snooze: Cancelled original notification for $habitId (ID: ${habitId.hashCode})");


    final tz.TZDateTime snoozedTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 10));

    final androidDetailsSnooze = AndroidNotificationDetails(
      habitChannelIdSnooze,
      'Lembretes Adiados',
      channelDescription: 'Canal para lembretes de hábitos adiados.',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(colorValue),
      icon: '@mipmap/ic_launcher',
       actions: <AndroidNotificationAction>[ // Manter a ação de adiar na notificação adiada
        const AndroidNotificationAction(snoozeActionId, 'Adiar (10 min)'),
      ],
    );
    const iosDetailsSnooze = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'HABIT_REMINDER_CATEGORY', // Para ter a ação de snooze no iOS também
    );
    final detailsSnooze = NotificationDetails(android: androidDetailsSnooze, iOS: iosDetailsSnooze);

    final snoozedNotificationId = ("${habitId}_snooze_${DateTime.now().millisecondsSinceEpoch}").hashCode;

    try {
      await _notifications.zonedSchedule(
        snoozedNotificationId,
        "Adiado: $title",
        body,
        snoozedTime,
        detailsSnooze,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        payload: json.encode(payloadData), // Reutiliza o payload original
      );
      Logger.info("Notification for habit '$habitId' snoozed to $snoozedTime (New ID: $snoozedNotificationId)");
    } catch (e, s) {
      Logger.error("Error scheduling snoozed notification for habit $habitId: $e", e, s);
    }
  }


  Future<bool> requestPermissions() async {
    bool? androidPermissionGranted;
    bool? iosPermissionGranted;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      iosPermissionGranted = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      androidPermissionGranted = true; // Permissions are handled during initialization
    }
    Logger.info("iOS Permissions: $iosPermissionGranted, Android Permissions: $androidPermissionGranted");
    return iosPermissionGranted ?? androidPermissionGranted ?? false;
  }

  Future<void> scheduleHabitReminder(Habit habit) async {
    if (!habit.notificationsEnabled || habit.reminderTime == null) {
      Logger.info("Notifications disabled or no reminder time for habit '${habit.title}'. Skipping schedule.");
      await cancelHabitReminder(habit);
      return;
    }

    await cancelHabitReminder(habit);

    final tz.TZDateTime? scheduledDate = _getNextOccurrence(habit);

    if (scheduledDate == null) {
      Logger.info("No next occurrence found for habit '${habit.title}'. Notification not scheduled.");
      return;
    }

    final String habitPayload = json.encode({
      'habitId': habit.id,
      'title': habit.title,
      'body': habit.description?.isNotEmpty == true ? habit.description! : 'Lembrete: ${habit.title}',
      'color': habit.color.value,
      'originalReminderTime': '${habit.reminderTime!.hour.toString().padLeft(2, '0')}:${habit.reminderTime!.minute.toString().padLeft(2, '0')}',
    });

    final androidDetails = AndroidNotificationDetails(
      habitChannelId,
      habitChannelName,
      channelDescription: habitChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      color: habit.color,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(snoozeActionId, 'Adiar (10 min)'),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'HABIT_REMINDER_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        habit.id.hashCode,
        habit.title,
        habit.description?.isNotEmpty == true ? habit.description! : 'Lembrete: ${habit.title}',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        matchDateTimeComponents: _getDateTimeComponents(habit),
        payload: habitPayload,
      );
      Logger.info("Notification scheduled for habit '${habit.title}' (ID: ${habit.id.hashCode}) at $scheduledDate with recurrence: ${_getDateTimeComponents(habit)}");
    } catch (e, s) {
        Logger.error("Error scheduling notification for habit ${habit.id}: $e", e, s);
    }
  }

  tz.TZDateTime? _getNextOccurrence(Habit habit) {
    if (habit.reminderTime == null) {
      Logger.debug("[_getNextOccurrence] Habit '${habit.title}' has no reminderTime.");
      return null;
    }

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final TimeOfDay reminder = habit.reminderTime!;

    final tz.TZDateTime habitStartDateAtReminderTime = tz.TZDateTime(
        tz.local, habit.startDate.year, habit.startDate.month, habit.startDate.day, reminder.hour, reminder.minute);

    if (habit.targetDate != null) {
      final tz.TZDateTime habitTargetDateEnd = tz.TZDateTime(
          tz.local, habit.targetDate!.year, habit.targetDate!.month, habit.targetDate!.day, 23, 59, 59);
      if (tz.TZDateTime(tz.local, now.year, now.month, now.day).isAfter(habitTargetDateEnd)) {
        Logger.debug("[_getNextOccurrence] Habit '${habit.title}' target date (${habit.targetDate}) has passed. No notification.");
        return null;
      }
    }

    tz.TZDateTime searchDateTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, reminder.hour, reminder.minute);

    if (searchDateTime.isBefore(now)) {
      searchDateTime = searchDateTime.add(const Duration(days: 1));
    }

    if (searchDateTime.isBefore(habitStartDateAtReminderTime)) {
      searchDateTime = habitStartDateAtReminderTime;
    }

    for (int i = 0; i < 730; i++) {
      tz.TZDateTime potentialDay = tz.TZDateTime(tz.local, searchDateTime.year, searchDateTime.month, searchDateTime.day).add(Duration(days: i));
      tz.TZDateTime potentialNotificationDateTime = tz.TZDateTime(
          tz.local,
          potentialDay.year,
          potentialDay.month,
          potentialDay.day,
          reminder.hour,
          reminder.minute
      );

      if (potentialNotificationDateTime.isBefore(habitStartDateAtReminderTime)) {
          continue;
      }

      if (habit.targetDate != null) {
        final tz.TZDateTime habitTargetDateForReminder = tz.TZDateTime(
            tz.local, habit.targetDate!.year, habit.targetDate!.month, habit.targetDate!.day, reminder.hour, reminder.minute);
        if (potentialNotificationDateTime.isAfter(habitTargetDateForReminder)) {
          Logger.debug("[_getNextOccurrence] Search for habit '${habit.title}' exceeded target date ($habitTargetDateForReminder). No further notifications.");
          return null;
        }
      }

      if (habit.isDueToday(potentialNotificationDateTime)) {
          if(potentialNotificationDateTime.isAfter(now)){
            Logger.debug("[_getNextOccurrence] Found next occurrence for '${habit.title}': $potentialNotificationDateTime");
            return potentialNotificationDateTime;
          }
      }
    }

        Logger.warning("[_getNextOccurrence] Could not find a valid next future occurrence for habit '${habit.title}'.");
    return null;
  }

  DateTimeComponents? _getDateTimeComponents(Habit habit) {
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return DateTimeComponents.time;
      case HabitFrequency.weekly:
        return (habit.daysOfWeek != null && habit.daysOfWeek!.isNotEmpty)
            ? DateTimeComponents.dayOfWeekAndTime
            : null;
      case HabitFrequency.monthly:
        if (habit.daysOfMonth != null && habit.daysOfMonth!.isNotEmpty) {
          if (habit.daysOfMonth!.contains(0) && habit.daysOfMonth!.length == 1) {
            return null;
          }
          return DateTimeComponents.dayOfMonthAndTime;
        }
        return null;

      case HabitFrequency.specificDaysOfYear:
      case HabitFrequency.repeat:
      case HabitFrequency.someTimesPerPeriod:
      case HabitFrequency.custom:
        return null;
      default:
        return null;
    }
  }

  Future<void> cancelHabitReminder(Habit habit) async {
    final String habitId = habit.id;
    final int mainNotificationId = habitId.hashCode;

    try {
      // Cancelar a notificação principal
      await _notifications.cancel(mainNotificationId);
      Logger.info("Cancelled main notification for habit '$habitId' (ID: $mainNotificationId)");

      // Cancelar notificações de snooze relacionadas
      final List<PendingNotificationRequest> pendingNotifications = await _notifications.pendingNotificationRequests();
      for (final PendingNotificationRequest pnr in pendingNotifications) {
        if (pnr.payload != null) {
          try {
            final payloadData = json.decode(pnr.payload!);
            if (payloadData['habitId'] == habitId && pnr.id != mainNotificationId) {
              await _notifications.cancel(pnr.id);
              Logger.info("Cancelled snoozed/related notification (ID: ${pnr.id}) for habit '$habitId'");
            }
          } catch (e) {
            Logger.warning("Error decoding payload for pending notification ${pnr.id}: $e");
          }
        }
      }
    } catch (e,s) {
      Logger.error("Error cancelling notifications for habit $habitId: $e", e, s);
    }
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      channelDescription: 'Channel for test notifications',
      importance: Importance.max,
      priority: Priority.high,
       icon: '@mipmap/ic_launcher',
       actions: <AndroidNotificationAction>[
        AndroidNotificationAction(snoozeActionId, 'Adiar Teste (10 min)'),
      ],
    );
    const iosDetails = DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true, categoryIdentifier: 'HABIT_REMINDER_CATEGORY');
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final testId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    final String testPayload = json.encode({
      'habitId': 'test_habit_id_$testId',
      'title': 'Notificação de Teste',
      'body': 'Este é o corpo da notificação de teste.',
      'color': 0xFF2196F3,
      'originalReminderTime': '${DateTime.now().hour.toString().padLeft(2,'0')}:${DateTime.now().minute.toString().padLeft(2,'0')}',
    });

    await _notifications.show(
      testId,
      'HabitAI - Notificação de Teste',
      'Esta é uma notificação de teste para verificar as configurações e ações.',
      details,
      payload: testPayload,
    );
     Logger.info("Test notification ($testId) shown.");
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    Logger.info("All notifications cancelled.");
  }
}
