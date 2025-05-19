import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// Splash screen shown when the app starts.
class SplashScreen extends StatefulWidget {
  /// Constructor for SplashScreen.
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // Navigate to next screen after delay
    Timer(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _navigateToNextScreen() {
    // Check if user is already logged in
    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      // User is logged in, navigate to home screen
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // User is not logged in, navigate to onboarding or login
      // For now, we'll navigate to login since onboarding is not implemented yet
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeInAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.psychology_alt,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // App name
                    Text(
                      'HabitAI',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tagline
                    Text(
                      'Transforme seus hábitos com IA',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.subtitleColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 60),
                    
                    // Loading indicator
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        strokeWidth: 4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
