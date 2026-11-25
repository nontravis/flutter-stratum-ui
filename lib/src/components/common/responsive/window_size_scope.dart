import 'package:flutter/widgets.dart';
import 'package:flutter_stratum_ui/src/components/common/model/widget_style.dart';
import 'package:flutter_stratum_ui/src/themes/constant/window_size.dart';

/// Publishes the [WindowSize] of the app window to its descendants.
///
/// Place it once near the root, e.g.
/// `MaterialApp(builder: (context, child) => WindowSizeScope(child: child!))`.
/// Dependents rebuild only when the window crosses a breakpoint, not on every
/// pixel of a window resize or when a phone rotates.
class WindowSizeScope extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  static WindowSize of(BuildContext context) {
    final windowSize = maybeOf(context);
    if (windowSize == null) {
      throw FlutterError(
        'No WindowSizeScope found in context.\n'
        'Wrap the app with WindowSizeScope, e.g. '
        'MaterialApp(builder: (context, child) => '
        'WindowSizeScope(child: child!)).',
      );
    }
    return windowSize;
  }

  /// The [WindowSize] of the nearest [WindowSizeScope], or null when none is
  /// above [context].
  ///
  /// Registers the same dependency as [of]: the caller rebuilds only when
  /// the window crosses a breakpoint.
  static WindowSize? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_WindowSizeInherited>()
      ?.windowSize;

  /// Whether a [WindowSizeScope] is above [context]; registers no
  /// dependency.
  static bool hasScope(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_WindowSizeInherited>() != null;

  @override
  Widget build(BuildContext context) => _WindowSizeInherited(
    windowSize: WindowSize.fromSize(MediaQuery.sizeOf(context)),
    child: child,
  );
}

/// Resolves a [WidgetStyle]'s `.at()` overrides for the window size that
/// the nearest [WindowSizeScope] publishes.
extension WindowSizeStyleExtension on WidgetStyle {
  /// This style resolved for the nearest [WindowSizeScope]'s size when it
  /// carries overrides, else this style itself.
  ///
  /// Call it before reading or rewriting any field: an override replaces a
  /// whole field, so a field read or copied from the unresolved style is
  /// wrong at every size an override sets. A style with no override reads
  /// no scope, so it registers no dependency and never throws; one with
  /// overrides depends on the scope, rebuilding [context] only when the
  /// window crosses a breakpoint, and throws [WindowSizeScope.of]'s error
  /// with none above.
  WidgetStyle resolvedIn(BuildContext context) =>
      hasWindowOverrides ? resolve(WindowSizeScope.of(context)) : this;
}

class _WindowSizeInherited extends InheritedWidget {
  const new({required this.windowSize, required super.child});

  final WindowSize windowSize;

  @override
  bool updateShouldNotify(_WindowSizeInherited oldWidget) =>
      windowSize != oldWidget.windowSize;
}
