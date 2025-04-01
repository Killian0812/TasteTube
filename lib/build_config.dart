class BuildConfig {
  static const String environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'vercel');
  static const String version =
      String.fromEnvironment('VERSION', defaultValue: '1.0.0');
}
