import 'package:flutter/material.dart';
import 'logger.dart';

/// Classe para tratamento centralizado de erros
class ErrorHandler {
  /// Trata erros genéricos do aplicativo
  static void handleError(Object error, StackTrace stackTrace, [String? context]) {
    Logger.error(
      'Erro capturado${context != null ? ' em $context' : ''}: $error',
      error,
      stackTrace,
    );
    
    // TODO: Integrar com serviço de monitoramento (Crashlytics, Sentry, etc)
  }
  
  /// Mostra erro amigável para o usuário
  static void showUserError(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: duration ?? const Duration(seconds: 3),
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
  
  /// Mostra mensagem de sucesso para o usuário
  static void showSuccess(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }
  
  /// Mostra mensagem de informação para o usuário
  static void showInfo(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue.shade700,
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }
  
  /// Trata erros de Firebase
  static String getFirebaseErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('user-not-found')) {
      return 'Usuário não encontrado';
    } else if (errorString.contains('wrong-password')) {
      return 'Senha incorreta';
    } else if (errorString.contains('email-already-in-use')) {
      return 'Este email já está em uso';
    } else if (errorString.contains('weak-password')) {
      return 'A senha é muito fraca';
    } else if (errorString.contains('invalid-email')) {
      return 'Email inválido';
    } else if (errorString.contains('network-request-failed')) {
      return 'Erro de conexão. Verifique sua internet';
    } else if (errorString.contains('too-many-requests')) {
      return 'Muitas tentativas. Tente novamente mais tarde';
    }
    
    return 'Ocorreu um erro. Tente novamente';
  }
  
  /// Wrapper para operações assíncronas com tratamento de erro
  static Future<T?> tryAsync<T>(
    Future<T> Function() operation, {
    required BuildContext context,
    String? errorMessage,
    bool showError = true,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      
      if (showError && context.mounted) {
        final message = errorMessage ?? getFirebaseErrorMessage(error);
        showUserError(context, message);
      }
      
      return null;
    }
  }
}
