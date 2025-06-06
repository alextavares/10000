import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/models/task.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import '../test_helpers/test_setup.dart';

@GenerateMocks([TaskService])
import 'task_service_test.mocks.dart';

void main() {
  group('TaskService Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    
    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(
        mockUser: MockUser(
          isAnonymous: false,
          uid: 'test-uid',
          email: 'test@example.com',
        ),
      );
    });

    test('Deve criar uma nova tarefa', () async {
      // Arrange
      final task = Task(
        id: 'task-1',
        title: 'Nova Tarefa',
        description: 'Descrição da tarefa',
        category: 'Trabalho',
        type: TaskType.yesNo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: false,
        notificationsEnabled: false,
        completionHistory: {},
      );

      // Act - Salvar no Firestore falso
      await fakeFirestore
          .collection('users')
          .doc('test-uid')
          .collection('tasks')
          .doc(task.id)
          .set(task.toMap());

      // Assert
      final doc = await fakeFirestore
          .collection('users')
          .doc('test-uid')
          .collection('tasks')
          .doc(task.id)
          .get();
      
      expect(doc.exists, true);
      expect(doc.data()?['title'], 'Nova Tarefa');
    });

    test('Deve verificar se tarefa está completa hoje', () async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final task = Task(
        id: 'task-complete',
        title: 'Tarefa Completa',
        category: 'Teste',
        type: TaskType.yesNo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: false,
        notificationsEnabled: false,
        completionHistory: {today: true},
      );

      // Act
      final isCompletedToday = task.isCompletedToday();

      // Assert
      expect(isCompletedToday, true);
    });

    test('Deve copiar tarefa com copyWith', () {
      // Arrange
      final originalTask = Task(
        id: 'original',
        title: 'Original',
        category: 'Teste',
        type: TaskType.yesNo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: false,
        notificationsEnabled: false,
        completionHistory: {},
      );

      // Act
      final copiedTask = originalTask.copyWith(
        title: 'Copied',
        isCompleted: true,
      );

      // Assert
      expect(copiedTask.title, 'Copied');
      expect(copiedTask.isCompleted, true);
      expect(copiedTask.id, originalTask.id); // ID deve permanecer o mesmo
      expect(copiedTask.category, originalTask.category);
    });

    test('Deve converter tarefa para Map', () {
      // Arrange
      final task = Task(
        id: 'map-test',
        title: 'Map Test',
        description: 'Testing toMap',
        category: 'Test',
        type: TaskType.yesNo,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        isCompleted: false,
        notificationsEnabled: true,
        completionHistory: {},
      );

      // Act
      final map = task.toMap();

      // Assert
      expect(map['id'], 'map-test');
      expect(map['title'], 'Map Test');
      expect(map['description'], 'Testing toMap');
      expect(map['category'], 'Test');
      expect(map['type'], 'TaskType.yesNo');
      expect(map['notificationsEnabled'], true);
      expect(map['isCompleted'], false);
    });

    test('Deve criar tarefa a partir de Map', () {
      // Arrange
      final map = {
        'id': 'from-map',
        'title': 'From Map',
        'description': 'Created from map',
        'category': 'Test',
        'type': 'TaskType.yesNo',
        'createdAt': DateTime(2024, 1, 1),
        'updatedAt': DateTime(2024, 1, 2),
        'isCompleted': false,
        'notificationsEnabled': true,
        'completionHistory': {},
      };

      // Act
      final task = Task.fromMap(map);

      // Assert
      expect(task.id, 'from-map');
      expect(task.title, 'From Map');
      expect(task.description, 'Created from map');
      expect(task.category, 'Test');
      expect(task.type, TaskType.yesNo);
      expect(task.notificationsEnabled, true);
      expect(task.isCompleted, false);
    });

    test('Deve marcar tarefa como completa', () {
      // Arrange
      final task = Task(
        id: 'complete-test',
        title: 'Complete Test',
        category: 'Test',
        type: TaskType.yesNo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: false,
        notificationsEnabled: false,
        completionHistory: {},
      );

      // Act
      final today = DateTime.now();
      task.markCompleted(today);

      // Assert
      expect(task.isCompletedToday(), true);
    });

    test('Deve marcar tarefa como não completa', () {
      // Arrange
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      
      final task = Task(
        id: 'uncomplete-test',
        title: 'Uncomplete Test',
        category: 'Test',
        type: TaskType.yesNo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: false,
        notificationsEnabled: false,
        completionHistory: {todayOnly: true},
      );

      // Act
      task.markNotCompleted(today);

      // Assert
      expect(task.completionHistory[todayOnly], false);
    });

    test('Deve lidar com valores nulos ao criar de Map', () {
      // Arrange
      final map = {
        'id': 'minimal',
        'title': 'Minimal Task',
        // Outros campos são opcionais
      };

      // Act
      final task = Task.fromMap(map);

      // Assert
      expect(task.id, 'minimal');
      expect(task.title, 'Minimal Task');
      expect(task.description, isNull);
      expect(task.category, isNull);
      expect(task.type, TaskType.yesNo); // Valor padrão
      expect(task.notificationsEnabled, false); // Valor padrão
    });
  });
}
