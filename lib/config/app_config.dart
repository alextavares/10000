import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/utils/logger.dart';

/// Classe de configuração do aplicativo
/// Gerencia todas as variáveis de ambiente e configurações
class AppConfig {
  // Firebase Configuration
  static String get firebaseApiKey => 
      dotenv.env['FIREBASE_API_KEY'] ?? '';
  
  static String get firebaseProjectId => 
      dotenv.env['FIREBASE_PROJECT_ID'] ?? 'android-habitai';
  
  static String get firebaseMessagingSenderId => 
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '258006613617';
  
  static String get firebaseAppId => 
      dotenv.env['FIREBASE_APP_ID'] ?? '';
  
  static String get firebaseAuthDomain => 
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? 'android-habitai.firebaseapp.com';
  
  static String get firebaseStorageBucket => 
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'android-habitai.firebasestorage.app';
  
  // AI Configuration
  static String get googleApiKey => 
      dotenv.env['GOOGLE_API_KEY'] ?? '';
  
  // App Configuration
  static bool get isDebugMode => 
      dotenv.env['DEBUG_MODE'] == 'true';
  
  /// Inicializa as configurações carregando o arquivo .env
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }
  
  /// Valida se as configurações essenciais estão presentes
  static bool validateConfiguration() {
    if (firebaseApiKey.isEmpty) {
      Logger.warning('AVISO: Firebase API Key não configurada no .env');
      return false;
    }
    
    if (googleApiKey.isEmpty) {
      Logger.warning('AVISO: Google API Key não configurada no .env');
      // Não retorna false pois pode funcionar sem AI
    }
    
    return true;
  }
}
