class AppConfig {
  // App branding
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'News App',
  );

  // Light Mode Colors
  static const String primaryColor = String.fromEnvironment(
    'PRIMARY_COLOR',
    defaultValue: '0xFF009688', // Teal
  );

  static const String secondaryColor = String.fromEnvironment(
    'SECONDARY_COLOR',
    defaultValue: '0xFFF5F5F5', // Grey 100
  );


  // API Configuration
  static const String newsApiKey = String.fromEnvironment(
    'NEWS_API_KEY',
    defaultValue: 'YOUR_API_KEY_HERE',
  );

  static const String newsApiBaseUrl = String.fromEnvironment(
    'NEWS_API_BASE_URL',
    defaultValue: 'https://newsapi.org/v2',
  );

  // App Configuration
  static const String packageName = String.fromEnvironment(
    'PACKAGE_NAME',
    defaultValue: 'com.dhealth.newsapp',
  );
}
