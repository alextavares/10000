import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/services/platform_services.dart';
import 'package:myapp/services/service_provider.dart';

/// Tela de login adaptativa para iOS e Android
class AdaptiveLoginScreen extends StatefulWidget {
  const AdaptiveLoginScreen({super.key});

  @override
  State<AdaptiveLoginScreen> createState() => _AdaptiveLoginScreenState();
}

class _AdaptiveLoginScreenState extends State<AdaptiveLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late PlatformConfig _platformConfig;

  @override
  void initState() {
    super.initState();
    _platformConfig = PlatformServices.getPlatformConfig();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Login com Apple (iOS obrigatório, Android opcional)
  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      // Implementar Sign in with Apple
      // iOS: Usar sign_in_with_apple package
      // Android: Também funciona com o mesmo package
      
      final serviceProvider = ServiceProvider.of(context);
      // await serviceProvider.authService.signInWithApple();
      
      // Simulação para exemplo
      await Future.delayed(const Duration(seconds: 1));
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro no login com Apple: $e';
        _isLoading = false;
      });
    }
  }

  /// Login com Google (Android prioritário, iOS secundário)
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final serviceProvider = ServiceProvider.of(context);
      await serviceProvider.authService.signInWithGoogle();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro no login com Google: $e';
        _isLoading = false;
      });
    }
  }

  /// Login com email/senha
  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Preencha email e senha');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final serviceProvider = ServiceProvider.of(context);
      await serviceProvider.authService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro no login: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Logo
              _buildLogo(),
              
              const SizedBox(height: 48),
              
              // Título
              Text(
                'Bem-vindo de volta',
                textAlign: TextAlign.center,
                style: AppTheme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Entre na sua conta para continuar',
                textAlign: TextAlign.center,
                style: AppTheme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Botões de login social (ordem baseada na plataforma)
              ..._buildSocialLoginButtons(),
              
              const SizedBox(height: 32),
              
              // Divisor "OU"
              _buildDivider(),
              
              const SizedBox(height: 32),
              
              // Campos de email e senha
              _buildEmailPasswordFields(),
              
              const SizedBox(height: 24),
              
              // Botão de login com email
              _buildEmailLoginButton(),
              
              const SizedBox(height: 16),
              
              // Erro
              if (_errorMessage != null) ...[
                _buildErrorMessage(),
                const SizedBox(height: 16),
              ],
              
              // Link para cadastro
              _buildSignUpLink(),
              
              const SizedBox(height: 32),
              
              // Informações sobre trial
              _buildTrialInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.track_changes,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  List<Widget> _buildSocialLoginButtons() {
    List<Widget> buttons = [];
    
    // iOS: Apple primeiro (obrigatório)
    if (PlatformServices.shouldShowAppleSignInFirst()) {
      buttons.add(_buildAppleSignInButton());
      buttons.add(const SizedBox(height: 16));
      
      // Google como segunda opção no iOS
      if (_platformConfig.supportedAuth.contains(AuthProvider.google)) {
        buttons.add(_buildGoogleSignInButton());
        buttons.add(const SizedBox(height: 16));
      }
    } else {
      // Android: Google primeiro
      if (_platformConfig.supportedAuth.contains(AuthProvider.google)) {
        buttons.add(_buildGoogleSignInButton());
        buttons.add(const SizedBox(height: 16));
      }
      
      // Apple como segunda opção no Android (opcional)
      if (_platformConfig.supportedAuth.contains(AuthProvider.apple)) {
        buttons.add(_buildAppleSignInButton());
        buttons.add(const SizedBox(height: 16));
      }
    }
    
    return buttons;
  }

  Widget _buildAppleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _signInWithApple,
        icon: const Icon(Icons.apple, color: Colors.white, size: 24),
        label: Text(
          PlatformServices.isIOS 
              ? 'Continuar com Apple'
              : 'Entrar com Apple',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _signInWithGoogle,
        icon: Image.asset(
          'assets/images/google_logo.png', // Adicionar logo do Google
          width: 24,
          height: 24,
        ),
        label: Text(
          PlatformServices.isAndroid 
              ? 'Continuar com Google'
              : 'Entrar com Google',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 0.5),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OU',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailPasswordFields() {
    return Column(
      children: [
        // Email
        TextFormField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.inputDecoration(
            labelText: 'Email',
            prefixIcon: Icons.email_outlined,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        
        const SizedBox(height: 16),
        
        // Password
        TextFormField(
          controller: _passwordController,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.inputDecoration(
            labelText: 'Senha',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _signInWithEmail(),
        ),
      ],
    );
  }

  Widget _buildEmailLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithEmail,
        style: AppTheme.primaryButtonStyle,
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Não tem uma conta? ',
          style: TextStyle(color: Colors.white70),
        ),
        TextButton(
          onPressed: () {
            // Navegar para tela de cadastro
            Navigator.pushNamed(context, '/register');
          },
          child: Text(
            'Criar conta',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrialInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            '7 dias grátis para novos usuários',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Experimente todos os recursos premium sem compromisso',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
