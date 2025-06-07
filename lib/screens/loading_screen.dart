import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';

/// Loading screen shown while the app is initializing.
class LoadingScreen extends StatelessWidget {
  /// Constructor for LoadingScreen.
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.psychology_alt,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // App name
            Text(
              'HabitAI',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Smart Habit Tracking',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.subtitleColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Loading text
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading screen with a message.
class LoadingScreenWithMessage extends StatelessWidget {
  /// Message to display.
  final String message;

  /// Constructor for LoadingScreenWithMessage.
  const LoadingScreenWithMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading indicator
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Loading message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen shown when initialization fails.
class ErrorScreen extends StatelessWidget {
  /// Error message to display.
  final String message;

  /// Callback for retry button.
  final VoidCallback onRetry;

  /// Constructor for ErrorScreen.
  const ErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 24),
              
              // Error title
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Error message
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.subtitleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Retry button
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
