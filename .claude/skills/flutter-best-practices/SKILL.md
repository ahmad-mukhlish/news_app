---
name: flutter-best-practices
description: Flutter & Dart widget coding conventions. Use when writing, reviewing, or refactoring Flutter widget code.
---

Review the current file (or selection) against the following Flutter/Dart best practices and fix any violations. Report what was changed and why.

---

## File Structure

**One file, one class (or one enum).**
Never declare more than one class or enum per file. This applies to widgets, data classes, typedefs, and enums — each gets its own file named after it.
```dart
// ✅ good — el_chat_action.dart contains only ElChatAction
class ElChatAction {
  const ElChatAction({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
}

// ❌ bad — two classes in one file
class ElChatAction { ... }
class ElChatBotBubble extends StatelessWidget { ... }
```

---

## Widget Structure

**Always break `build()` into smaller widget methods.**
Never write one large `build()` method. Extract each logical section into a private method
(e.g. `_buildLeadingIcon()`, `_buildClearButton()`, `_buildInput()`).
`build()` should read like a high-level layout description, not an implementation.

**Method order in a widget class:**
1. Fields
2. Lifecycle (`initState`, `dispose`)
3. `build()` — always first after lifecycle
4. `_buildX()` helpers — UI children of `build()`
5. Behaviour — callbacks (`_onX`) and computed getters

Widgets are primarily about UI. Layout is always visible at the top; behaviour is secondary and lives at the bottom.

**Never scatter `_buildX()` methods among `_onX()` methods.**
All widget builder methods must be grouped together immediately after `build()`. All callbacks and behaviour methods must be grouped together after the builders. Mixing them breaks the read order and makes the class harder to navigate.
```dart
// ✅ good — builders first, then behaviour
Widget build(BuildContext context) { ... }
Widget _buildHeader(BuildContext context) { ... }
Widget _buildFooter(BuildContext context) { ... }

void _onSubmit() { ... }
void _onCancel() { ... }

// ❌ bad — builder buried inside behaviour methods
Widget build(BuildContext context) { ... }
void _onSubmit() { ... }
Widget _buildHeader(BuildContext context) { ... }  // out of place
void _onCancel() { ... }
```

---

## Code Grouping

**Declare a variable on the line immediately before it is used.**
Never let unrelated statements come between a variable declaration and its consumer.
A variable and its single consumer are one logical unit — keep them visually together,
separated from other blocks by blank lines.
```dart
// ✅ good — isLast and its guard are one uninterrupted block
widgets.add(_buildActionButton(actions[i]));

final isLast = i == actions.length - 1;
if (isLast) continue;

widgets.add(const SizedBox(height: ElSpacing.s8));

// ❌ bad — widgets.add splits the declaration from its consumer
final isLast = i == actions.length - 1;
widgets.add(_buildActionButton(actions[i]));  // unrelated, breaks the group
if (isLast) continue;
```

---

## Dart Code Style

**Enums: no spaces inside curly braces.**
```dart
// ✅ good
enum ElButtonVariant {primary, secondary, destructive}

// ❌ bad
enum ElButtonVariant { primary, secondary, destructive }
```

**Assign nullable fields to a local variable before null-checking — never use the `!` operator.**

Applies to both `StatefulWidget` (`widget.x`) and `StatelessWidget` (`this.x`) fields.
```dart
// ✅ good — StatefulWidget
final label = widget.label;
if (label != null) _buildLabel(label);

// ✅ good — StatelessWidget
final label = this.label;
if (label != null) Text(label);

// ❌ bad
if (widget.label != null) _buildLabel(widget.label!);
if (label != null) Text(label!);
```
The local variable promotes the type to non-null, removing the need for `!`. Dart cannot flow-promote class fields directly because they are accessible from outside the method.

