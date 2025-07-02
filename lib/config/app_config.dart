import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/utils/logger.dart';

/// Classe de configuração do aplicativo
/// Gerencia todas as variáveis de ambiente e configurações
class AppConfig {
  static bool _isInitialized = false;
  
  // Firebase Configuration
  static String get firebaseApiKey => 
      _ensureInitialized()['FIREBASE_API_KEY'] ?? '';
  
  static String get firebaseProjectId => 
      _ensureInitialized()['FIREBASE_PROJECT_ID'] ?? 'android-habitai';
  
  static String get firebaseMessagingSenderId => 
      _ensureInitialized()['FIREBASE_MESSAGING_SENDER_ID'] ?? '258006613617';
  
  static String get firebaseAppId => 
      _ensureInitialized()['FIREBASE_APP_ID'] ?? '';
  
  static String get firebaseAuthDomain => 
      _ensureInitialized()['FIREBASE_AUTH_DOMAIN'] ?? 'android-habitai.firebaseapp.com';
  
  static String get firebaseStorageBucket => 
      _ensureInitialized()['FIREBASE_STORAGE_BUCKET'] ?? 'android-habitai.firebasestorage.app';
  
  // AI Configuration
  static String get googleApiKey => 
      _ensureInitialized()['GOOGLE_API_KEY'] ?? '';
  
  // App Configuration
  static bool get isDebugMode => 
      _ensureInitialized()['DEBUG_MODE'] == 'true';
  
  /// Garante que o dotenv foi inicializado antes de acessar
  static Map<String, String> _ensureInitialized() {
    if (!_isInitialized) {
      // Se ainda não foi inicializado, tenta carregar sincronamente
      try {
        dotenv.load(fileName: '.env');
        _isInitialized = true;
      } catch (e) {
        Logger.error('Erro ao carregar arquivo .env: $e');
      }
    }
    return dotenv.env;
  }
  
  /// Inicializa as configurações carregando o arquivo .env
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
    } catch (e) {
      Logger.error('Erro ao carregar arquivo .env: $e');
    }
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
