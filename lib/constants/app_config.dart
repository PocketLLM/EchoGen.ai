class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'ECHO_GEN_API_BASE',
    defaultValue: 'https://echo-gen-ai.vercel.app/api/v1',
  );

  static const Duration networkTimeout = Duration(seconds: 20);
}
