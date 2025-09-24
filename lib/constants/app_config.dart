class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'ECHO_GEN_API_BASE',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  static const Duration networkTimeout = Duration(seconds: 20);
}
