#!/usr/bin/env dart

import 'dart:io';

/// Script para validar se as correções foram aplicadas corretamente
/// Execute com: dart run scripts/validate_fixes.dart

void main() async {
  print('🔍 Validando correções aplicadas...\n');
  
  final results = <String, bool>{};
  
  results['API Keys Seguras'] = await validateApiKeySecurity();
  results['Sistema de Logging'] = await validateLoggingSystem();
  results['Configuração de Ambiente'] = await validateEnvironmentConfig();
  results['Analysis Options'] = await validateAnalysisOptions();
  results['Estrutura de Erros'] = await validateErrorHandling();
  results['Dependências'] = await validateDependencies();
  
  print('\n📊 Resumo da Validação:');
  print('=' * 50);
  
  int passed = 0;
  int total = results.length;
  
  results.forEach((test, result) {
    final status = result ? '✅' : '❌';
    print('$status $test');
    if (result) passed++;
  });
  
  print('=' * 50);
  print('📈 Score: $passed/$total (${(passed / total * 100).toStringAsFixed(1)}%)');
  
  if (passed == total) {
    print('🎉 Todas as validações passaram! Projeto pronto para revisão final.');
  } else {
    print('⚠️  Algumas validações falharam. Verifique os problemas acima.');
    exit(1);
  }
}

/// Valida se as API keys não estão mais hardcoded
Future<bool> validateApiKeySecurity() async {
  print('🔐 Validando segurança das API keys...');
  
  try {
    final mainFile = File('lib/main.dart');
    if (!mainFile.existsSync()) {
      print('  ❌ Arquivo main.dart não encontrado');
      return false;
    }
    
    final content = await mainFile.readAsString();
    
    // Verificar se ainda há API keys hardcoded
    final hasHardcodedKeys = content.contains('AIzaSy') || 
                            content.contains('apiKey:') && content.contains('\'');
    
    if (hasHardcodedKeys) {
      print('  ❌ API keys ainda estão hardcoded no main.dart');
      return false;
    }
    
    // Verificar se AppConfig está sendo usado
    final usesAppConfig = content.contains('AppConfig.');
    if (!usesAppConfig) {
      print('  ⚠️  AppConfig não está sendo usado no main.dart');
      return false;
    }
    
    print('  ✅ API keys estão seguras');
    return true;
  } catch (e) {
    print('  ❌ Erro ao validar API keys: $e');
    return false;
  }
}

/// Valida se o sistema de logging foi implementado
Future<bool> validateLoggingSystem() async {
  print('📝 Validando sistema de logging...');
  
  try {
    final loggerFile = File('lib/utils/logger.dart');
    if (!loggerFile.existsSync()) {
      print('  ❌ Arquivo logger.dart não encontrado');
      return false;
    }
    
    final content = await loggerFile.readAsString();
    
    // Verificar se contém os métodos essenciais
    final hasDebug = content.contains('static void debug');
    final hasError = content.contains('static void error');
    final hasInfo = content.contains('static void info');
    
    if (!hasDebug || !hasError || !hasInfo) {
      print('  ❌ Logger não contém todos os métodos necessários');
      return false;
    }
    
    // Verificar se print statements foram removidos do código principal
    final libDir = Directory('lib');
    int printCount = 0;
    
    await for (final file in libDir.list(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final fileContent = await file.readAsString();
        printCount += 'print('.allMatches(fileContent).length;
      }
    }
    
    if (printCount > 5) { // Permitir alguns prints em arquivos de debug
      print('  ⚠️  Ainda há muitos print statements ($printCount encontrados)');
      return false;
    }
    
    print('  ✅ Sistema de logging implementado');
    return true;
  } catch (e) {
    print('  ❌ Erro ao validar logging: $e');
    return false;
  }
}

/// Valida se a configuração de ambiente foi criada
Future<bool> validateEnvironmentConfig() async {
  print('⚙️  Validando configuração de ambiente...');
  
  try {
    final configFile = File('lib/config/app_config.dart');
    if (!configFile.existsSync()) {
      print('  ❌ Arquivo app_config.dart não encontrado');
      return false;
    }
    
    final envExampleFile = File('.env.example');
    if (!envExampleFile.existsSync()) {
      print('  ❌ Arquivo .env.example não encontrado');
      return false;
    }
    
    final configContent = await configFile.readAsString();
    
    // Verificar se contém as configurações essenciais
    final hasFirebaseConfig = configContent.contains('firebaseApiKey') &&
                             configContent.contains('firebaseProjectId');
    
    if (!hasFirebaseConfig) {
      print('  ❌ Configurações do Firebase não encontradas');
      return false;
    }
    
    print('  ✅ Configuração de ambiente criada');
    return true;
  } catch (e) {
    print('  ❌ Erro ao validar configuração: $e');
    return false;
  }
}

/// Valida se analysis_options.yaml foi atualizado
Future<bool> validateAnalysisOptions() async {
  print('📋 Validando analysis_options.yaml...');
  
  try {
    final analysisFile = File('analysis_options.yaml');
    if (!analysisFile.existsSync()) {
      print('  ❌ Arquivo analysis_options.yaml não encontrado');
      return false;
    }
    
    final content = await analysisFile.readAsString();
    
    // Verificar se contém regras importantes
    final hasAvoidPrint = content.contains('avoid_print: true');
    final hasPreferConst = content.contains('prefer_const_constructors');
    
    if (!hasAvoidPrint) {
      print('  ❌ Regra avoid_print não está configurada');
      return false;
    }
    
    if (!hasPreferConst) {
      print('  ⚠️  Regras de qualidade não estão completas');
    }
    
    print('  ✅ Analysis options configurado');
    return true;
  } catch (e) {
    print('  ❌ Erro ao validar analysis options: $e');
    return false;
  }
}

/// Valida se o tratamento de erros foi implementado
Future<bool> validateErrorHandling() async {
  print('🚨 Validando tratamento de erros...');
  
  try {
    final errorHandlerFile = File('lib/utils/error_handler.dart');
    if (!errorHandlerFile.existsSync()) {
      print('  ❌ Arquivo error_handler.dart não encontrado');
      return false;
    }
    
    final content = await errorHandlerFile.readAsString();
    
    // Verificar se contém métodos essenciais
    final hasHandleError = content.contains('static void handleError');
    final hasShowUserError = content.contains('static void showUserError');
    final hasInitialize = content.contains('static void initialize');
    
    if (!hasHandleError || !hasShowUserError || !hasInitialize) {
      print('  ❌ ErrorHandler não contém todos os métodos necessários');
      return false;
    }
    
    print('  ✅ Tratamento de erros implementado');
    return true;
  } catch (e) {
    print('  ❌ Erro ao validar error handling: $e');
    return false;
  }
}

/// Valida se as dependências necessárias estão no pubspec.yaml
Future<bool> validateDependencies() async {
  print('📦 Validando dependências...');
  
  try {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      print('  ❌ Arquivo pubspec.yaml não encontrado');
      return false;
    }
    
    final content = await pubspecFile.readAsString();
    
    // Verificar dependências essenciais
    final hasFlutterDotenv = content.contains('flutter_dotenv:');
    final hasFlutterLints = content.contains('flutter_lints:');
    
    if (!hasFlutterLints) {
      print('  ❌ flutter_lints não está configurado');
      return false;
    }
    
    if (!hasFlutterDotenv) {
      print('  ⚠️  flutter_dotenv não está adicionado (necessário para .env)');
      return false;
    }
    
    print('  ✅ Dependências validadas');
    return true;
  } catch (e) {
    print('  ❌ Erro ao validar dependências: $e');
    return false;
  }
}