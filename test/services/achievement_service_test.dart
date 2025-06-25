import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/data/achievements/achievement_definitions.dart';
import 'package:myapp/data/achievements/user_achievement_profile.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Mock HabitService para o construtor do AchievementService
class MockHabitService extends Mock implements HabitService {}


void main() {
  late AchievementService achievementService;
  late MockFirebaseAuth mockAuth;
  late User mockUser;
  late MockHabitService mockHabitService; // Mock para dependência

  const userId = 'testUserId';

  setUp(() async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    mockUser = MockUser(uid: userId, email: 'test@example.com');
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    // Mock HabitService - não precisamos de implementação real para a maioria dos testes de achievement
    // desde que `checkAchievements` receba a lista de hábitos.
    // No entanto, a implementação atual do AchievementService o instancia.
    // Para manter o teste focado no AchievementService,
    // e dado que a implementação atual do AchievementService não usa Firestore diretamente
    // para ler/escrever achievements (usa SharedPreferences), não precisamos de FakeFirestore aqui.
    // O HabitService injetado é usado para o `getAllHabits` se não for passado.
    mockHabitService = MockHabitService();
    when(mockHabitService.getAllHabits()).thenAnswer((_) async => []); // Default para lista vazia


    achievementService = AchievementService(
      // O AchievementService atual não toma firestore/auth no construtor,
      // mas o UserAchievementProfile é carregado/salvo com SharedPreferences.
      // A dependência do HabitService é para o caso de getAllHabits ser chamado internamente.
      // Se a versão do AchievementService que estou testando é a do código-fonte fornecido,
      // ela não tem construtor com parâmetros.
      // Vamos assumir a versão do código-fonte que usa SharedPreferences.
      // E que `initialize(userId)` será chamado.
    );
    // O AchievementService fornecido não tem um construtor com parâmetros.
    // Ele instancia SharedPreferences internamente.
    // A inicialização é feita via `achievementService.initialize(userId)`
    // Vamos chamar initialize aqui para os testes.
    await achievementService.initialize(userId);

  });

  group('AchievementService Tests', () {
    test('Initial profile should have all achievements locked', () {
      final profile = achievementService.userProfile;
      expect(profile, isNotNull);
      expect(profile!.userId, userId);
      expect(profile.totalPoints, 0);
      expect(profile.level, 1);

      final allDefinitions = AchievementDefinitions.getAllAchievements();
      expect(profile.achievements.length, allDefinitions.length);
      profile.achievements.forEach((id, progress) {
        expect(progress.isUnlocked, isFalse);
        expect(progress.isNew, isFalse);
        expect(progress.currentProgress, 0);
        final def = AchievementDefinitions.getById(id);
        expect(def, isNotNull);
        // targetProgress não está no AchievementProgress, mas sim no AchievementDefinition.requirement
      });
    });

    test('Unlock "Pioneiro dos Hábitos" (habit_pioneer)', () async {
      final habit1 = Habit(id: 'h1', title: 'Hábito 1', category: 'Saúde', icon: Icons.healing, color: Colors.green, frequency: HabitFrequency.daily, startDate: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now(), completionHistory: {}, dailyProgress: {}, userId: userId);
      List<Habit> habits = [habit1];

      // Simular que o serviço de hábito retorna esta lista
      // when(mockHabitService.getAllHabits()).thenAnswer((_) async => habits); // Se o service usasse o mockHabitService

      await achievementService.checkAchievements(habits);

      final profile = achievementService.userProfile!;
      final pioneerProgress = profile.achievements[AchievementDefinitions.varietyAchievements.firstWhere((a) => a.id == 'habit_pioneer').id];

      expect(pioneerProgress, isNotNull);
      expect(pioneerProgress!.isUnlocked, isTrue);
      expect(pioneerProgress.isNew, isTrue);
      expect(pioneerProgress.currentProgress, 1);
      expect(profile.totalPoints, AchievementDefinitions.getById('habit_pioneer')!.points);
      expect(achievementService.recentlyUnlocked, contains('habit_pioneer'));
    });

    test('Unlock "Primeira Missão Cumprida" (getting_started)', () async {
      Habit habit1 = Habit(
        id: 'h1', title: 'Hábito Concluído', category: 'Saúde',
        icon: Icons.healing, color: Colors.green,
        frequency: HabitFrequency.daily, startDate: DateTime.now(),
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
        completionHistory: {DateTime(2023,1,1): true}, // Simula uma conclusão
        dailyProgress: {DateTime(2023,1,1): HabitDailyProgress(date: DateTime(2023,1,1), isCompleted: true)},
        totalCompletions: 1, // Importante
        userId: userId
      );
      List<Habit> habits = [habit1];

      await achievementService.checkAchievements(habits);

      final profile = achievementService.userProfile!;
      final achievementDef = AchievementDefinitions.getById('getting_started')!;
      final progress = profile.achievements[achievementDef.id];

      expect(progress, isNotNull);
      expect(progress!.isUnlocked, isTrue, reason: "Getting started deveria estar desbloqueado com 1 conclusão total");
      expect(progress.isNew, isTrue);
      expect(progress.currentProgress, 1);
      expect(profile.totalPoints, achievementDef.points);
      expect(achievementService.recentlyUnlocked, contains(achievementDef.id));
    });

    test('Unlock "Embalando no Ritmo" (streak_3_days)', () async {
      Habit habit1 = Habit(
        id: 'h1', title: 'Hábito com Streak', category: 'Saúde',
        icon: Icons.healing, color: Colors.green,
        frequency: HabitFrequency.daily, startDate: DateTime.now(),
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
        completionHistory: {},
        dailyProgress: {},
        streak: 3, // Streak de 3 dias
        longestStreak: 3,
        userId: userId
      );
      List<Habit> habits = [habit1];

      await achievementService.checkAchievements(habits);

      final profile = achievementService.userProfile!;
      final achievementDef = AchievementDefinitions.getById('streak_3_days')!;
      final progress = profile.achievements[achievementDef.id];

      expect(progress, isNotNull);
      expect(progress!.isUnlocked, isTrue);
      expect(progress.isNew, isTrue);
      expect(progress.currentProgress, 3);
      expect(profile.totalPoints, achievementDef.points);
      expect(achievementService.recentlyUnlocked, contains(achievementDef.id));
    });

    test('Unlock "Mestre das Categorias" (explorer)', () async {
      List<Habit> habits = [
        Habit(id: 'h1', title: 'H1', category: 'Saúde', icon: Icons.healing, color: Colors.green, frequency: HabitFrequency.daily, startDate: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now(), completionHistory: {}, dailyProgress: {}, userId: userId),
        Habit(id: 'h2', title: 'H2', category: 'Trabalho', icon: Icons.work, color: Colors.blue, frequency: HabitFrequency.daily, startDate: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now(), completionHistory: {}, dailyProgress: {}, userId: userId),
        Habit(id: 'h3', title: 'H3', category: 'Estudos', icon: Icons.school, color: Colors.orange, frequency: HabitFrequency.daily, startDate: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now(), completionHistory: {}, dailyProgress: {}, userId: userId),
      ];

      await achievementService.checkAchievements(habits);

      final profile = achievementService.userProfile!;
      final achievementDef = AchievementDefinitions.getById('explorer')!; // Mestre das Categorias (explorer)
      final progress = profile.achievements[achievementDef.id];

      expect(progress, isNotNull);
      expect(progress!.isUnlocked, isTrue);
      expect(progress.isNew, isTrue);
      expect(progress.currentProgress, 3); // 3 categorias distintas
      expect(profile.totalPoints, achievementDef.points);
    });

    test('Unlock "Semana Impecável" (perfect_week)', () async {
      final today = DateTime.now();
      Map<DateTime, bool> perfectWeekHistory = {};
      for(int i=0; i<7; i++){
        perfectWeekHistory[DateTime(today.year, today.month, today.day).subtract(Duration(days:i))] = true;
      }

      Habit dailyHabit = Habit(
        id: 'h_daily', title: 'Hábito Diário Perfeito', category: 'Rotina',
        icon: Icons.check, color: Colors.purple,
        frequency: HabitFrequency.daily, // Hábito diário
        startDate: today.subtract(const Duration(days: 10)),
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
        completionHistory: perfectWeekHistory,
        dailyProgress: {},
        streak: 7, // Streak de 7 dias
        longestStreak: 7,
        totalCompletions: 7,
        userId: userId
      );
      List<Habit> habits = [dailyHabit];

      await achievementService.checkAchievements(habits);

      final profile = achievementService.userProfile!;
      final achievementDef = AchievementDefinitions.getById('perfect_week')!;
      final progress = profile.achievements[achievementDef.id];

      expect(progress, isNotNull);
      expect(progress!.isUnlocked, isTrue, reason: "Deveria desbloquear Semana Impecável com hábito diário e streak 7");
      expect(progress.isNew, isTrue);
      expect(progress.currentProgress, greaterThanOrEqualTo(7));
      expect(profile.totalPoints, achievementDef.points);
    });


    test('markAchievementsAsSeen deve limpar isNew e recentlyUnlocked', () async {
      // Desbloquear uma conquista primeiro
      final habit1 = Habit(id: 'h1', title: 'Hábito 1', category: 'Saúde', icon: Icons.healing, color: Colors.green, frequency: HabitFrequency.daily, startDate: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now(), completionHistory: {}, dailyProgress: {}, userId: userId);
      await achievementService.checkAchievements([habit1]);

      final pioneerId = AchievementDefinitions.varietyAchievements.firstWhere((a) => a.id == 'habit_pioneer').id;
      expect(achievementService.userProfile!.achievements[pioneerId]!.isNew, isTrue);
      expect(achievementService.recentlyUnlocked, contains(pioneerId));

      await achievementService.markAchievementsAsSeen([pioneerId]);

      expect(achievementService.userProfile!.achievements[pioneerId]!.isNew, isFalse);
      expect(achievementService.recentlyUnlocked, isEmpty); // clearRecentlyUnlocked é chamado no SnackBar, mas aqui testamos o markAsSeen
    });

    test('clearRecentlyUnlocked deve limpar a lista', () async {
       final habit1 = Habit(id: 'h1', title: 'Hábito 1', category: 'Saúde', icon: Icons.healing, color: Colors.green, frequency: HabitFrequency.daily, startDate: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now(), completionHistory: {}, dailyProgress: {}, userId: userId);
      await achievementService.checkAchievements([habit1]);

      expect(achievementService.recentlyUnlocked, isNotEmpty);
      achievementService.clearRecentlyUnlocked();
      expect(achievementService.recentlyUnlocked, isEmpty);
    });

  });
}
