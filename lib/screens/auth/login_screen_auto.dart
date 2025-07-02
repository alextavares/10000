import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/screens/loading_screen.dart';
import 'package:myapp/screens/auth/register_screen.dart';
import 'package:myapp/screens/auth/forgot_password_screen.dart';
import 'package:myapp/utils/logger.dart';

/// Login screen with automatic anonymous login for debugging.
class LoginScreenAuto extends StatefulWidget {
  /// Constructor for LoginScreenAuto.
  const LoginScreenAuto({super.key});

  @override
  State<LoginScreenAuto> createState() => _LoginScreenAutoState();
}

class _LoginScreenAutoState extends State<LoginScreenAuto> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _autoLoginAttempted = false;

  @override
  void initState() {
    super.initState();
    // Fazer login anônimo automaticamente após um pequeno delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptAutoLogin();
    });
  }

  /// Tenta fazer login anônimo automaticamente
  Future<void> _attemptAutoLogin() async {
    if (_autoLoginAttempted) return;
    
    setState(() {
      _autoLoginAttempted = true;
      _isLoading = true;
    });

    try {
      Logger.info('Tentando login anônimo automático...');
      final serviceProvider = ServiceProvider.of(context);
      await serviceProvider.authService.signInAnonymously();
      Logger.info('Login anônimo automático realizado com sucesso!');
      // O AuthWrapper vai detectar a mudança de estado e navegar automaticamente
    } catch (e) {
      Logger.error('Falha no login anônimo automático: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Falha no login automático. Você pode tentar fazer login manualmente.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates the form and signs in the user.
  Future<void> _signIn() async {
    // Clear any previous error messages
    setState(() {
      _errorMessage = null;
    });

    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in with email and password
      final serviceProvider = ServiceProvider.of(context);
      await serviceProvider.authService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      // Navigation is handled by AuthWrapper
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  /// Signs in anonymously for testing purposes.
  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serviceProvider = ServiceProvider.of(context);
      await serviceProvider.authService.signInAnonymously();
      // Navigation is handled by AuthWrapper
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  /// Gets a user-friendly error message from the exception.
  String _getErrorMessage(dynamic e) {
    final message = e.toString();
    if (message.contains('user-not-found')) {
      return 'No account found with this email address.';
    } else if (message.contains('wrong-password')) {
      return 'Incorrect password.';
    } else if (message.contains('invalid-email')) {
      return 'The email address is not valid.';
    } else if (message.contains('user-disabled')) {
      return 'This account has been disabled.';
    } else if (message.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Title
                  Icon(
                    Icons.track_changes,
                    size: 80,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'HabitAI',
                    textAlign: TextAlign.center,
                    style: AppTheme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Build better habits, one day at a time',
                    textAlign: TextAlign.center,
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Auto-login status
                  if (_autoLoginAttempted && !_isLoading)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _errorMessage == null ? AppTheme.primaryColor.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _errorMessage == null ? AppTheme.primaryColor : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _errorMessage ?? 'Tentativa de login automático concluída. Login manual disponível abaixo.',
                        style: TextStyle(
                          color: _errorMessage == null ? AppTheme.primaryColor : Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  if (_autoLoginAttempted && !_isLoading) const SizedBox(height: 24),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: AppTheme.inputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icons.email_outlined,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: AppTheme.inputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Sign in button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: AppTheme.primaryButton,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Sign In'),
                  ),
                  const SizedBox(height: 16),

                  // Anonymous sign in button
                  OutlinedButton(
                    onPressed: _isLoading ? null : _signInAnonymously,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                    child: const Text('Continue as Guest'),
                  ),
                  const SizedBox(height: 24),

                  // Forgot password
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
