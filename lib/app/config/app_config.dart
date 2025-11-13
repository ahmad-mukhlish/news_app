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

  // Lottie Animations
  static const String searchPageLottieAnimation = String.fromEnvironment(
    'SEARCH_PAGE_LOTTIE_ANIMATION',
    defaultValue:
        '',
  );

  static const String emptyNewsAnimation = String.fromEnvironment(
    'EMPTY_NEWS_ANIMATION',
    defaultValue:
        '',
  );

  static const String errorAnimation = String.fromEnvironment(
    'ERROR_ANIMATION',
    defaultValue:
    '',
  );

  static const String comingSoonAnimation = String.fromEnvironment(
    'COMING_SOON_ANIMATION',
    defaultValue: '',
  );

  // Notification Configuration (for white-labeling)
  static const String notificationChannelId = String.fromEnvironment(
    'NOTIFICATION_CHANNEL_ID',
    defaultValue: 'news_app_high_importance_channel',
  );

  static const String notificationChannelName = String.fromEnvironment(
    'NOTIFICATION_CHANNEL_NAME',
    defaultValue: 'News App Alerts',
  );

  static const String notificationIcon = String.fromEnvironment(
    'NOTIFICATION_ICON',
    defaultValue: '@mipmap/ic_launcher',
  );
}
