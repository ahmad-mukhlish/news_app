class AppConfig {
  // App branding
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Globe Daily',
  );

  // Light Mode Colors
  static const String primaryColor = String.fromEnvironment(
    'PRIMARY_COLOR',
    defaultValue: '0xFF0057FF',
  );

  static const String secondaryColor = String.fromEnvironment(
    'SECONDARY_COLOR',
    defaultValue: '0xFFFFB703',
  );


  // API Configuration
  static const String newsApiKey = String.fromEnvironment(
    'NEWS_API_KEY',
    defaultValue: 'e5b8d7516ad4439595ce42c4ce8477d3',
  );

  static const String newsApiBaseUrl = String.fromEnvironment(
    'NEWS_API_BASE_URL',
    defaultValue: 'https://newsapi.org/v2',
  );

  // App Configuration
  static const String packageName = String.fromEnvironment(
    'PACKAGE_NAME',
    defaultValue: 'com.globedaily.app',
  );

  // Lottie Animations
  static const String searchPageLottieAnimation = String.fromEnvironment(
    'SEARCH_PAGE_LOTTIE_ANIMATION',
    defaultValue:
        'https://lottie.host/dummy-animations/search.json',
  );

  static const String emptyNewsAnimation = String.fromEnvironment(
    'EMPTY_NEWS_ANIMATION',
    defaultValue:
        'https://lottie.host/dummy-animations/empty.json',
  );

  static const String errorAnimation = String.fromEnvironment(
    'ERROR_ANIMATION',
    defaultValue:
        'https://lottie.host/dummy-animations/error.json',
  );

  static const String comingSoonAnimation = String.fromEnvironment(
    'COMING_SOON_ANIMATION',
    defaultValue:
        'https://lottie.host/dummy-animations/coming-soon.json',
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
    defaultValue: '@mipmap/launcher_icon',
  );
}
