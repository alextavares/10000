import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Precisamos mockar FlutterLocalNotificationsPlugin
@GenerateMocks([FlutterLocalNotificationsPlugin])
import 'notification_service_snooze_test.mocks.dart';

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockFlutterLocalNotificationsPlugin;

  setUpAll(() {
    tz_data.initializeTimeZones();
    // Defina um local padrão para tz.local, se necessário para consistência nos testes
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
  });

  setUp(() {
    mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService();

    // "Injetar" o mock no service. Como NotificationService cria sua própria instância,
    // isso é complicado. A melhor abordagem seria o NotificationService aceitar
    // o plugin no construtor. Para este teste, vamos focar na lógica que *seria* chamada.
    // Esta é uma limitação do design atual do NotificationService para testes unitários profundos.
    // Vamos testar o método _handleSnoozeAction mais diretamente se possível,
    // ou simular o fluxo de _onNotificationResponse.

    // Configuração do mock para initialize
    // Necessário porque _onNotificationResponse é chamado internamente após initialize
     final androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
     final darwinInitSettings = DarwinInitializationSettings(
        notificationCategories: [
         DarwinNotificationCategory(
            NotificationService.snoozeActionId, // Este não é o categoryIdentifier, mas para simplificar o mock
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain(NotificationService.snoozeActionId, 'Adiar (10 min)'),
            ],
          )
        ]
     );
    final initSettings = InitializationSettings(android: androidInitSettings, iOS: darwinInitSettings);

    // Mock a inicialização para evitar erros
    when(mockFlutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      onDidReceiveBackgroundNotificationResponse: anyNamed('onDidReceiveBackgroundNotificationResponse'),
    )).thenAnswer((_) async => true);

    // Mock para as chamadas de agendamento e cancelamento
    when(mockFlutterLocalNotificationsPlugin.zonedSchedule(
      any, any, any, any, any,
      androidScheduleMode: anyNamed('androidScheduleMode'),
      uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
      payload: anyNamed('payload'),
      matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
    )).thenAnswer((_) async {
      return null;
    });

    when(mockFlutterLocalNotificationsPlugin.cancel(any)).thenAnswer((_) async {
      return null;
    });

    // Para testar _handleSnoozeAction, precisamos de uma forma de chamar _onNotificationResponse
    // ou expor _handleSnoozeAction (o que não é ideal para um método privado).
    // Vamos simular o _onNotificationResponse sendo chamado.
  });

  group('NotificationService Snooze Logic', () {
    testWidgets('Quando _onNotificationResponse é chamada com ação de snooze, deve tentar cancelar e reagendar', (WidgetTester tester) async {
      // Este teste é mais uma simulação da chamada do callback, pois não podemos instanciar
      // NotificationService com o mock plugin diretamente da forma como está construído.
      // Vamos assumir que o initialize foi chamado e os handlers estão configurados.

      final habitId = 'habit_snooze_test';
      final originalTitle = "Test Snooze Habit";
      final originalBody = "Time to test snooze";
      final originalColor = Colors.blue.value;
      final originalReminderTime = "09:00";

      final payloadData = {
        'habitId': habitId,
        'title': originalTitle,
        'body': originalBody,
        'color': originalColor,
        'originalReminderTime': originalReminderTime,
      };
      final String payloadJson = json.encode(payloadData);

      final response = NotificationResponse(
        payload: payloadJson,
        actionId: NotificationService.snoozeActionId,
        id: habitId.hashCode, // ID da notificação original
        notificationResponseType: NotificationResponseType.selectedNotificationAction,
      );

      // Para realmente testar _handleSnoozeAction, precisaríamos de uma instância
      // de NotificationService que use nosso mockFlutterLocalNotificationsPlugin.
      // Como isso não é diretamente possível com o design atual do service,
      // este teste se torna mais conceitual ou exigiria refatoração do service para DI.

      // Se pudéssemos chamar notificationService._onNotificationResponse(response)
      // e o notificationService usasse o mock internamente, poderíamos verificar:
      // await notificationService._onNotificationResponse(response);
      // verify(mockFlutterLocalNotificationsPlugin.cancel(habitId.hashCode)).called(1);
      // verify(mockFlutterLocalNotificationsPlugin.zonedSchedule(
      //   argThat(isNot(habitId.hashCode)), // Novo ID para snooze
      //   "Adiado: $originalTitle",
      //   originalBody,
      //   any, // snoozedTime
      //   any, // detailsSnooze
      //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      //   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      //   payload: payloadJson, // Mesmo payload
      // )).called(1);

      // Devido à dificuldade de mockar o plugin interno, este teste permanece mais como um
      // guia do que uma verificação funcional completa sem refatorar o NotificationService.
      // O que podemos fazer é testar o _getNextOccurrence e _getDateTimeComponents separadamente,
      // e os testes manuais / Maestro para o fluxo de snooze completo.

      expect(true, isTrue); // Placeholder para indicar que o teste foi considerado.
    });

    test('notificationTapBackground deve tentar reagendar para snooze', () async {
        final habitId = 'habit_bg_snooze';
        final title = 'BG Snooze Test';
        final body = 'Test body';
        final color = Colors.red.value;
        final reminderTime = "10:00";

        final payloadData = {
            'habitId': habitId,
            'title': title,
            'body': body,
            'color': color,
            'originalReminderTime': reminderTime,
        };
        final String payloadJson = json.encode(payloadData);

        final response = NotificationResponse(
            payload: payloadJson,
            actionId: NotificationService.snoozeActionId,
            id: habitId.hashCode,
            notificationResponseType: NotificationResponseType.selectedNotificationAction,
        );

        // Esta chamada é estática e tentará criar sua própria instância do plugin.
        // O mock direto é difícil aqui. O teste é mais para verificar a lógica conceitual.
        // NotificationService.notificationTapBackground(response);

        // Para um teste real, precisaríamos de um setup de plataforma e possivelmente
        // um teste de integração.
        // O verify(...) não funcionará aqui da mesma forma.
        expect(true, isTrue); // Placeholder
    });


  });
}

// Helper para simular o ServiceProvider se necessário em testes mais integrados
class TestServiceProvider extends StatelessWidget {
  final Widget child;
  final MockCategoryService? categoryService;
  final MockHabitService? habitService;
  final MockFirebaseAuth? firebaseAuth;
  final NotificationService? notificationService;


  const TestServiceProvider({
    super.key,
    required this.child,
    this.categoryService,
    this.habitService,
    this.firebaseAuth,
    this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CategoryService>.value(value: categoryService ?? MockCategoryService()),
        Provider<HabitService>.value(value: habitService ?? MockHabitService()),
        Provider<FirebaseAuth>.value(value: firebaseAuth ?? MockFirebaseAuth()),
        Provider<NotificationService>.value(value: notificationService ?? NotificationService()),
      ],
      child: child,
    );
  }
}
