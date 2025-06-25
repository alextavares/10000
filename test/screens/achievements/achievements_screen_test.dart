import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/data/achievements/achievement_definitions.dart';
import 'package:myapp/data/achievements/user_achievement_profile.dart';
import 'package:myapp/models/habit.dart'; // Necessário para HabitFrequency
import 'package:myapp/screens/achievements/achievements_screen.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/auth_service.dart'; // Para mock do AuthService e User
import 'package:myapp/services/habit_service.dart'; // Para o construtor de AchievementService
import 'package:myapp/services/notification_service.dart'; // Para o construtor de HabitService
import 'package:myapp/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class MockAuthService extends Mock implements AuthService {}
class MockHabitService extends Mock implements HabitService {}
class MockNotificationService extends Mock implements NotificationService {}
class MockAchievementService extends Mock implements AchievementService {
  // Precisamos mockar o getter userProfile e recentlyUnlocked, e o método initialize
  UserAchievementProfile? _profile;
  List<String> _recent = [];

  @override
  UserAchievementProfile? get userProfile => _profile;

  @override
  List<String> get recentlyUnlocked => List.unmodifiable(_recent);

  @override
  FirebaseAuth get auth => MockFirebaseAuth(); // Retorna um mock básico

  @override
  Future<void> initialize(String userId) async {
    _profile = UserAchievementProfile.initial(userId); // Cria um perfil inicial para o teste
    // Simula o carregamento de algumas conquistas desbloqueadas
    final pioneerDef = AchievementDefinitions.getById('habit_pioneer')!;
    _profile!.achievements[pioneerDef.id] = AchievementProgress(
      achievementId: pioneerDef.id,
      currentProgress: pioneerDef.requirement,
      isUnlocked: true,
      unlockedAt: DateTime.now().subtract(const Duration(days: 1)),
      isNew: true, // Marcar como nova para teste de UI
    );
    _profile = _profile!.copyWith(totalPoints: pioneerDef.points, level: UserAchievementProfile.calculateLevel(pioneerDef.points), title: UserAchievementProfile.getLevelTitle(UserAchievementProfile.calculateLevel(pioneerDef.points)));
    _recent.add(pioneerDef.id);
    notifyListeners(); // Notifica os listeners sobre a mudança
  }

  @override
  List<AchievementDefinition> getAllAchievementDefinitions() {
    return AchievementDefinitions.getAllAchievements();
  }

  @override
  void clearRecentlyUnlocked() {
    _recent.clear();
    notifyListeners();
  }

  @override
  Future<void> markAchievementsAsSeen(List<String> achievementIds) async {
    if (_profile == null) return;
    Map<String, AchievementProgress> updatedAchievements = Map.from(_profile!.achievements);
    bool changed = false;
    for (String id in achievementIds) {
      if (updatedAchievements.containsKey(id) && updatedAchievements[id]!.isNew) {
        updatedAchievements[id] = updatedAchievements[id]!.copyWith(isNew: false);
        changed = true;
      }
    }
    if (changed) {
      _profile = _profile!.copyWith(achievements: updatedAchievements);
      _recent.removeWhere((id) => achievementIds.contains(id));
      notifyListeners();
    }
  }
   // Mock para o getter auth que é usado internamente
  // @override
  // FirebaseAuth get auth => MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'test_user_id'));

}


