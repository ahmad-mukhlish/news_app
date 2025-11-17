class AppConfig {
  // App branding
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'News Flash',
  );

  // Light Mode Colors
  static const String primaryColor = String.fromEnvironment(
    'PRIMARY_COLOR',
    defaultValue: '0xFFE9465F',
  );

  static const String secondaryColor = String.fromEnvironment(
    'SECONDARY_COLOR',
    defaultValue: '0xFFFFC27A',
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
    defaultValue: 'com.newsflash.app',
  );

  // Lottie Animations
  static const String searchPageLottieAnimation = String.fromEnvironment(
    'SEARCH_PAGE_LOTTIE_ANIMATION',
    defaultValue:
        'https://lottie.host/86d422f5-aba6-4895-bf80-9275bd2aeba9/A5bf8ZuQSb.json',
  );

  static const String emptyNewsAnimation = String.fromEnvironment(
    'EMPTY_NEWS_ANIMATION',
    defaultValue:
        'https://assets-v2.lottiefiles.com/a/f0ca603e-c41e-11ee-beca-2ffe24a94aa6/SoXs4DE0l1.json',
  );

  static const String errorAnimation = String.fromEnvironment(
    'ERROR_ANIMATION',
    defaultValue:
        'https://lottie.host/6a661c33-4295-4d80-8a7f-f0e81e97e5c1/bjgiyg3N21.json',
  );

  static const String comingSoonAnimation = String.fromEnvironment(
    'COMING_SOON_ANIMATION',
    defaultValue:
        'https://lottie.host/0b5a90ef-2d98-4735-b800-0d2dfea5140f/0FgSQHGFNk.json',
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
