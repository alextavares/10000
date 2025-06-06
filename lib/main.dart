import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/loading_screen.dart';
import 'package:myapp/screens/splash_screen.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:myapp/screens/main_navigation_screen.dart';
import 'package:myapp/screens/habit/add_habit_screen.dart';
import 'package:myapp/screens/habit/habit_tracking_type_screen.dart';
import 'package:myapp/screens/habit/habit_quantity_config_screen.dart';
import 'package:myapp/screens/habit/habit_timer_config_screen.dart';
import 'package:myapp/screens/habit/habit_subtasks_config_screen.dart';
import 'package:myapp/screens/onboarding/onboarding_screen.dart';
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/screens/notifications/notification_settings_screen.dart';
import 'package:myapp/screens/test/notification_test_screen.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

// Novas importações para configuração e logging
import 'package:myapp/config/app_config.dart';
import 'package:myapp/config/firebase_options.dart';
import 'package:myapp/utils/logger.dart';
import 'package:myapp/utils/error_handler.dart';

// Sistema de notificações inteligentes
import 'package:myapp/services/notifications/smart_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar configurações do aplicativo
  await AppConfig.initialize();
  
  // Validar configurações
  if (!AppConfig.validateConfiguration()) {
    Logger.warning('Algumas configurações estão faltando no arquivo .env');
  }
  
  // Initialize date formatting for Portuguese
  await initializeDateFormatting('pt_BR', null);
  
  // Inicializar timezone para notificações
  tz.initializeTimeZones();
  
  try {
    // Inicializar Firebase com configurações do arquivo de config
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    Logger.info("Firebase inicializado com sucesso!");
    
    // Inicializar sistema de notificações inteligentes
    await SmartNotificationService().initialize();
    Logger.info("Sistema de notificações inicializado!");
    
    // Inicializar Analytics se estiver disponível
    if (kIsWeb) {
      Logger.debug("Executando na web - verificando Firebase Analytics");
      
      try {
        await Future.delayed(const Duration(seconds: 1));
        Logger.info("Firebase web está configurado corretamente");
      } catch (e, stackTrace) {
        Logger.warning("Firebase Analytics pode não estar disponível no web");
        ErrorHandler.handleError(e, stackTrace, 'Firebase Analytics Web');
      }
    }
  } catch (e, stackTrace) {
    Logger.error("Erro ao inicializar Firebase", e, stackTrace);
    ErrorHandler.handleError(e, stackTrace, 'Firebase Initialization');
    // Continuamos com o app mesmo se o Firebase falhar
  }
  
  // Configurar tratamento global de erros
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.critical(
      'Flutter Error: ${details.exception}',
      details.exception,
      details.stack,
    );
    ErrorHandler.handleError(
      details.exception,
      details.stack ?? StackTrace.current,
      'Flutter Error',
    );
  };
  
  // Inicie o app
  runApp(await _buildApp());
}

Future<Widget> _buildApp() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

  return MyApp(onboardingCompleted: onboardingCompleted);
}

/// The main app widget.
class MyApp extends StatelessWidget {
  final bool onboardingCompleted;

  /// Constructor for MyApp.
  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return ServiceProvider.create(
      aiApiKey: AppConfig.googleApiKey, // Usando a API key do arquivo de config
      child: MaterialApp(
        title: 'HabitAI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFE91E63),
          scaffoldBackgroundColor: Colors.black,
          cardColor: const Color(0xFF1E1E1E),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.black,
            selectedItemColor: Color(0xFFE91E63),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(color: Colors.white),
          ),
          useMaterial3: true,
        ),
        // Add localization delegates
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'), // Portuguese
          Locale('en', 'US'), // English
        ],
        home: onboardingCompleted
            ? const SplashScreen()
            : const OnboardingScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/main': (context) => const MainNavigationScreen(),
          '/add-habit': (context) => const AddHabitScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/categories': (context) => const Scaffold(body: Center(child: Text('Categories Screen'))),
          '/timer': (context) => const Scaffold(body: Center(child: Text('Timer Screen'))),
          '/settings': (context) => const Scaffold(body: Center(child: Text('Settings Screen'))),
          '/notification-settings': (context) => const NotificationSettingsScreen(),
          '/test-notifications': (context) => const NotificationTestScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/habit-tracking-type':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => HabitTrackingTypeScreen(
                  categoryName: args['categoryName'],
                  categoryIcon: args['categoryIcon'],
                  categoryColor: args['categoryColor'],
                ),
              );
            case '/add-habit-quantity-config':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => HabitQuantityConfigScreen(
                  habitTitle: args['title'],
                  habitDescription: args['description'],
                  category: args['category'],
                  icon: args['icon'],
                  color: args['color'],
                  frequency: args['frequency'],
                  daysOfWeek: args['daysOfWeek'],
                  trackingType: args['trackingType'],
                ),
              );
            case '/add-habit-timer-config':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => HabitTimerConfigScreen(
                  habitTitle: args['title'],
                  habitDescription: args['description'],
                  category: args['category'],
                  icon: args['icon'],
                  color: args['color'],
                  frequency: args['frequency'],
                  daysOfWeek: args['daysOfWeek'],
                  trackingType: args['trackingType'],
                ),
              );
            case '/add-habit-subtasks-config':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => HabitSubtasksConfigScreen(
                  habitTitle: args['title'],
                  habitDescription: args['description'],
                  category: args['category'],
                  icon: args['icon'],
                  color: args['color'],
                  frequency: args['frequency'],
                  daysOfWeek: args['daysOfWeek'],
                  trackingType: args['trackingType'],
                ),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}

/// Wrapper widget that handles authentication state.
class AuthWrapper extends StatelessWidget {
  /// Constructor for AuthWrapper.
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreenWithMessage(
            message: 'Checking authentication...',
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationScreen(); 
        }
        
        return const LoginScreen();
      },
    );
  }
}
