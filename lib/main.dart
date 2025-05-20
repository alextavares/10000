import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/loading_screen.dart';
import 'package:myapp/screens/splash_screen.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:myapp/screens/main_navigation_screen.dart';
import 'package:myapp/screens/habit/add_habit_screen.dart';
import 'package:myapp/screens/onboarding/onboarding_screen.dart'; // Importar a tela de onboarding
import 'package:myapp/screens/home/home_screen.dart'; // Importar a HomeScreen
import 'package:myapp/services/service_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importar shared_preferences
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Portuguese
  await initializeDateFormatting('pt_BR', null);
  
  try {
    // Inicializar Firebase com configurações específicas para plataforma
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print("Firebase inicializado com sucesso!");
    
    // Inicializar Analytics se estiver disponível
    if (kIsWeb) {
      print("Executando na web - verificando Firebase Analytics");
      
      // Na web, vamos verificar se o Analytics está disponível através do JS
      // Este é um passo opcional, apenas para diagnóstico
      try {
        await Future.delayed(const Duration(seconds: 1)); // Pequeno atraso para garantir que scripts sejam carregados
        print("Firebase web está configurado corretamente");
      } catch (e) {
        print("Aviso: Firebase Analytics pode não estar disponível no web: $e");
        // Não falhe aqui, apenas registre o erro
      }
    }
  } catch (e) {
    print("Erro ao inicializar Firebase: $e");
    // Continuamos com o app mesmo se o Firebase falhar
    // O serviço AIService tem fallbacks para operar offline
  }
  
  // Inicie o app de qualquer forma
  runApp(await _buildApp());
}

Future<Widget> _buildApp() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

  return MyApp(onboardingCompleted: onboardingCompleted);
}

/// Configurações do Firebase para diferentes plataformas
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web options
      return const FirebaseOptions(
        apiKey: 'AIzaSyAayN2swkuxNZRV_htDIKc9CUjgcxQJK4M',
        appId: '1:258006613617:web:97dd7ccb386841785465d0',
        messagingSenderId: '258006613617',
        projectId: 'android-habitai',
        authDomain: 'android-habitai.firebaseapp.com',
        storageBucket: 'android-habitai.firebasestorage.app',
      );
    } else {
      // Android options - estas serão lidas do arquivo google-services.json
      return const FirebaseOptions(
        apiKey: 'AIzaSyAayN2swkuxNZRV_htDIKc9CUjgcxQJK4M',
        appId: '1:258006613617:android:97dd7ccb386841785465d0',
        messagingSenderId: '258006613617',
        projectId: 'android-habitai',
        storageBucket: 'android-habitai.firebasestorage.app',
      );
    }
  }
}

/// The main app widget.
class MyApp extends StatelessWidget {
  final bool onboardingCompleted;

  /// Constructor for MyApp.
  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return ServiceProvider.create(
      aiApiKey: 'AIzaSyAayN2swkuxNZRV_htDIKc9CUjgcxQJK4M', // Usando a API key do Firebase
      child: MaterialApp(
        title: 'HabitAI',
        theme: ThemeData(
          primaryColor: const Color(0xFFE91E63), // Pink color from screenshot
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.black,
            selectedItemColor: Color(0xFFE91E63),
            unselectedItemColor: Colors.grey,
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
        // Define a tela inicial baseada no status do onboarding
        home: onboardingCompleted
            ? const SplashScreen() // Se onboarding concluído, SplashScreen levará para AuthWrapper -> HomeScreen
            : const OnboardingScreen(), // Caso contrário, iniciar com Onboarding
        routes: {
          '/login': (context) => const LoginScreen(),
          // A rota '/home' agora pode ser a HomeScreen diretamente se o onboarding for pulado
          // ou a MainNavigationScreen se o usuário estiver logado.
          // A SplashScreen e AuthWrapper cuidarão da lógica de para onde ir após o login/onboarding.
          '/home': (context) => const HomeScreen(), // Rota para pular onboarding
          '/main': (context) => const MainNavigationScreen(), // Rota principal após login
          '/add-habit': (context) => const AddHabitScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/categories': (context) => const Scaffold(body: Center(child: Text('Categories Screen'))), // Placeholder
          '/timer': (context) => const Scaffold(body: Center(child: Text('Timer Screen'))), // Placeholder
          '/settings': (context) => const Scaffold(body: Center(child: Text('Settings Screen'))), // Placeholder
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
          // Se o usuário estiver logado, vá para MainNavigationScreen
          // A MainNavigationScreen será a tela principal após o login
          return const MainNavigationScreen(); 
        }
        
        // Se não estiver logado, vá para LoginScreen
        return const LoginScreen();
      },
    );
  }
}

// Modificar SplashScreen para verificar onboarding após a lógica de autenticação
// Se o onboarding não foi concluído, e o usuário não está logado,
// o fluxo normal levará para LoginScreen, que pode então levar para Onboarding.
// Se o onboarding foi concluído, e o usuário está logado, vai para MainNavigationScreen.
// Se o onboarding não foi concluído, mas o usuário se loga, o LoginScreen deveria
// redirecionar para o OnboardingBenefitsScreen.
// Esta lógica de redirecionamento pós-login para onboarding precisará ser
// implementada na LoginScreen ou no AuthWrapper.

// Por agora, a lógica em main() decide a tela inicial absoluta.
// A SplashScreen ainda levará para AuthWrapper, que então decide entre Login ou MainNavigation.
// Se o onboarding não foi feito, o usuário verá OnboardingBenefitsScreen primeiro.
// Se ele pular, vai para HomeScreen (que pode ser a mesma que MainNavigationScreen ou uma versão simplificada).
// Se ele completar o onboarding, a flag será salva, e na próxima vez, SplashScreen -> AuthWrapper -> MainNavigationScreen.
