import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/screens/loading_screen.dart';
import 'package:myapp/screens/auth/login_screen.dart';

/// Register screen for user registration.
class RegisterScreen extends StatefulWidget {
  /// Constructor for RegisterScreen.
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _agreeToTerms = false; // Novo estado para o checkbox

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validates the form and registers the user.
  Future<void> _register() async {
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
      // Create user with email and password
      await context.authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      // Navigate to home screen (handled by auth state listener)
    } catch (e) {
      // Handle registration errors
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  /// Gets a user-friendly error message from the exception.
  String _getErrorMessage(dynamic e) {
    final message = e.toString();
    print('Erro completo: $message');

    if (message.contains('email-already-in-use')) {
      return 'An account already exists with this email address.';
    } else if (message.contains('invalid-email')) {
      return 'The email address is not valid.';
    } else if (message.contains('weak-password')) {
      return 'The password is too weak. Please use a stronger password.';
    } else if (message.contains('operation-not-allowed')) {
      return 'Email/password accounts are not enabled.';
    } else if (message.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (message.contains('firebase') && message.contains('firestore')) {
      // Erro relacionado ao Firestore não deve impedir criação da conta
      return 'Your account was created but some profile data may be incomplete. You can update your profile later.';
    } else if (message.contains('permission-denied')) {
      return 'Permission denied. Please try again or contact support.';
    } else if (message.contains('quota-exceeded')) {
      return 'Service temporarily unavailable. Please try again later.';
    } else if (message.contains('unavailable')) {
      return 'The service is currently unavailable. Please try again later.';
    } else if (message.contains('timeout')) {
      return 'The operation timed out. Please check your internet connection and try again.';
    } else if (message.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else {
      // Log detalhado para fins de depuração
      print('Erro não categorizado na criação da conta: $e');
      return 'An error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreenWithMessage(
        message: 'Creating your account...',
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.textColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Register title
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Register subtitle
                  Text(
                    'Sign up to start tracking your habits',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.errorColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Create a password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Terms and Conditions Checkbox
                  CheckboxListTile(
                    title: RichText(
                      text: TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(color: AppTheme.subtitleColor, fontSize: 14),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: TextStyle(color: AppTheme.primaryColor, decoration: TextDecoration.underline),
                            // recognizer: TapGestureRecognizer()..onTap = () {
                            //   // TODO: Navigate to Terms and Conditions screen/URL
                            //   print('Navigate to Terms and Conditions');
                            // },
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(color: AppTheme.primaryColor, decoration: TextDecoration.underline),
                            // recognizer: TapGestureRecognizer()..onTap = () {
                            //   // TODO: Navigate to Privacy Policy screen/URL
                            //   print('Navigate to Privacy Policy');
                            // },
                          ),
                        ],
                      ),
                    ),
                    value: _agreeToTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppTheme.primaryColor,
                    subtitle: !_agreeToTerms && (_formKey.currentState?.validate() == false || _errorMessage != null)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'You must agree to the terms to continue.',
                            style: TextStyle(color: AppTheme.errorColor, fontSize: 12),
                          ),
                        )
                      : null,
                  ),
                  const SizedBox(height: 24),

                  // Register button
                  ElevatedButton(
                    onPressed: _agreeToTerms ? _register : null, // Habilita o botão apenas se os termos forem aceitos
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _agreeToTerms ? AppTheme.primaryColor : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: AppTheme.subtitleColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
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
