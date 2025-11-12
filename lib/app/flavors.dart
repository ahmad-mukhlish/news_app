enum Flavor {
  dev,
  prod,
}

class F {
  static Flavor? appFlavor;

  static String get name {
    switch (appFlavor) {
      case Flavor.dev:
        return 'DEV';
      case Flavor.prod:
        return 'PROD';
      default:
        return 'PROD';
    }
  }

  static String title(String appName) {
    switch (appFlavor) {
      case Flavor.dev:
        return '[DEV] $appName';
      case Flavor.prod:
        return appName;
      default:
        return appName;
    }
  }

  static bool get isDevMode {
    switch (appFlavor) {
      case Flavor.dev:
        return true;
      case Flavor.prod:
        return false;
      default:
        return false;
    }
  }

  static void updateFlavor(String flavor) {
    switch (flavor.toLowerCase()) {
      case 'dev':
        appFlavor = Flavor.dev;
        break;
      case 'prod':
        appFlavor = Flavor.prod;
        break;
      default:
        appFlavor = Flavor.prod;
    }
  }
}
