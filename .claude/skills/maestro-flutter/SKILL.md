---
name: maestro-flutter
description: Provides integration between Maestro mobile testing framework and Flutter development. Helps with creating and organizing Maestro test flows using the entry point + runFlow pattern, managing common_tests folder for reusable flows, wrapping Flutter widgets with Semantics for testability, running tests, inspecting app UI hierarchy, managing devices, and automating mobile testing workflows. Essential for Flutter + Maestro integration.
---

# Maestro Flutter Integration

## What This Skill Does

This skill helps developers use Maestro, a mobile testing framework, with Flutter applications.

## When to Use This Skill

Use this skill when you need to:
- Write test automation for Flutter apps
- Organize Maestro test flows using the entry point + runFlow pattern
- Debug UI issues by inspecting the app hierarchy
- Set up or run Maestro test flows
- Extract common/recurring test logic to reusable flows
- Get help with Maestro documentation or best practices

## Prerequisites

### Maestro MCP Connection (REQUIRED)

**You MUST connect to Maestro MCP server to use this skill effectively.**

The Maestro MCP (Model Context Protocol) server provides essential tools for:
- Running Maestro flows
- Inspecting app hierarchy
- Taking screenshots
- Managing devices
- Querying Maestro documentation

#### How to Connect:

Use Claude Code's MCP integration to connect to the Maestro MCP server:

```bash
# Add Maestro MCP server
claude mcp add maestro

# Verify it's installed
claude mcp list
```

#### Available MCP Tools:

Once connected, you'll have access to:
- `mcp__maestro__run_flow` - Run Maestro test flows
- `mcp__maestro__inspect_view_hierarchy` - Inspect app UI structure
- `mcp__maestro__take_screenshot` - Capture app screenshots
- `mcp__maestro__launch_app` - Launch the app on device
- `mcp__maestro__list_devices` - List connected devices
- `mcp__maestro__query_docs` - Query Maestro documentation
- `mcp__maestro__cheat_sheet` - Get Maestro command reference

**Without the MCP connection, you won't be able to run tests or inspect app hierarchy!**

## CRITICAL REQUIREMENT: Widget Identification Pattern

**This is a deal breaker requirement for Maestro + Flutter integration:**

### In Flutter Code:
All testable widgets MUST be wrapped with `Semantics` widget and given a `label`:

```dart
Semantics(
  label: "News card",
  child: YourWidget(
    // widget content
  ),
)
```

**IMPORTANT NAMING CONVENTION**:
- First word should be capitalized
- Second and subsequent words should be lowercase
- Correct: `"News card"`, `"Login button"`, `"Article header"`
- Incorrect: `"News Card"`, `"login button"`, `"Article Header"`
- **This convention MUST be followed, otherwise Maestro won't recognize the widgets!**

### In Maestro Tests:
Reference the widget using `assertVisible` with the semantic label as a text pattern:

```yaml
- assertVisible:
    text: ".*News card.*"
```

**Without this pattern, Maestro cannot reliably identify Flutter widgets in tests.**

## Key Workflow

1. Identify the widget you want to test
2. Wrap it with `Semantics` and add a descriptive `label`
3. In your Maestro flow, use `assertVisible` with the label pattern
4. Run the test to verify the widget is detectable

---

## Why This Pattern Is Required

1. **Flutter's Widget Tree**: Flutter's rendering engine doesn't expose widget types directly to testing frameworks
2. **Accessibility First**: Semantics widgets are designed for accessibility, making them perfect for test automation
3. **Reliable Identification**: Text-based semantic labels are stable across builds and don't break with UI changes

---

## Test Organization Pattern (REQUIRED)

### Create an Entry Point with runFlow

Organize your Maestro tests using this pattern:

**Important:** The examples below show online/offline test organization. This is just one way to organize tests - the offline pattern is **OPTIONAL** and only needed if your app has offline features. Organize folders based on your app's needs (by feature, platform, priority, etc.).

#### 1. Entry Point File (`all-tests.yaml`)
Create a master flow that orchestrates all test suites:

```yaml
appId: com.example
---
# Master flow to run all tests
# Runs navigation regression, online tests, and offline tests

## Test 1: Navigation Regression (standalone so it can fail fast)
- runFlow: common_tests/navigation-test.yaml

# Test 2: Online Test Flow (All screen tests with network)
- runFlow: screen_tests_online/online_test_flow.yaml

## Test 3: Offline Test Flow (OPTIONAL - example of network-specific testing)
# Note: Offline testing is optional, only use if your app has offline features
- runFlow: screen_tests_offline/offline_test_flow.yaml
```

#### 2. Test Suite Flows
Organize related tests into suite files:

```yaml
appId: com.example
---
# Online Test Flow: Runs all screen tests that require internet connection

# Test 1: Home Screen
- runFlow: home-screen-test.yaml

# Test 2: Search Screen
- runFlow: search-screen-test.yaml

# Test 3: Categories Screen
- runFlow: categories-screen-test.yaml
```

