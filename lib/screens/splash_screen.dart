import 'dart:async';
import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/screens/onboarding_screen.dart';
import 'package:echogenai/screens/home_screen.dart';
import 'package:echogenai/screens/auth/auth_flow_screen.dart';
import 'package:echogenai/screens/user_onboarding_screen.dart';
import 'package:echogenai/utils/preferences_manager.dart';
import 'package:echogenai/providers/auth_provider.dart';
import 'package:provider/provider.dart';

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
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Allow any final bootstrap updates to settle
    if (authProvider.status == AuthStatus.unknown) {
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (!mounted) return;

    final status = authProvider.status;

    if (status == AuthStatus.authenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }

    if (status == AuthStatus.onboardingRequired) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserOnboardingScreen()),
      );
      return;
    }

    bool onboardingShown = false;
    try {
      onboardingShown = await PreferencesManager.isOnboardingShown();
    } catch (e) {
      debugPrint('Error checking onboarding status: $e');
      onboardingShown = false;
    }

    if (!mounted) return;

    if (onboardingShown) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthFlowScreen()),
      );
    } else {
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