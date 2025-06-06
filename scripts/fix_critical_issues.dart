#!/usr/bin/env dart

import 'dart:io';

/// Script para corrigir automaticamente os problemas críticos do projeto
/// Execute com: dart run scripts/fix_critical_issues.dart

void main() async {
  print('🔧 Iniciando correção automática de problemas críticos...\n');
  
  await fixPrintStatements();
  await createEnvironmentConfig();
  await updateAnalysisOptions();
  await createLoggerUtility();
  await createErrorHandler();
  
  print('\n✅ Correções automáticas concluídas!');
  print('📋 Próximos passos manuais:');
  print('1. Configurar variáveis de ambiente no .env');
  print('2. Atualizar main.dart para usar AppConfig');
  print('3. Revisar e corrigir testes');
  print('4. Executar flutter analyze para verificar');
}

/// Remove print statements e substitui por logging adequado
Future<void> fixPrintStatements() async {
  print('🧹 Corrigindo print statements...');
  
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('❌ Diretório lib/ não encontrado');
    return;
  }
  
  await for (final file in libDir.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      await _fixPrintInFile(file);
    }
  }
  
  print('✅ Print statements corrigidos');
}

Future<void> _fixPrintInFile(File file) async {
  try {
    String content = await file.readAsString();
    bool modified = false;
    
    // Substituir print simples por debugPrint
    if (content.contains('print(')) {
      content = content.replaceAllMapped(
        RegExp(r'print\((.*?)\);'),
        (match) {
          modified = true;
          return 'debugPrint(${match.group(1)});';
        },
      );
    }
    
    // Adicionar import do Flutter se necessário
    if (modified && !content.contains('import \'package:flutter/foundation.dart\'')) {
      final lines = content.split('\n');
      int importIndex = 0;
      
      // Encontrar onde inserir o import
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('import ')) {
          importIndex = i + 1;
        } else if (lines[i].trim().isEmpty && importIndex > 0) {
          break;
        }
      }
      
      lines.insert(importIndex, 'import \'package:flutter/foundation.dart\';');
      content = lines.join('\n');
    }
    
    if (modified) {
      await file.writeAsString(content);
      print('  📝 Corrigido: ${file.path}');
    }
  } catch (e) {
    print('  ❌ Erro ao processar ${file.path}: $e');
  }
}

/// Cria configuração de ambiente
Future<void> createEnvironmentConfig() async {
  print('🔧 Criando configuração de ambiente...');
  
  // Criar diretório config se não existir
  final configDir = Directory('lib/config');
  if (!configDir.existsSync()) {
    await configDir.create(recursive: true);
  }
  
  // Criar app_config.dart
  final configFile = File('lib/config/app_config.dart');
  const configContent = '''
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configurações da aplicação carregadas de variáveis de ambiente
class AppConfig {
  /// Inicializa as configurações carregando o arquivo .env
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }
  
  /// API Key do Firebase
  static String get firebaseApiKey {
    final key = dotenv.env['FIREBASE_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('FIREBASE_API_KEY não configurada no arquivo .env');
    }
    return key;
  }
  
  /// ID do projeto Firebase
  static String get firebaseProjectId {
    final projectId = dotenv.env['FIREBASE_PROJECT_ID'];
    if (projectId == null || projectId.isEmpty) {
      throw Exception('FIREBASE_PROJECT_ID não configurada no arquivo .env');
    }
    return projectId;
  }
  
  /// App ID do Firebase para Web
  static String get firebaseWebAppId {
    final appId = dotenv.env['FIREBASE_WEB_APP_ID'];
    if (appId == null || appId.isEmpty) {
      throw Exception('FIREBASE_WEB_APP_ID não configurada no arquivo .env');
    }
    return appId;
  }
  
  /// App ID do Firebase para Android
  static String get firebaseAndroidAppId {
    final appId = dotenv.env['FIREBASE_ANDROID_APP_ID'];
    if (appId == null || appId.isEmpty) {
      throw Exception('FIREBASE_ANDROID_APP_ID não configurada no arquivo .env');
    }
    return appId;
  }
  
  /// Messaging Sender ID do Firebase
  static String get firebaseMessagingSenderId {
    final senderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'];
    if (senderId == null || senderId.isEmpty) {
      throw Exception('FIREBASE_MESSAGING_SENDER_ID não configurada no arquivo .env');
    }
    return senderId;
  }
  
  /// Storage Bucket do Firebase
  static String get firebaseStorageBucket {
    final bucket = dotenv.env['FIREBASE_STORAGE_BUCKET'];
    if (bucket == null || bucket.isEmpty) {
      throw Exception('FIREBASE_STORAGE_BUCKET não configurada no arquivo .env');
    }
    return bucket;
  }
  
  /// Auth Domain do Firebase
  static String get firebaseAuthDomain {
    final domain = dotenv.env['FIREBASE_AUTH_DOMAIN'];
    if (domain == null || domain.isEmpty) {
      throw Exception('FIREBASE_AUTH_DOMAIN não configurada no arquivo .env');
    }
    return domain;
  }
  
  /// Verifica se está em modo de desenvolvimento
  static bool get isDevelopment {
    return dotenv.env['ENVIRONMENT'] == 'development';
  }
  
  /// Verifica se está em modo de produção
  static bool get isProduction {
    return dotenv.env['ENVIRONMENT'] == 'production';
  }
}
''';
  
  await configFile.writeAsString(configContent);
  print('✅ Arquivo app_config.dart criado');
  
  // Atualizar .env.example
  final envExampleFile = File('.env.example');
  const envContent = '''
# Configurações do Firebase
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_PROJECT_ID=your_project_id_here
FIREBASE_WEB_APP_ID=your_web_app_id_here
FIREBASE_ANDROID_APP_ID=your_android_app_id_here
FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id_here
FIREBASE_STORAGE_BUCKET=your_storage_bucket_here
FIREBASE_AUTH_DOMAIN=your_auth_domain_here

# Ambiente (development, staging, production)
ENVIRONMENT=development
''';
  
  await envExampleFile.writeAsString(envContent);
  print('✅ Arquivo .env.example atualizado');
}