**Never use single-letter or abbreviated variable names.**
Every variable must have a descriptive name that explains what it holds. This is code, not algebra.
Single-letter names (`c`, `e`, `s`, `i`) and cryptic abbreviations (`usr`, `btn`, `mgr`) are forbidden
everywhere — local variables, pattern match bindings, loop variables, and parameters.
```dart
// ✅ good
if (userLocation case LocationCoordinate(coordinate: final coordinate)) return coordinate;
for (final station in stations) { ... }
final fetchCustomerProfile = _customerProfileRepository.getCustomerProfile();

// ❌ bad
if (userLocation case LocationCoordinate(coordinate: final c)) return c;
for (final s in stations) { ... }
final fcp = _customerProfileRepository.getCustomerProfile();
```

**Always declare the type explicitly on `final` variables — never leave the reader guessing.**
When the type is not immediately obvious from the right-hand side, write it on the left.
This applies to method calls, repository results, translated strings, and any expression
whose return type requires looking up another file to know.
```dart
// ✅ good — type is clear without reading the right-hand side
final SelfServiceBatteryStrings strings = t.self_service_battery;
final String label = _helpButtonLabelRepository.getLabels()[action] ?? '';
final List<Widget> items = [];

// ❌ bad — reader must trace the return type to know what this holds
final strings = t.self_service_battery;
final label = _helpButtonLabelRepository.getLabels()[action] ?? '';
final items = <Widget>[];
```
Exception: when the type is trivially obvious from the literal itself (`final name = 'Ahmad'`,
`final count = 0`), inference is fine.

**Named constants: class-level only when used in multiple places.**
If a value is only used once inside a single method, declare it as a local `final` variable
in that method. Only promote to a class-level `static const` when the value is referenced
in two or more places.
```dart
// ✅ good — used once, keep it local
Widget _buildBssCard(...) {
  final double bottomOffset = 130;
  ...
}

// ✅ good — used in multiple places, class-level const is justified
static const double _kBssCardBottomOffset = 130;
// used in _buildBssCard AND _buildSomethingElse

// ❌ bad — used only once but promoted to class-level
static const double _kBssCardBottomOffset = 130;
Widget _buildBssCard(...) {
  ... _kBssCardBottomOffset ... // only usage
}
```

**Omit curly braces for single-line `if` bodies.**
When the body of an `if` statement is a single expression, write it without curly braces on one line.
```dart
// ✅ good
if (refreshFromDetailButton) safeEmit(state.copyWith(isRefreshing: true));
if (message.isEmpty) return;

// ❌ bad
if (refreshFromDetailButton) {
  safeEmit(state.copyWith(isRefreshing: true));
}
```

**Extract complex boolean conditions into named variables.**
Multi-part conditions are hard to parse inline — a descriptive name makes the intent immediately clear.
```dart
// ✅ good
final isBackspace = event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace;
final isBoxEmptyAndNotFirst = controller.text.isEmpty && i > 0;
if (isBackspace && isBoxEmptyAndNotFirst) { ... }

// ❌ bad
if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace && controller.text.isEmpty && i > 0) { ... }
```

**Encapsulate logic into named methods for self-documenting code.**
Even a 2–3 line block benefits from a descriptive name — the method name replaces the need for a comment.
```dart
// ✅ good
void dispose() {
  _disposeControllers();
  _disposeFocusNodes();
  super.dispose();
}

// ❌ bad
void dispose() {
  for (final c in _controllers) { c.dispose(); }
  for (final n in _focusNodes) { n.removeListener(_onChange); n.dispose(); }
  super.dispose();
}
```

**Always DRY shared UI and behavior.**
Do not duplicate styling, layout rules, component dimensions, or action handling across widgets/screens.
If two places need the same UI treatment, extract a reusable widget, helper, or design-system component.
```dart
// ✅ good
ElChatActionButton(label: label, onPressed: onPressed)

// ❌ bad
OutlinedButton(
  style: OutlinedButton.styleFrom(...),
  child: Text(label),
)
```
Duplication is especially risky for design-system code because one future Figma tweak will drift across screens.

