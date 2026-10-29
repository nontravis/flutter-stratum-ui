# Responsive

## Responsive values

- A component prop that changes from a window size up is a `Responsive<T>`, so a widget can default it to one:
  `const Responsive(false, tablet: true)`. `value.resolve(windowSize)` answers mobile-first: the override of the
  largest window size at or below the current one, else the base value, which holds below every override. Name only
  the window sizes that differ; the watch override stands beside the base. Never compare two `WindowSize` values by
  order in component code, and never branch on one with a catch-all arm: read the resolved value, or name every window
  size in a `switch`.

## Screen corner radius

- `context.deviceWindow.radius` is the screen's corner radii as a `BorderRadius?`: Android API 31+, iOS 26+, and
  macOS 27+ under a `StratumThemeApplication`; null everywhere else. Always pass a fallback:
  `context.deviceWindow.radius ?? BorderRadius.zero`. A reader rebuilds only when the radius changes. The app writes
  no setup code for it.

## Keyboard visibility

- `context.deviceWindow.isKeyboardVisible` is true while the OS of an Android or iOS device reports the on-screen
  keyboard shown, even while `keyboardHeight` reads 0, as it does inside a `Scaffold` body, Android's floating or
  split keyboard mode included. With a hardware keyboard it is false only while the OS hides the on-screen keyboard.
  On web, macOS, Windows, Linux, and in `flutter test` it is always false and asks the OS nothing. A reader rebuilds
  only on open or close. To get the screen area the keyboard covers, read `keyboardHeight`.
- Under `StratumThemeApplication`, and so under `StratumApplication`, the app writes no setup for the scope. An app
  with neither wraps itself: `MaterialApp(builder: (context, child) => KeyboardVisibilityScope(child: child!))`. A
  read with no scope throws "No KeyboardVisibilityScope found in context".
- Tests need no setup: under `flutter test` the scope reads false and opens no platform channel. To drive it, call
  `KeyboardVisibilityScope.setVisibleForTesting(true)`, then `await tester.pump()`. The value wins on every platform
  and holds across tests, so add `addTearDown(() => KeyboardVisibilityScope.setVisibleForTesting(false))`. Never
  import `flutter_keyboard_visibility`.
