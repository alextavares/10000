import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/screens/loading_screen.dart';

/// Forgot password screen for password reset.
class ForgotPasswordScreen extends StatefulWidget {
  /// Constructor for ForgotPasswordScreen.
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _resetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Validates the form and sends a password reset email.
  Future<void> _resetPassword() async {
    // Clear any previous error messages
    setState(() {
      _errorMessage = null;
    });

    // Validate the form only if it's currently visible
    // (i.e., if we are not already on the success screen)
    if (!_resetEmailSent) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Send password reset email
      await context.authService.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      // Show success message
      setState(() {
        _resetEmailSent = true;
        _isLoading = false;
      });
    } catch (e) {
      // Handle errors
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
      return 'No user found with this email address.';
    } else if (message.contains('invalid-email')) {
      return 'The email address is not valid.';
    } else if (message.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreenWithMessage(
        message: 'Sending password reset email...',
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
            child: _resetEmailSent
                ? _buildSuccessContent()
                : _buildResetForm(),
          ),
        ),
      ),
    );
  }

  /// Builds the reset password form.
  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reset password title
          Text(
            'Forgot Password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),

          // Reset password subtitle
          Text(
            'Enter your email address and we\'ll send you a link to reset your password',
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
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.errorColor.withValues(alpha: 0.3),
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

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: true,
            autocorrect: true,
            textCapitalization: TextCapitalization.none, // Email não precisa de capitalização
            
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
          const SizedBox(height: 24),

          // Reset password button
          ElevatedButton(
            onPressed: _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the success content after the reset email is sent.
  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        Icon(
          Icons.check_circle_outline,
          size: 64,
          color: AppTheme.successColor,
        ),
        const SizedBox(height: 24),

        // Success title
        Text(
          'Email Sent',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Success message
        Text(
          'We\'ve sent a password reset link to:\n${_emailController.text.trim()}',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.subtitleColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Instructions
        Text(
          'Please check your email and follow the instructions to reset your password.',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.subtitleColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Back to login button
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Back to Login',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Resend email button
        TextButton(
          onPressed: _resetPassword,
          child: Text(
            'Didn\'t receive the email? Send again',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