#### 3. Screen-Specific Tests
Individual screen tests reference common flows:

```yaml
appId: com.example
---
# Home Screen Test

# Run setup flow
- runFlow: ../common_tests/setup-online.yaml

# Verify screen elements
- assertVisible: "News App"
- assertVisible:
    text: ".*News card.*"

# Run reusable test flow
- runFlow: ../common_tests/pagination-test.yaml
```

#### 4. Common Tests Folder
Extract recurring logic to `common_tests/`:

```
maestro/
├── all-tests.yaml                    # Entry point
├── config.yaml
├── common_tests/                     # Reusable flows (REQUIRED)
│   ├── setup-online.yaml
│   ├── setup-offline.yaml            # Optional: only if app has offline features
│   ├── navigation-test.yaml
│   ├── article-interaction-test.yaml
│   ├── pagination-test.yaml
│   └── pull-to-refresh-test.yaml
├── screen_tests_online/              # Screen-specific tests
│   ├── online_test_flow.yaml        # Suite orchestrator
│   ├── home-screen-test.yaml
│   ├── search-screen-test.yaml
│   └── categories-screen-test.yaml
└── screen_tests_offline/             # OPTIONAL: Only if app has offline features
    ├── offline_test_flow.yaml
    └── ...
```

**Note:** The `online`/`offline` folder separation is just an example. Organize your test folders based on your app's needs (e.g., by feature, by platform, by test type, etc.). The offline pattern is optional and only relevant if your app supports offline functionality.

### Benefits of This Pattern

1. **Modularity**: Reuse common test logic across multiple test files
2. **Maintainability**: Update shared logic in one place
3. **Fail Fast**: Run critical tests first (e.g., navigation) before running full suites
4. **Organization**: Separate concerns based on your app's needs (e.g., by feature, platform, or test type)
5. **Readability**: Clear hierarchy makes test structure easy to understand

**Note:** The online/offline separation shown above is just one example of how to organize tests. You can organize test folders however makes sense for your app (e.g., by feature modules, by user flows, by priority, etc.).

### Using runFlow Command

```yaml
# Relative path from current file
- runFlow: ../common_tests/setup-online.yaml

# Same directory
- runFlow: home-screen-test.yaml

# Subdirectory
- runFlow: screen_tests_online/online_test_flow.yaml
```

**ALWAYS use this pattern when creating Maestro test suites!**

---

## Examples

### Example 1: Making a Widget Testable

**Flutter Widget Code** (from `lib/app/helper/common_widgets/news_article_card.dart`):

```dart
@override
Widget build(BuildContext context) {
  return Semantics(
    label: "News card",  // This label makes it testable
    child: Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(children: [buildContent(context), buildOpenLinkIcon(context)]),
      ),
    ),
  );
}
```

**Corresponding Maestro Test** (from `maestro/common_tests/article-interaction-test.yaml`):

```yaml
# Verify news cards are visible
- assertVisible:
    text: ".*News card.*"
```

### Example 2: Pattern Matching Considerations

Use regex patterns with `.*` to match the semantic label:

```yaml
# Good - uses regex pattern
- assertVisible:
    text: ".*News card.*"

# Also valid - exact match (but less flexible)
- assertVisible:
    text: "News card"
```

### Example 3: Multiple Widget Testing

**Flutter Code:**
```dart
// Header widget
Semantics(
  label: "Article header",
  child: HeaderWidget(),
)

// Content widget
Semantics(
  label: "Article content",
  child: ContentWidget(),
)

// Footer widget
Semantics(
  label: "Article footer",
  child: FooterWidget(),
)
```

**Maestro Test Flow:**
```yaml
- assertVisible:
    text: ".*Article header.*"
- assertVisible:
    text: ".*Article content.*"
- assertVisible:
    text: ".*Article footer.*"
```

### Example 4: Interactive Elements

**Flutter Button with Semantics:**
```dart
Semantics(
  label: "Read more button",
  child: ElevatedButton(
    onPressed: onReadMore,
    child: Text("Read More"),
  ),
)
```

**Maestro Test with Interaction:**
```yaml
- assertVisible:
    text: ".*Read more button.*"
- tapOn:
    text: ".*Read more button.*"
```

---

## Command Reference

### Common Maestro Commands for Flutter

**Assertion Commands:**
```yaml
# Check if widget is visible
- assertVisible:
    text: ".*Widget label.*"

# Check if widget is NOT visible
- assertNotVisible:
    text: ".*Widget label.*"
```

**Interaction Commands:**
```yaml
# Tap on a widget
- tapOn:
    text: ".*Button label.*"

# Long press
- longPressOn:
    text: ".*Widget label.*"

# Scroll
- scrollUntilVisible:
    element:
      text: ".*Target widget.*"
```

---

## Best Practices

### 1. Follow the Naming Convention (CRITICAL)
**First word capitalized, rest lowercase** - This is mandatory for Maestro to work!

