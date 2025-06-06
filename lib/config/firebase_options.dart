import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'app_config.dart';

/// Configurações do Firebase para diferentes plataformas
/// Usa as variáveis de ambiente ao invés de hardcoded values
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web options
      return FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey,
        appId: AppConfig.firebaseAppId.isNotEmpty 
            ? AppConfig.firebaseAppId 
            : '1:258006613617:web:97dd7ccb386841785465d0',
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        projectId: AppConfig.firebaseProjectId,
        authDomain: AppConfig.firebaseAuthDomain,
        storageBucket: AppConfig.firebaseStorageBucket,
      );
    } else {
      // Android options
      return FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey,
        appId: AppConfig.firebaseAppId.isNotEmpty 
            ? AppConfig.firebaseAppId 
            : '1:258006613617:android:97dd7ccb386841785465d0',
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        projectId: AppConfig.firebaseProjectId,
        storageBucket: AppConfig.firebaseStorageBucket,
      );
    }
  }
}
