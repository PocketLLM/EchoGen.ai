import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/screens/splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:echogenai/providers/theme_provider.dart';

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

    // Initialize theme provider
    final themeProvider = ThemeProvider();
    await themeProvider.initialize();

    // Run the app
    runApp(
      ChangeNotifierProvider.value(
        value: themeProvider,
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