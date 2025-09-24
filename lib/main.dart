import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/screens/splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:echogenai/providers/auth_provider.dart';
import 'package:echogenai/providers/theme_provider.dart';
import 'package:echogenai/services/global_audio_manager.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:echogenai/services/audio_handler.dart';

void main() async {
  // Catch any errors that occur during app startup
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // In release mode, log errors but don't crash
      debugPrint('Error occurred: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    } else {
      // In debug mode, rethrow the error
      FlutterError.dumpErrorToConsole(details);
    }
  };

  try {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize providers
    final themeProvider = ThemeProvider();
    final authProvider = AuthProvider();
    await Future.wait([
      themeProvider.initialize(),
      authProvider.bootstrap(),
    ]);

    // Initialize audio session
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      print('Warning: Audio session initialization failed: $e');
    }

    // Initialize audio service
    late EchoGenAudioHandler audioHandler;
    try {
      audioHandler = await AudioService.init(
        builder: () => EchoGenAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.echogenai.channel.audio',
          androidNotificationChannelName: 'EchoGen.ai Audio',
          androidNotificationOngoing: true,
          androidShowNotificationBadge: true,
        ),
      );
    } catch (e) {
      print('Warning: Audio service initialization failed: $e');
      // Fallback to basic audio handler
      audioHandler = EchoGenAudioHandler();
    }

    // Initialize global audio manager
    try {
      await GlobalAudioManager.instance.init();
    } catch (e) {
      print('Warning: Audio manager initialization failed: $e');
    }

    // Run the app
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    // Run a minimal error app if initialization fails
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'EchoGen.ai',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}