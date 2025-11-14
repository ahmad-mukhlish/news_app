import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/helper/common_methods/url_methods.dart';
import 'package:url_launcher_platform_interface/link.dart' show LinkDelegate;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart' show UrlLauncherPlatform;

class _FakeUrlLauncherPlatform extends UrlLauncherPlatform {
  bool launchCalled = false;
  String? launchedUrl;
  bool? lastUseWebView;
  bool? lastUseSafariVC;
  bool? lastEnableJavaScript;
  bool? lastEnableDomStorage;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    launchCalled = true;
    launchedUrl = url;
    lastUseSafariVC = useSafariVC;
    lastUseWebView = useWebView;
    lastEnableJavaScript = enableJavaScript;
    lastEnableDomStorage = enableDomStorage;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeUrlLauncherPlatform fakePlatform;

  setUp(() {
    fakePlatform = _FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = fakePlatform;
  });

  test('openUrl delegates to url_launcher with in-app browser mode', () async {
    await openUrl('https://news.example.com/article');

    expect(fakePlatform.launchCalled, isTrue);
    expect(fakePlatform.launchedUrl, 'https://news.example.com/article');
    expect(fakePlatform.lastUseSafariVC, isTrue);
    expect(fakePlatform.lastUseWebView, isTrue);
    expect(fakePlatform.lastEnableJavaScript, isTrue);
    expect(fakePlatform.lastEnableDomStorage, isTrue);
  });
}
