import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class PreferencesManager {
  static const String _keyOnboardingShown = 'onboarding_shown';
  
  // Check if onboarding has been shown
  static Future<bool> isOnboardingShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyOnboardingShown) ?? false;
    } catch (e) {
      debugPrint('Error accessing SharedPreferences: $e');
      // Always return false if there's an error, to ensure onboarding is shown
      return false;
    }
  }
  
  // Set onboarding as shown
  static Future<void> setOnboardingShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboardingShown, true);
    } catch (e) {
      debugPrint('Error setting SharedPreferences: $e');
      // Silently fail - we'll just show onboarding again next time
    }
  }
  
  // Reset onboarding (for testing purposes)
  static Future<void> resetOnboardingShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboardingShown, false);
    } catch (e) {
      debugPrint('Error resetting SharedPreferences: $e');
    }
  }
} 