/// Atualiza analysis_options.yaml com regras mais rigorosas
Future<void> updateAnalysisOptions() async {
  print('📋 Atualizando analysis_options.yaml...');
  
  const analysisContent = '''
# This file configures the analyzer, which statically analyzes Dart code to
# check for errors, warnings, and lints.

include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Segurança
    avoid_print: true
    
    # Qualidade do código
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    prefer_final_fields: true
    prefer_final_locals: true
    unnecessary_late: true
    
    # Performance
    avoid_unnecessary_containers: true
    sized_box_for_whitespace: true
    use_build_context_synchronously: true
    
    # Legibilidade
    prefer_single_quotes: true
    require_trailing_commas: true
    sort_child_properties_last: true
    
    # Manutenibilidade
    avoid_empty_else: true
    avoid_returning_null_for_void: true
    cancel_subscriptions: true
    close_sinks: true
    
    # Documentação
    public_member_api_docs: false # Desabilitado por enquanto

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"
  
  errors:
    # Tratar alguns warnings como erros
    avoid_print: error
    use_build_context_synchronously: error
''';
  
  final analysisFile = File('analysis_options.yaml');
  await analysisFile.writeAsString(analysisContent);
  print('✅ analysis_options.yaml atualizado');
}

/// Cria utilitário de logging
Future<void> createLoggerUtility() async {
  print('📝 Criando utilitário de logging...');
  
  final utilsDir = Directory('lib/utils');
  if (!utilsDir.existsSync()) {
    await utilsDir.create(recursive: true);
  }
  
  const loggerContent = '''
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Utilitário para logging estruturado da aplicação
class Logger {
  static const String _defaultName = 'HabitAI';
  
  /// Log de debug - apenas em modo debug
  static void debug(String message, {String? name, Object? error}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? _defaultName,
        level: 500, // DEBUG level
        error: error,
      );
    }
  }
  
  /// Log de informação
  static void info(String message, {String? name}) {
    developer.log(
      message,
      name: name ?? _defaultName,
      level: 800, // INFO level
    );
  }
  
  /// Log de warning
  static void warning(String message, {String? name, Object? error}) {
    developer.log(
      message,
      name: name ?? _defaultName,
      level: 900, // WARNING level
      error: error,
    );
  }
  
  /// Log de erro
  static void error(String message, {String? name, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: name ?? _defaultName,
      level: 1000, // ERROR level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log de erro crítico
  static void critical(String message, {String? name, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: name ?? _defaultName,
      level: 1200, // CRITICAL level
      error: error,
      stackTrace: stackTrace,
    );
    
    // Em produção, enviar para serviço de monitoramento
    if (kReleaseMode) {
      _sendToCrashlytics(message, error, stackTrace);
    }
  }
  
  /// Envia erro crítico para serviço de monitoramento (implementar conforme necessário)
  static void _sendToCrashlytics(String message, Object? error, StackTrace? stackTrace) {
    // TODO: Implementar integração com Firebase Crashlytics ou Sentry
    debugPrint('CRITICAL ERROR: \$message');
  }
}
''';
  
  final loggerFile = File('lib/utils/logger.dart');
  await loggerFile.writeAsString(loggerContent);
  print('✅ Logger criado em lib/utils/logger.dart');
}

/// Cria handler de erros
Future<void> createErrorHandler() async {
  print('🚨 Criando handler de erros...');
  
  const errorHandlerContent = '''
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'logger.dart';

/// Handler centralizado para tratamento de erros da aplicação
class ErrorHandler {
  /// Inicializa o handler de erros global
  static void initialize() {
    // Capturar erros do Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      Logger.error(
        'Flutter Error: \${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
      );
      
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };
    
    // Capturar erros assíncronos
    PlatformDispatcher.instance.onError = (error, stack) {
      Logger.critical(
        'Uncaught Error: \$error',
        error: error,
        stackTrace: stack,
      );
      return true;
    };
  }
  
  /// Trata erro e exibe mensagem para o usuário
  static void handleError(
    BuildContext context,
    Object error, {
    StackTrace? stackTrace,
    String? userMessage,
  }) {
    Logger.error(
      'Error handled: \$error',
      error: error,
      stackTrace: stackTrace,
    );
    
    final message = userMessage ?? _getErrorMessage(error);
    showUserError(context, message);
  }
  
  /// Exibe erro para o usuário via SnackBar
  static void showUserError(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Exibe sucesso para o usuário
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Converte erro em mensagem amigável para o usuário
  static String _getErrorMessage(Object error) {
    if (error.toString().contains('network')) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    
    if (error.toString().contains('permission')) {
      return 'Permissão negada. Verifique as configurações.';
    }
    
    if (error.toString().contains('auth')) {
      return 'Erro de autenticação. Faça login novamente.';
    }
    
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}
''';
  
  final errorHandlerFile = File('lib/utils/error_handler.dart');
  await errorHandlerFile.writeAsString(errorHandlerContent);
  print('✅ ErrorHandler criado em lib/utils/error_handler.dart');
}