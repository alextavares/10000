import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart'; // Supondo que você tenha um AppTheme
import 'package:myapp/screens/onboarding/onboarding_ai_personalization_screen.dart';
// HomeScreen não será mais navegada diretamente daqui ao pular
// import 'package:myapp/screens/home/home_screen.dart'; 
import 'package:myapp/screens/splash_screen.dart'; // Importar SplashScreen
import 'package:shared_preferences/shared_preferences.dart'; 

class OnboardingBenefitsScreen extends StatelessWidget {
  const OnboardingBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Indicador de Progresso
              Text(
                'Etapa 1 de 3',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),

              // Placeholder para Imagem/Ilustração
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.emoji_events, // Ícone de placeholder
                    size: 120,
                    color: AppTheme.primaryColor, // Usando a cor primária do tema
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Título
              Text(
                'Descubra Seu Potencial Máximo!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor, // Usando a cor de texto do tema
                ),
              ),
              const SizedBox(height: 16),

              // Descrição dos Benefícios (Placeholder)
              Text(
                'Nosso app ajuda você a construir hábitos saudáveis, aumentar sua produtividade e alcançar seus objetivos com o poder da IA.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.subtitleColor, // Usando a cor de subtítulo do tema
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Botão Próximo (Placeholder para Subtarefa 3.2)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingAiPersonalizationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Próximo',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),

              // Botão Pular (Placeholder para Subtarefa 3.2)
              TextButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboardingCompleted', true);
                  if (context.mounted) {
                    // Navega para SplashScreen e remove todas as rotas anteriores
                    // SplashScreen então lidará com a lógica de AuthWrapper
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                      (Route<dynamic> route) => false, // Remove todas as rotas anteriores
                    );
                  }
                },
                child: Text(
                  'Pular',
                  style: TextStyle(
                    color: AppTheme.subtitleColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
