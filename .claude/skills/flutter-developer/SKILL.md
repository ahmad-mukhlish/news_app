---
name: flutter-developer
description: Expert Flutter development assistance for building cross-platform mobile, web, and desktop applications. Use when working with Flutter projects, widgets, layouts, navigation, platform-specific code, or Flutter SDK features. Covers modern Flutter 3.x+ patterns, performance optimization, and best practices.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
---

# Flutter Developer Skill

Expert assistance for Flutter development covering modern patterns, architecture, and best practices.

## When to Use This Skill

- Building or modifying Flutter applications
- Creating custom widgets and layouts
- Implementing navigation and routing
- Working with Flutter animations
- Handling platform-specific functionality
- Optimizing Flutter app performance
- Setting up Flutter project structure
- Implementing responsive and adaptive designs
- Managing Flutter dependencies and packages

## Core Principles

### 1. Widget Composition
- Use one file for one widget, one class or one enum (separation of concerns)
- Prefer composition over inheritance
- Break complex widgets into smaller, reusable components
- Use const constructors whenever possible for performance
- Follow the single responsibility principle for widgets

### 2. Performance Best Practices
- Use const widgets to reduce rebuilds
- Implement RepaintBoundary for complex custom painters
- Use ListView.builder for long lists
- Profile with Flutter DevTools before optimizing

### 3. Clean Architecture
```
lib/
├── core/              # Core utilities, constants, extensions
├── features/          # Feature modules
│   └── feature_name/
│       ├── data/      # Data sources, repositories
│       ├── domain/    # Entities, use cases
│       └── presentation/  # UI, widgets, pages
├── shared/            # Shared widgets, utilities
└── main.dart
```

## Project-Specific Guidelines

### Required Packages & Usage

**IMPORTANT:** These are mandatory patterns for this project:

#### 1. HTTP Client - Dio (Required)
- **ALWAYS use Dio** for all API calls
- Never use http package directly for API requests
- Configure Dio with interceptors for logging, auth, error handling

```dart
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 3),
));

// Add interceptors
dio.interceptors.add(LogInterceptor(responseBody: true));

// Example API call
Future<User> fetchUser(String id) async {
  final response = await dio.get('/users/$id');
  return User.fromJson(response.data);
}
```

#### 2. Secure Storage - flutter_secure_storage (Required for sensitive data)
- **ALWAYS use flutter_secure_storage** for sensitive data
- Use for: auth tokens, API keys, passwords, personal information
- Never store sensitive data in SharedPreferences or Hive

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

// Store sensitive data
await storage.write(key: 'auth_token', value: token);
await storage.write(key: 'refresh_token', value: refreshToken);

// Retrieve sensitive data
final token = await storage.read(key: 'auth_token');

// Delete sensitive data
await storage.delete(key: 'auth_token');
```

#### 3. Code Generation - Freezed & Generators (Required)
- **ALWAYS use Freezed** for immutable data classes
- Use json_serializable for JSON serialization
- Run `flutter pub run build_runner build` after changes

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    String? avatarUrl,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// Usage
final user = User(id: '1', name: 'John', email: 'john@example.com');

// CopyWith
final updatedUser = user.copyWith(name: 'Jane');

// Equality (automatic)
print(user == updatedUser); // false
```

### Data Storage Decision Tree

```
Need to store data?
├─ Is it sensitive? (tokens, passwords, personal info)
│  ├─ YES → Use flutter_secure_storage
│  └─ NO → Continue
├─ Is it simple key-value? (settings, flags)
│  ├─ YES → Use SharedPreferences (only for non-sensitive)
│  └─ NO → Continue
```


## Common Patterns

### Widget Structure

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({
    super.key,
    required this.title,
    this.onTap,
  });

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}
```
### Navigation with GoRouter
```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'details/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DetailsPage(id: id);
          },
        ),
      ],
    ),
  ],
);
```

### Theme Configuration
```dart
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontSize: 16),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }
}
```

## File Organization

### Feature Module Example
```
features/authentication/
├── data/
│   ├── datasources/
│   │   ├── auth_local_datasource.dart
│   │   └── auth_remote_datasource.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── login.dart
│       └── logout.dart
└── presentation/
    ├── pages/
    │   ├── login_page.dart
    │   └── register_page.dart
    └── widgets/
        ├── login_form.dart
        └── password_field.dart
```

## Common Tasks

### Adding Dependencies
```bash
# Add package
flutter pub add package_name

# Add dev dependency
flutter pub add --dev package_name

# Update dependencies
flutter pub upgrade
```

### Platform-Specific Code
```dart
import 'dart:io' show Platform;

if (kIsWeb) {
  // Web specific code
} else if (Platform.isAndroid) {
  // Android-specific code
}
```

### Using Platform Channels
```dart
class PlatformService {
  static const platform = MethodChannel('com.example.app/channel');

  Future<String> getPlatformVersion() async {
    try {
      final version = await platform.invokeMethod<String>('getPlatformVersion');
      return version ?? 'Unknown';
    } on PlatformException catch (e) {
      return 'Failed to get platform version: ${e.message}';
    }
  }
}
```


## Performance Optimization


### Const Constructors
```dart
// Good: Const constructor allows const instances
class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

// Usage with const
const MyWidget(text: 'Hello')  // More efficient
```

### Lazy Loading
```dart
// Use ListView.builder instead of ListView
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)
```

## Common Issues and Solutions

### Issue: Unbounded Height/Width
**Solution:** Wrap in Expanded, Flexible, or provide constraints
```dart
Column(
  children: [
    Expanded(  // Provides bounds
      child: ListView(...),
    ),
  ],
)
```

### Issue: RenderFlex Overflow
**Solution:** Use SingleChildScrollView or adjust layout
```dart
SingleChildScrollView(
  child: Column(
    children: [...],
  ),
)
```

### Issue: setState Called After Dispose
**Solution:** Check if mounted before setState
```dart
if (mounted) {
  setState(() {
    // Update state
  });
}
```

## Flutter Commands Reference

```bash
# Create new project
flutter create my_app

# Run app
flutter run

# Run on specific device
flutter run -d chrome
flutter run -d macos

# Build release
flutter build apk
flutter build ipa
flutter build web

# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
dart format lib/

# Clean build
flutter clean

# Doctor check
flutter doctor -v
```

## Best Practices Checklist

- [ ] Use const constructors for immutable widgets
- [ ] Separate business logic from UI
- [ ] Implement proper error handling
- [ ] Follow Flutter style guide
- [ ] Use meaningful variable and class names
- [ ] Document complex widgets and logic
- [ ] Handle loading and error states
- [ ] Optimize images and assets
- [ ] Use appropriate state management
- [ ] Implement responsive layouts
- [ ] Test on multiple screen sizes
- [ ] Profile performance before optimizing

## Resources

- **Official Docs:** https://docs.flutter.dev
- **Widget Catalog:** https://docs.flutter.dev/ui/widgets
- **Cookbook:** https://docs.flutter.dev/cookbook
- **API Reference:** https://api.flutter.dev
- **Performance Best Practices:** https://docs.flutter.dev/perf/best-practices

## Notes

This skill provides Flutter-agnostic guidance. For state management specifics, use the dedicated Riverpod or Bloc skills. This skill focuses on Flutter SDK features, widget composition, layout, navigation, and platform integration.
