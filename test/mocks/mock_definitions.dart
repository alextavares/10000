// ignore_for_file: unused_import

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/annotations.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/genkit_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/task_service.dart';

// Adicione todas as classes de serviço que precisam de mock aqui.
// O comando `build_runner` irá gerar o arquivo `generated.mocks.dart`.
@GenerateMocks([AuthService, HabitService, TaskService, CategoryService, NotificationService, AchievementService, GenkitService, FlutterLocalNotificationsPlugin])
void main() {}