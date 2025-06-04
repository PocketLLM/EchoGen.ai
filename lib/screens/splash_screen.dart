import 'dart:async';
import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/screens/onboarding_screen.dart';
import 'package:echogenai/screens/home_screen.dart';
import 'package:echogenai/utils/preferences_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
    
    // Navigate after splash duration
    _checkOnboardingStatus();
  }
  
  Future<void> _checkOnboardingStatus() async {
    // Wait for 2.5 seconds to show splash screen
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    
    bool onboardingShown = false;
    
    try {
      // Check if onboarding has been shown
      onboardingShown = await PreferencesManager.isOnboardingShown();
    } catch (e) {
      // If there's an error, default to showing onboarding
      debugPrint('Error checking onboarding status: $e');
      onboardingShown = false;
    }
    
    // Navigate to appropriate screen
    if (!mounted) return;
    
    if (onboardingShown) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Always navigate to onboarding screen if there's an error or onboarding hasn't been shown
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.purpleBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.white.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    'lib/assets/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image fails to load
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.mic,
                            size: 60,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // App name
              Text(
                'EchoGen.ai',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tagline
              Text(
                'Craft your voice with AI',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 