```dart
// Correct - First word capitalized, rest lowercase
Semantics(label: "Login button", child: LoginButton())
Semantics(label: "Email input field", child: EmailField())
Semantics(label: "Error message banner", child: ErrorBanner())
Semantics(label: "News card", child: NewsCard())

// Wrong - Will NOT work in Maestro
Semantics(label: "Login Button", child: LoginButton())  // ❌ Second word capitalized
Semantics(label: "email input field", child: EmailField())  // ❌ First word not capitalized
Semantics(label: "ERROR MESSAGE BANNER", child: ErrorBanner())  // ❌ All caps
```

### 2. Descriptive Semantic Labels
```dart
// Good - Clear and specific
Semantics(label: "Login button", child: LoginButton())
Semantics(label: "Email input field", child: EmailField())
Semantics(label: "Error message banner", child: ErrorBanner())

// Bad - Too vague
Semantics(label: "Button", child: LoginButton())
Semantics(label: "Field", child: EmailField())
```

### 3. Unique Labels Within a Screen
Ensure each testable widget has a unique label within its context:

```dart
// Good - Unique labels
Semantics(label: "Primary action button", ...)
Semantics(label: "Secondary action button", ...)

// Bad - Duplicate labels (hard to target specifically)
Semantics(label: "Button", ...)
Semantics(label: "Button", ...)
```

### 4. Use Regex Patterns in Tests
Always use `.*` wildcards for flexibility:

```yaml
# Recommended
- assertVisible:
    text: ".*News card.*"

# Works, but less flexible
- assertVisible:
    text: "News card"
```

### 5. Group Related Widgets
When testing complex components, add semantics at appropriate levels:

```dart
Semantics(
  label: "News article card",
  child: Card(
    child: Column(
      children: [
        // Individual elements don't need semantics
        // unless you need to test them independently
        Title(...),
        Body(...),
        Actions(...),
      ],
    ),
  ),
)
```

### 6. Test Across Widget States
Add semantic labels that reflect widget states:

```dart
Semantics(
  label: isLoading ? "Loading button" : "Submit button",
  child: Button(...),
)
```

---

## Troubleshooting

### MCP Connection Issues

**Problem**: Cannot run Maestro flows or access MCP tools

**Solutions**:
1. Verify Maestro MCP is installed:
   ```bash
   claude mcp list
   ```
2. Look for `maestro` in the list of installed MCP servers
3. If not installed, add it:
   ```bash
   claude mcp add maestro
   ```
4. Restart Claude Code after installing MCP servers
5. Check that Maestro CLI is installed on your system:
   ```bash
   maestro --version
   ```

**Checklist**:
- [ ] Maestro MCP server is installed (`claude mcp list`)
- [ ] Maestro CLI is installed on system
- [ ] Claude Code has been restarted after MCP installation
- [ ] Device/emulator is connected (`adb devices` or `maestro test`)

### Widget Not Found in Tests

**Problem**: `assertVisible` fails with "Element not found"

**Solutions**:
1. Verify the widget has a `Semantics` wrapper with a `label`
2. Check the label matches the test pattern
3. Use `maestro studio` to inspect the view hierarchy
4. Ensure the widget is actually rendered (check visibility, scroll position)

### Multiple Matches Found

**Problem**: Test finds multiple widgets with the same label

**Solutions**:
1. Make semantic labels more specific
2. Use additional selectors (index, parent context)
3. Restructure tests to target specific screen regions

### Semantics Not Working

**Problem**: Added Semantics but still can't find widget

**Checklist**:
- [ ] Semantics widget wraps the target widget
- [ ] `label` property is set (not `hint` or `value`)
- [ ] **Label follows naming convention: First word capitalized, rest lowercase** (e.g., "News card", not "News Card")
- [ ] Widget is actually rendered on screen
- [ ] No competing accessibility labels from child widgets
- [ ] Test uses correct text pattern matching (e.g., `".*News card.*"`)

---

## Additional Resources

### Essential Tools

- **Maestro Studio**: Use `maestro studio` to inspect Flutter app hierarchy in real-time
- **MCP Tools**: Access via Claude Code once Maestro MCP is connected:
  - `mcp__maestro__inspect_view_hierarchy` - See app structure
  - `mcp__maestro__take_screenshot` - Debug visual issues
  - `mcp__maestro__cheat_sheet` - Quick command reference
- **Check Devices**: Use `maestro test` or `adb devices` to verify device connection

### Documentation Links

- Maestro official docs: https://maestro.mobile.dev/
- Flutter Semantics widget: https://api.flutter.dev/flutter/widgets/Semantics-class.html
- Claude Code MCP guide: https://code.claude.com/docs/en/mcp-servers.md

### Quick Setup Commands

```bash
# Install Maestro MCP
claude mcp add maestro

# Verify installation
claude mcp list

# Check Maestro CLI
maestro --version

# Test device connection
adb devices  # For Android
# or
maestro test  # For any platform
```