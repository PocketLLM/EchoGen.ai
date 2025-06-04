import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/screens/home_screen.dart';
import 'package:echogenai/utils/preferences_manager.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _onNextPage() {
    if (_currentPage < _numPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  void _completeOnboarding() async {
    try {
      // Mark onboarding as shown
      await PreferencesManager.setOnboardingShown();
    } catch (e) {
      debugPrint('Error setting onboarding as shown: $e');
      // Continue anyway - we'll just show onboarding again next time
    }
    
    if (!mounted) return;
    
    // Navigate to home screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _OnboardingPage(
                backgroundColor: AppTheme.onboardingRed,
                title: 'Create podcasts with AI',
                description: 'Transform articles, audio uploads, or text prompts into professional podcasts',
                assetPath: 'lib/assets/mic_icon.png',
                isSvg: false,
              ),
              _OnboardingPage(
                backgroundColor: AppTheme.onboardingYellow,
                title: 'Your API keys, your control',
                description: 'Use your preferred AI services with your own API keys for full privacy',
                assetPath: 'lib/assets/api_keys.svg',
                isSvg: true,
              ),
              _OnboardingPage(
                backgroundColor: AppTheme.onboardingBlue,
                title: 'High-quality voice synthesis',
                description: 'Choose from a variety of natural-sounding voices for your podcast',
                assetPath: 'lib/assets/ai_voice.png',
                isSvg: false,
              ),
            ],
          ),
          
          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 50,
            child: Column(
              children: [
                // Page indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _numPages,
                  effect: WormEffect(
                    dotColor: Colors.white.withOpacity(0.5),
                    activeDotColor: Colors.white,
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 16,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Skip and Next buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      if (_currentPage < _numPages - 1)
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            'Skip',
                            style: AppTheme.buttonText.copyWith(color: Colors.white),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      
                      // Next/Get Started button
                      ElevatedButton(
                        onPressed: _onNextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _currentPage == 0 
                              ? AppTheme.onboardingRed 
                              : _currentPage == 1 
                                ? AppTheme.onboardingYellow 
                                : AppTheme.onboardingBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: const CircleBorder(),
                        ),
                        child: Icon(
                          _currentPage < _numPages - 1 ? Icons.arrow_forward : Icons.check,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Get Started button for last page
          if (_currentPage == _numPages - 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 120,
              child: Center(
                child: ElevatedButton(
                  onPressed: _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.onboardingBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: AppTheme.buttonText.copyWith(
                      color: AppTheme.onboardingBlue,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String description;
  final String assetPath;
  final bool isSvg;
  
  const _OnboardingPage({
    required this.backgroundColor,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.isSvg,
  });
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          // Title section (top 30% of screen)
          Container(
            height: screenHeight * 0.3,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo at the top
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      'EchoGen.ai',
                      style: AppTheme.headingLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Title
                  Text(
                    title,
                    style: AppTheme.headingMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Image section (middle 40% of screen)
          Container(
            height: screenHeight * 0.4,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: isSvg 
                ? SvgPicture.asset(
                    assetPath,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    assetPath,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
            ),
          ),
          
          // Description section (bottom 30% of screen)
          Container(
            height: screenHeight * 0.15,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Center(
              child: Text(
                description,
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 