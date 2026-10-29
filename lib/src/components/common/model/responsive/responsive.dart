import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stratum_ui/src/themes/constant/window_size.dart';
import 'package:stratum_ui/src/themes/value_model.dart';

part 'generated/responsive.freezed.dart';

/// A value that may differ per [WindowSize] (FO-07 US-03 FR-01; responsive
/// s03 INV-4, INV-5), for a component prop a widget defaults to
/// `const Responsive(false, tablet: true)`.
///
/// [resolve] is mobile-first: the override of the largest window size at or
/// below the requested one wins, else [base], which holds below every
/// override. A theme token per window size resolves the same way but has no
/// base (FO-07 US-02 FR-01); a `WindowSize` order comparison stays out of
/// component code (FO-08 US-08 FR-02).
@valueModel
class Responsive<T> with _$Responsive<T> {
  const new(
    this.base, {
    this.watch,
    this.mobile,
    this.tablet,
    this.desktop,
    this.bigDesktop,
  });

  /// The value every window size without an override, and every window size
  /// below the smallest override, takes.
  final T base;

  /// The value a watch window takes instead of [base].
  final T? watch;

  /// The value a mobile window takes instead of [base] or [watch].
  final T? mobile;

  /// The value a tablet window takes instead of a smaller size's value.
  final T? tablet;

  /// The value a desktop window takes instead of a smaller size's value.
  final T? desktop;

  /// The value a big desktop window takes instead of a smaller size's value.
  final T? bigDesktop;

  /// The value for [size]: its own override when set, else the nearest
  /// smaller size's, else [base] (INV-5).
  T resolve(WindowSize size) => switch (size) {
    WindowSize.watch => watch ?? base,
    WindowSize.mobile => mobile ?? watch ?? base,
    WindowSize.tablet => tablet ?? mobile ?? watch ?? base,
    WindowSize.desktop => desktop ?? tablet ?? mobile ?? watch ?? base,
    WindowSize.bigDesktop =>
      bigDesktop ?? desktop ?? tablet ?? mobile ?? watch ?? base,
  };
}