**Use arrow syntax for one-expression non-builder functions.**
When a non-builder method or getter only returns or executes a single expression, prefer `=>` over a block body.
Keep `_buildX()` widget builder methods as block bodies so UI layout remains easy to scan.
```dart
// ✅ good — non-builder one-liners
bool get _isBusy => state.isBusy;
void _onFocusChanged() => setState(() => _isFocused = focusNode.hasFocus);

// ✅ good — builder methods stay block-bodied
Widget _buildIcon() {
  return const Icon(Icons.close);
}

// ❌ bad — non-builder one-liner uses block body
bool get _isBusy {
  return state.isBusy;
}
```

**Prefer guard clauses over nested `if` / `else`.**
Return early when a condition finishes the method. This keeps the main path flat and avoids nested branches.
```dart
// ✅ good
void _showError(BuildContext context, String message) {
  if (message.isEmpty) return;

  ErrorSnackbar.show(context, message);
}

// ❌ bad
void _showError(BuildContext context, String message) {
  if (message.isNotEmpty) {
    ErrorSnackbar.show(context, message);
  }
}
```

**Prefer `for-each` over `for-i` loops.**
Use `for (final item in list)` whenever the index is not needed.
Only use `for (int i = 0; ...)` when the index itself is required (e.g. building indexed widgets or interleaving separators).

**Avoid `late` — initialize with a safe default instead.**
```dart
// ✅ good
List<TextEditingController> _controllers = [];

// ❌ risky — throws LateInitializationError if accessed before initState
late final List<TextEditingController> _controllers;
```
Flutter guarantees `initState` runs before `build`, so an empty list is a safe placeholder.

**Use the project's spacing class for spacing values if one is defined — never raw numbers in `SizedBox` or `EdgeInsets`.**
```dart
// ✅ good — using project spacing tokens
SizedBox(height: Spacing.s16)
Padding(padding: EdgeInsets.all(Spacing.s24))

// ❌ bad — magic numbers
SizedBox(height: 16)
Padding(padding: EdgeInsets.all(24))
```
Check the project for a spacing constants class (e.g. `ElSpacing`, `AppSpacing`, `Spacing`) before writing any numeric spacing value. Using tokens keeps spacing consistent with the design system and avoids magic numbers.

**Use design-system color tokens only.**
Do not use generated app colors, raw `Color(...)`, or Flutter `Colors.*` directly in feature/widget code. Use semantic color tokens first, then primitive palette tokens only when a semantic token does not exist.
```dart
// ✅ good
backgroundColor: AppColor.bgPrimary
color: AppColor.iconPrimary

// ❌ bad
backgroundColor: ColorName.secondary
color: Colors.black
color: const Color(0xFF101010)
```

**No magic numbers — extract numeric literals into named constants.**
Any number with a domain meaning (max length, item count, duration, etc.) must be a named `const` at the top of the file.
```dart
// ✅ good
const _maxPhoneNumberLength = 15;
const _passcodeLength = 6;

if (value.length <= _maxPhoneNumberLength) { ... }
if (value.length <= _passcodeLength) { ... }

// ❌ bad
if (value.length <= 15) { ... }
if (value.length <= 6) { ... }
```
The name explains *why* the number exists. A raw literal forces the reader to guess.

---

## After Implementation Checklist

**Always run `dart analyze lib/` after finishing any implementation and fix all reported issues before considering the work done.**

This includes:
- `error` — must fix, code will not compile or behave correctly
- `warning` — must fix, indicates likely bugs or bad practices
- `info` — must fix, includes `prefer_const_constructors`, `directives_ordering`, `eol_at_end_of_file`, `unused_local_variable`, and similar style violations

No issues should remain (excluding pre-existing `deprecated_member_use` on `withOpacity`, `groupValue`, and `onChanged` that belong to unrelated code).
