import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/services/genkit_service.dart'; // Importar GenkitService
import 'package:myapp/screens/onboarding/onboarding_ai_habit_suggestions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingAiPersonalizationScreen extends StatefulWidget {
  const OnboardingAiPersonalizationScreen({super.key});

  @override
  State<OnboardingAiPersonalizationScreen> createState() =>
      _OnboardingAiPersonalizationScreenState();
}

class _OnboardingAiPersonalizationScreenState
    extends State<OnboardingAiPersonalizationScreen> {
  final TextEditingController _answerController = TextEditingController();
  final GenkitService _genkitService = GenkitService(); // Instanciar GenkitService

  String _currentQuestion = "Carregando primeira pergunta...";
  bool _isLoading = true; // Começa carregando a primeira pergunta
  int _currentStep = 1; // Para gerenciar o fluxo de perguntas
  // Map<String, dynamic> _onboardingData = {}; // Para armazenar respostas, se necessário

  @override
  void initState() {
    super.initState();
    _loadFirstQuestion();
  }

  Future<void> _loadFirstQuestion() async {
    setState(() { _isLoading = true; });
    try {
      // O fluxo de onboarding do Genkit pode ser iniciado com um input vazio
      // ou um identificador especial para a primeira pergunta.
      // Usaremos uma string vazia como input inicial.
      final result = await _genkitService.processOnboardingAnswer(""); 
      setState(() {
        _currentQuestion = result['nextQuestion'] ?? "Como podemos te ajudar hoje?";
        // _onboardingData = result['extractedData'] ?? {}; // Se precisar armazenar dados extraídos
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentQuestion = "Erro ao carregar pergunta. Verifique sua conexão e tente novamente.";
        // Poderia adicionar um botão de tentar novamente aqui
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty && _currentStep > 0) { // Não valida input para a "primeira pergunta" se for um trigger
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira uma resposta.')),
      );
      return;
    }

    final answer = _answerController.text.trim();
    setState(() { _isLoading = true; });

    try {
      final result = await _genkitService.processOnboardingAnswer(answer);
      _answerController.clear();

      if (result['onboardingComplete'] == true) {
        // _onboardingData.addAll(result['extractedData'] ?? {});
        // print("Dados finais do onboarding: $_onboardingData");
        await _completeOnboarding();
      } else {
        setState(() {
          _currentQuestion = result['nextQuestion'] ?? "Obrigado! Próxima pergunta...";
          // _onboardingData.addAll(result['extractedData'] ?? {});
          _currentStep++;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        // Mantém a pergunta atual para o usuário tentar novamente
        // _currentQuestion = "Erro ao processar resposta. Tente novamente.";
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar resposta: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
    if (mounted) {
      // Decide para onde navegar: próxima tela de onboarding ou tela principal
      // Se houver uma tela de sugestão de hábitos (Tarefa 8)
      Navigator.of(context).pushReplacement(
         MaterialPageRoute(builder: (context) => const OnboardingAiHabitSuggestionsScreen()),
      );
      // Caso contrário, se esta for a última tela de onboarding:
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => const HomeScreen()), 
      //   (Route<dynamic> route) => false,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalização'),
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Etapa 2 de 3', 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),

              if (_isLoading && _currentQuestion == "Carregando primeira pergunta...")
                const Center(child: CircularProgressIndicator())
              else
                Text(
                  _currentQuestion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textColor,
                    height: 1.4,
                  ),
                ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _answerController,
                decoration: InputDecoration(
                  hintText: 'Sua resposta aqui...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                enabled: !_isLoading, // Desabilita enquanto carrega
              ),
              const SizedBox(height: 32),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Enviar Resposta',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
