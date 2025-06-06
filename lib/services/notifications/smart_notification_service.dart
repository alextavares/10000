import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/notifications/notification_models.dart';
import 'package:myapp/services/notifications/behavior_analyzer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

class SmartNotificationService extends ChangeNotifier {
  static final SmartNotificationService _instance = SmartNotificationService._internal();
  factory SmartNotificationService() => _instance;
  SmartNotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final BehaviorAnalyzer _behaviorAnalyzer = BehaviorAnalyzer();
  
  Map<String, HabitNotificationSettings> _habitSettings = {};
  List<SmartNotification> _scheduledNotifications = [];
  UserBehaviorPattern? _userPattern;
  bool _isInitialized = false;
  
  // Getters
  bool get isInitialized => _isInitialized;
  UserBehaviorPattern? get userPattern => _userPattern;
  
  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Configurações do Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configurações do iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Inicializar
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Carregar configurações salvas
    await _loadSettings();
    
    _isInitialized = true;
    notifyListeners();
  }
  
  /// Callback quando uma notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final data = json.decode(payload);
      final route = data['route'];
      if (route != null) {
        // Navegar para a rota específica
        // Navigator.pushNamed(context, route);
      }
    }
  }
  
  /// Analisa o comportamento do usuário e atualiza padrões
  Future<void> analyzeUserBehavior(List<Habit> habits) async {
    _userPattern = await _behaviorAnalyzer.analyzePatterns(habits);
    notifyListeners();
    
    // Reagendar notificações baseado nos novos padrões
    if (_userPattern != null) {
      await _rescheduleAllNotifications(habits);
    }
  }
  
  /// Agenda notificações inteligentes para um hábito
  Future<void> scheduleSmartNotifications(Habit habit, {List<DateTime>? customTimes}) async {
    final settings = _habitSettings[habit.id] ?? HabitNotificationSettings(
      habitId: habit.id,
      reminderTimes: [],
    );
    
    if (!settings.enabled) return;
    
    // Cancelar notificações anteriores deste hábito
    await cancelHabitNotifications(habit.id);
    
    final now = DateTime.now();
    final notifications = <SmartNotification>[];
    
    // Se customTimes foi fornecido, usar esses horários
    if (customTimes != null && customTimes.isNotEmpty) {
      for (final time in customTimes) {
        if (time.isAfter(now)) {
          notifications.add(_createSmartReminder(habit, time));
        }
      }
    } else {
      // 1. Notificações de lembrete baseadas em IA
      if (settings.smartScheduling && _userPattern != null) {
      final optimalTimes = _behaviorAnalyzer.predictOptimalNotificationTimes(
        habit,
        _userPattern!,
      );
      
      for (final time in optimalTimes) {
        final scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        
        if (scheduledTime.isAfter(now)) {
          notifications.add(_createSmartReminder(habit, scheduledTime));
        }
      }
    } else {
      // Usar horários fixos definidos pelo usuário
      for (final time in settings.reminderTimes) {
        final scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        
        if (scheduledTime.isAfter(now)) {
          notifications.add(_createSmartReminder(habit, scheduledTime));
        }
      }
    }
    }
    
    // 2. Notificações motivacionais (se habilitadas)
    if (settings.motivationalMessages) {
      final motivationalTime = _calculateMotivationalTime(habit);
      if (motivationalTime != null && motivationalTime.isAfter(now)) {
        notifications.add(_createMotivationalNotification(habit, motivationalTime));
      }
    }
    
    // 3. Notificações de streak (se aplicável)
    if (settings.streakReminders && habit.streak > 0) {
      final streakTime = _calculateStreakReminderTime(habit);
      if (streakTime != null && streakTime.isAfter(now)) {
        notifications.add(_createStreakNotification(habit, streakTime));
      }
    }
    
    // Agendar todas as notificações
    for (final notification in notifications) {
      await _scheduleNotification(notification);
      _scheduledNotifications.add(notification);
    }
    
    // Salvar estado
    await _saveScheduledNotifications();
  }
  
  /// Cria uma notificação de lembrete inteligente
  SmartNotification _createSmartReminder(Habit habit, DateTime scheduledTime) {
    final timeOfDay = TimeOfDay.fromDateTime(scheduledTime);
    
    return SmartNotification(
      id: '${habit.id}_reminder_${scheduledTime.millisecondsSinceEpoch}',
      habitId: habit.id,
      title: NotificationTemplates.generateTitle(
        type: NotificationType.reminder,
        habitTitle: habit.title,
      ),
      body: NotificationTemplates.generatePersonalizedMessage(
        type: NotificationType.reminder,
        habitTitle: habit.title,
        currentTime: timeOfDay,
        category: habit.category,
        completionRate: habit.getCompletionRate(),
      ),
      type: NotificationType.reminder,
      scheduledTime: scheduledTime,
      priority: 3,
      actionText: 'Fazer Agora',
      actionRoute: '/habit/${habit.id}',
    );
  }
  
  /// Cria uma notificação motivacional
  SmartNotification _createMotivationalNotification(Habit habit, DateTime scheduledTime) {
    final timeOfDay = TimeOfDay.fromDateTime(scheduledTime);
    
    return SmartNotification(
      id: '${habit.id}_motivation_${scheduledTime.millisecondsSinceEpoch}',
      habitId: habit.id,
      title: '💪 Motivação do Dia',
      body: NotificationTemplates.generatePersonalizedMessage(
        type: NotificationType.motivation,
        habitTitle: habit.title,
        currentTime: timeOfDay,
        category: habit.category,
        completionRate: habit.getCompletionRate(),
      ),
      type: NotificationType.motivation,
      scheduledTime: scheduledTime,
      priority: 2,
      metadata: {
        'category': habit.category,
        'completionRate': habit.getCompletionRate(),
      },
    );
  }
  
  /// Cria uma notificação de streak
  SmartNotification _createStreakNotification(Habit habit, DateTime scheduledTime) {
    return SmartNotification(
      id: '${habit.id}_streak_${scheduledTime.millisecondsSinceEpoch}',
      habitId: habit.id,
      title: NotificationTemplates.generateTitle(
        type: NotificationType.streak,
        habitTitle: habit.title,
        streak: habit.streak,
      ),
      body: NotificationTemplates.generatePersonalizedMessage(
        type: NotificationType.streak,
        habitTitle: habit.title,
        currentTime: TimeOfDay.fromDateTime(scheduledTime),
        currentStreak: habit.streak,
      ),
      type: NotificationType.streak,
      scheduledTime: scheduledTime,
      priority: 4,
      metadata: {
        'currentStreak': habit.streak,
        'longestStreak': habit.longestStreak,
      },
    );
  }
  
  /// Calcula o melhor horário para notificação motivacional
  DateTime? _calculateMotivationalTime(Habit habit) {
    final now = DateTime.now();
    final random = math.Random();
    
    // Enviar em um momento aleatório entre 10h e 20h
    final hour = 10 + random.nextInt(10);
    final minute = random.nextInt(60);
    
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
  
  /// Calcula o horário para lembrete de streak
  DateTime? _calculateStreakReminderTime(Habit habit) {
    final now = DateTime.now();
    
    // Se o hábito costuma ser feito pela manhã, lembrar à tarde
    // Se costuma ser à tarde/noite, lembrar de manhã
    if (_userPattern != null) {
      final morningTime = _userPattern!.optimalMorningTime;
      if (morningTime != null && habit.reminderTime?.hour == morningTime.hour) {
        // Hábito matinal - lembrar às 15h
        return DateTime(now.year, now.month, now.day, 15, 0);
      }
    }
    
    // Padrão: lembrar às 19h
    return DateTime(now.year, now.month, now.day, 19, 0);
  }
  
  /// Agenda uma notificação no sistema
  Future<void> _scheduleNotification(SmartNotification notification) async {
    final androidDetails = AndroidNotificationDetails(
      'habit_channel_${notification.type.name}',
      'Notificações de ${_getChannelName(notification.type)}',
      channelDescription: 'Notificações inteligentes do HabitAI',
      importance: _getImportance(notification.priority),
      priority: _getPriority(notification.priority),
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF6200EE),
      enableVibration: true,
      playSound: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Converter para timezone aware
    final tzTime = tz.TZDateTime.from(notification.scheduledTime, tz.local);
    
    await _notifications.zonedSchedule(
      notification.id.hashCode,
      notification.title,
      notification.body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: json.encode({
        'id': notification.id,
        'habitId': notification.habitId,
        'type': notification.type.name,
        'route': notification.actionRoute,
      }),
    );
  }
  
  /// Cancela todas as notificações de um hábito
  Future<void> cancelHabitNotifications(String habitId) async {
    final toRemove = _scheduledNotifications
        .where((n) => n.habitId == habitId)
        .toList();
    
    for (final notification in toRemove) {
      await _notifications.cancel(notification.id.hashCode);
      _scheduledNotifications.remove(notification);
    }
    
    await _saveScheduledNotifications();
  }
  
  /// Reagenda todas as notificações baseado em novos padrões
  Future<void> _rescheduleAllNotifications(List<Habit> habits) async {
    // Cancelar todas as notificações existentes
    await _notifications.cancelAll();
    _scheduledNotifications.clear();
    
    // Reagendar para cada hábito
    for (final habit in habits) {
      await scheduleSmartNotifications(habit);
    }
  }
  
  /// Atualiza configurações de notificação para um hábito
  Future<void> updateHabitSettings(
    String habitId,
    HabitNotificationSettings settings,
  ) async {
    _habitSettings[habitId] = settings;
    await _saveSettings();
    notifyListeners();
  }
  
  /// Obtém configurações de um hábito
  HabitNotificationSettings? getHabitSettings(String habitId) {
    return _habitSettings[habitId];
  }
  
  /// Envia uma notificação instantânea (para testes ou eventos especiais)
  Future<void> sendInstantNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.motivation,
    String? route,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Notificações Instantâneas',
      channelDescription: 'Notificações imediatas do HabitAI',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF6200EE),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      details,
      payload: route != null ? json.encode({'route': route}) : null,
    );
  }
  
  /// Carrega configurações salvas
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Carregar configurações de hábitos
    final settingsJson = prefs.getString('habit_notification_settings');
    if (settingsJson != null) {
      final Map<String, dynamic> settingsMap = json.decode(settingsJson);
      _habitSettings = settingsMap.map(
        (key, value) => MapEntry(
          key,
          HabitNotificationSettings.fromMap(value),
        ),
      );
    }
    
    // Carregar notificações agendadas
    final notificationsJson = prefs.getString('scheduled_notifications');
    if (notificationsJson != null) {
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      _scheduledNotifications = notificationsList
          .map((n) => SmartNotification.fromMap(n))
          .toList();
    }
  }
  
  /// Salva configurações
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final settingsMap = _habitSettings.map(
      (key, value) => MapEntry(key, value.toMap()),
    );
    
    await prefs.setString(
      'habit_notification_settings',
      json.encode(settingsMap),
    );
  }
  
  /// Salva notificações agendadas
  Future<void> _saveScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    
    final notificationsList = _scheduledNotifications
        .map((n) => n.toMap())
        .toList();
    
    await prefs.setString(
      'scheduled_notifications',
      json.encode(notificationsList),
    );
  }
  
  // Helpers para configuração de notificação
  
  String _getChannelName(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return 'Lembretes';
      case NotificationType.motivation:
        return 'Motivação';
      case NotificationType.streak:
        return 'Sequências';
      case NotificationType.achievement:
        return 'Conquistas';
      case NotificationType.insight:
        return 'Insights';
      case NotificationType.challenge:
        return 'Desafios';
      case NotificationType.celebration:
        return 'Celebrações';
      case NotificationType.comeback:
        return 'Retorno';
      case NotificationType.smartSuggestion:
        return 'Sugestões Inteligentes';
    }
  }
  
  Importance _getImportance(int priority) {
    if (priority >= 4) return Importance.high;
    if (priority >= 3) return Importance.defaultImportance;
    if (priority >= 2) return Importance.low;
    return Importance.min;
  }
  
  Priority _getPriority(int priority) {
    if (priority >= 4) return Priority.high;
    if (priority >= 3) return Priority.defaultPriority;
    return Priority.low;
  }
}
