import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Sistema de logging estruturado para o aplicativo
/// Substitui todos os print() statements por logs adequados
class Logger {
  static const String _defaultName = 'HabitAI';
  
  /// Log de debug - apenas em modo debug
  static void debug(String message, [String? name]) {
    if (kDebugMode) {
      developer.log(
        message, 
        name: name ?? _defaultName,
        level: 0,
      );
    }
  }
  
  /// Log de informação
  static void info(String message, [String? name]) {
    developer.log(
      message, 
      name: name ?? _defaultName,
      level: 800,
    );
  }
  
  /// Log de aviso
  static void warning(String message, [String? name]) {
    developer.log(
      message, 
      name: name ?? _defaultName,
      level: 900,
    );
  }
  
  /// Log de erro
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _defaultName,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log de erro crítico
  static void critical(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      'CRITICAL: $message',
      name: _defaultName,
      level: 1200,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log de analytics/eventos
  static void event(String eventName, [Map<String, dynamic>? parameters]) {
    if (kDebugMode) {
      developer.log(
        'Event: $eventName ${parameters != null ? '- Params: $parameters' : ''}',
        name: '${_defaultName}_Analytics',
        level: 500,
      );
    }
  }
  
  /// Log de performance
  static void performance(String operation, Duration duration) {
    if (kDebugMode) {
      developer.log(
        'Performance: $operation took ${duration.inMilliseconds}ms',
        name: '${_defaultName}_Performance',
        level: 600,
      );
    }
  }
}
