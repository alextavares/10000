import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Serviços específicos da plataforma
class PlatformServices {
  
  /// Detecta se está rodando no iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  /// Detecta se está rodando no Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  
  /// Detecta se está rodando na Web
  static bool get isWeb => kIsWeb;

  /// Configuração de login social baseada na plataforma
  static List<AuthProvider> getAvailableAuthProviders() {
    List<AuthProvider> providers = [];
    
    if (isIOS) {
      // iOS: Sign in with Apple é OBRIGATÓRIO como primeira opção
      providers.add(AuthProvider.apple);
      providers.add(AuthProvider.google);
      providers.add(AuthProvider.email);
    } else if (isAndroid) {
      // Android: Google Sign-In como primeira opção
      providers.add(AuthProvider.google);
      providers.add(AuthProvider.email);
      // Apple Sign-In também disponível no Android (opcional)
      providers.add(AuthProvider.apple);
    } else {
      // Web: Todas as opções disponíveis
      providers.add(AuthProvider.google);
      providers.add(AuthProvider.apple);
      providers.add(AuthProvider.email);
    }
    
    return providers;
  }

  /// Configuração de pagamentos baseada na plataforma
  static PaymentProvider getPaymentProvider() {
    if (isIOS) {
      return PaymentProvider.appStore;
    } else if (isAndroid) {
      return PaymentProvider.googlePlay;
    } else {
      return PaymentProvider.stripe; // Para web
    }
  }

  /// Verifica se precisa mostrar "Sign in with Apple" primeiro
  static bool shouldShowAppleSignInFirst() {
    return isIOS; // Obrigatório no iOS
  }

  /// Configurações específicas de cada plataforma
  static PlatformConfig getPlatformConfig() {
    return PlatformConfig(
      platform: getCurrentPlatform(),
      supportedAuth: getAvailableAuthProviders(),
      paymentProvider: getPaymentProvider(),
      analyticsProvider: isIOS ? AnalyticsProvider.appStore : AnalyticsProvider.firebase,
      pushProvider: isIOS ? PushProvider.apns : PushProvider.fcm,
    );
  }

  static PlatformType getCurrentPlatform() {
    if (isIOS) return PlatformType.ios;
    if (isAndroid) return PlatformType.android;
    return PlatformType.web;
  }
}

/// Tipos de plataforma
enum PlatformType { ios, android, web }

/// Provedores de autenticação
enum AuthProvider { apple, google, facebook, email }

/// Provedores de pagamento
enum PaymentProvider { appStore, googlePlay, stripe }

/// Provedores de analytics
enum AnalyticsProvider { firebase, appStore, playConsole }

/// Provedores de push notifications
enum PushProvider { apns, fcm }

/// Configuração da plataforma
class PlatformConfig {
  final PlatformType platform;
  final List<AuthProvider> supportedAuth;
  final PaymentProvider paymentProvider;
  final AnalyticsProvider analyticsProvider;
  final PushProvider pushProvider;

  PlatformConfig({
    required this.platform,
    required this.supportedAuth,
    required this.paymentProvider,
    required this.analyticsProvider,
    required this.pushProvider,
  });

  @override
  String toString() {
    return 'PlatformConfig(platform: $platform, auth: $supportedAuth, payment: $paymentProvider)';
  }
}