void main() {
  late MockAchievementService mockAchievementService;
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  setUp(() async {
     // Mock SharedPreferences pois AchievementService usa internamente
    SharedPreferences.setMockInitialValues({});
    TestWidgetsFlutterBinding.ensureInitialized(); // Para DateFormat

    mockAchievementService = MockAchievementService();
    mockUser = MockUser(uid: 'test_user_id');
    mockAuthService = MockAuthService();
    when(mockAuthService.currentUser).thenReturn(mockUser); // Simula usuário logado

    // Configura o mock para initialize e para retornar um perfil
    // A inicialização agora é feita dentro do mock para este teste
    // await mockAchievementService.initialize('test_user_id');
  });

  Widget createAchievementsScreen() {
    // O AchievementService é um ChangeNotifier, então usamos ChangeNotifierProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AchievementService>.value(value: mockAchievementService),
        Provider<AuthService>.value(value: mockAuthService),
        // Outros serviços que AchievementScreen possa depender indiretamente via context
        Provider<HabitService>(create: (_) => MockHabitService()),
        Provider<NotificationService>(create: (_) => MockNotificationService()),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const AchievementsScreen(),
        routes: {
          AchievementsScreen.routeName: (context) => const AchievementsScreen(),
        },
      ),
    );
  }

  group('AchievementsScreen Widget Tests', () {
    testWidgets('Mostra loading e depois dados do perfil e conquistas', (WidgetTester tester) async {
      // É crucial que o initialize do mockAchievementService seja chamado
      // antes que o FutureBuilder em AchievementsScreen tente acessar userProfile.
      // O initState da AchievementsScreen tenta chamar initialize se userProfile for null.
      // Para garantir, vamos chamar initialize no mock antes de construir o widget.
      await mockAchievementService.initialize('test_user_id');

      await tester.pumpWidget(createAchievementsScreen());

      // Estado de Loading inicial do FutureBuilder
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle(); // Espera o FutureBuilder completar

      // Verifica o card de resumo do perfil
      expect(find.text(mockAchievementService.userProfile!.title), findsOneWidget);
      expect(find.text('Nível ${mockAchievementService.userProfile!.level}'), findsOneWidget);
      expect(find.text(' ${mockAchievementService.userProfile!.totalPoints} Pontos'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verifica se os títulos das categorias de conquistas são exibidos
      expect(find.text('🔥 Sequências Incríveis'), findsOneWidget);
      expect(find.text('✅ Marcas de Conclusão'), findsOneWidget);

      // Verifica se a conquista desbloqueada "Pioneiro dos Hábitos" está lá
      final pioneerDef = AchievementDefinitions.getById('habit_pioneer')!;
      expect(find.text(pioneerDef.name), findsOneWidget);
      expect(find.byIcon(pioneerDef.icon), findsWidgets); // Pode haver mais de um (no card e no indicador "novo")

      // Verifica o indicador de "novo" (um Container pequeno)
      // O indicador de "novo" é um Container dentro de um Stack no ListTile leading.
      // Pode ser difícil de encontrar sem uma Key específica.
      // Vamos verificar se o SnackBar de desbloqueio aparece (seria testado no widget pai - MainNavigationScreen)
      // Aqui, verificamos se o _markAchievementsAsSeen foi chamado.
      // Isso é indireto, mas se `isNew` se torna false, funcionou.

      // Simular que a tela ficou visível e o postFrameCallback foi chamado
      await tester.pumpAndSettle(const Duration(milliseconds: 100)); // Para o addPostFrameCallback

      // Após markAchievementsAsSeen, isNew deve ser false
      final updatedPioneerProgress = mockAchievementService.userProfile!.achievements[pioneerDef.id];
      expect(updatedPioneerProgress?.isNew, isFalse, reason: "isNew deveria ser false após visualização");

    });

    testWidgets('Mostra progresso para conquistas não desbloqueadas', (WidgetTester tester) async {
       await mockAchievementService.initialize('test_user_id');
      // Modificar o perfil para ter uma conquista não desbloqueada com progresso
      final streak3DaysDef = AchievementDefinitions.getById('streak_3_days')!;
      mockAchievementService._profile!.achievements[streak3DaysDef.id] = AchievementProgress(
        achievementId: streak3DaysDef.id,
        currentProgress: 1, // Progresso de 1 em 3
        isUnlocked: false,
        isNew: false,
      );
      // Forçar notificação para reconstruir com o novo perfil (se necessário)
      // mockAchievementService.notifyListeners(); // O teste já pega o profile atualizado

      await tester.pumpWidget(createAchievementsScreen());
      await tester.pumpAndSettle();

      expect(find.text(streak3DaysDef.name), findsOneWidget);
      expect(find.text('Progresso: 1 / ${streak3DaysDef.requirement}'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsWidgets); // Ícone de bloqueado
    });

    testWidgets('Exibe data de desbloqueio para conquistas desbloqueadas', (WidgetTester tester) async {
       await mockAchievementService.initialize('test_user_id'); // Já desbloqueia 'habit_pioneer' com data

      await tester.pumpWidget(createAchievementsScreen());
      await tester.pumpAndSettle();

      final pioneerDef = AchievementDefinitions.getById('habit_pioneer')!;
      final unlockedDate = mockAchievementService.userProfile!.achievements[pioneerDef.id]!.unlockedAt!;
      final formattedDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(unlockedDate);

      expect(find.text('Desbloqueado em: $formattedDate'), findsOneWidget);
    });

    testWidgets('Conquistas secretas não são mostradas a menos que desbloqueadas', (WidgetTester tester) async {
       await mockAchievementService.initialize('test_user_id');
      final secretAchievement = AchievementDefinitions.getById('comeback_kid')!; // é secreta

      await tester.pumpWidget(createAchievementsScreen());
      await tester.pumpAndSettle();

      // Não deve encontrar a conquista secreta se ela não estiver no perfil como desbloqueada
      expect(find.text(secretAchievement.name), findsNothing);

      // Agora, simular desbloqueio da secreta
      mockAchievementService._profile!.achievements[secretAchievement.id] = AchievementProgress(
        achievementId: secretAchievement.id,
        currentProgress: secretAchievement.requirement,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        isNew: true,
      );
      // Forçar o FutureBuilder a reconstruir com o novo perfil
      // (Uma forma é chamar setState no widget de teste, ou recriar o _achievementsDataFuture)
      // Para este teste, vamos recarregar o widget.
      await tester.pumpWidget(createAchievementsScreen());
      await tester.pumpAndSettle();

      expect(find.text(secretAchievement.name), findsOneWidget); // Agora deve estar visível
    });

  });
}
