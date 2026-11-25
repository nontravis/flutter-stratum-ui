import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:flutter_stratum_ui/src/components/common/model/image_blur_filter.dart';
import 'package:flutter_stratum_ui/src/themes/constant/window_size.dart';
import 'package:flutter_stratum_ui/src/themes/value_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/widget_style.freezed.dart';

@valueModel
class WidgetStyle with _$WidgetStyle {
  const new({
    this.opacity,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.alignment,
    this.border,
    this.borderRadius,
    this.backgroundColor,
    this.backgroundGradient,
    this.backgroundImage,
    this.backgroundBlur,
    this.foregroundColor,
    this.foregroundGradient,
    this.foregroundImage,
    this.foregroundBlur,
    this.clipBehavior,
    this.innerShadow,
    this.dropShadow,
    this.animationStyle,
    this.windowOverrides,
  });
  final double? opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Tight width. Min and max constraints win when they conflict, as in
  /// `Container`.
  final double? width;

  /// Tight height. Min and max constraints win when they conflict, as in
  /// `Container`.
  final double? height;
  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;

  /// Aligns the child inside the padded box.
  final AlignmentGeometry? alignment;
  final Border? border;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;

  final Gradient? backgroundGradient;
  final DecorationImage? backgroundImage;

  final ImageBlurFilter? backgroundBlur;

  /// Painted over the child, e.g. a hover or pressed tint.
  ///
  /// Unlike `ButtonStyle.foregroundColor`, this is not the text or icon color.
  final Color? foregroundColor;
  final Gradient? foregroundGradient;
  final DecorationImage? foregroundImage;

  /// Blurs the child itself, while [backgroundBlur] blurs what is behind it.
  final ImageBlurFilter? foregroundBlur;

  final List<BoxShadow>? innerShadow;
  final List<BoxShadow>? dropShadow;

  final Clip? clipBehavior;

  final AnimationStyle? animationStyle;

  /// One optional override per [WindowSize], set through [at].
  ///
  /// A component's `const` default style may carry them, so this is a
  /// constructor field; [at] is the call-site form. [resolve] layers each
  /// override over this value's own fields.
  final Map<WindowSize, WidgetStyle>? windowOverrides;

  /// Whether any window size carries an override.
  bool get hasWindowOverrides => windowOverrides?.isNotEmpty ?? false;

  /// Returns a copy with [watch], [mobile], [tablet], [desktop], and
  /// [bigDesktop] layered over the override this value already carries at
  /// that size.
  ///
  /// Every argument null returns this value unchanged, with no empty
  /// override map.
  WidgetStyle at({
    WidgetStyle? watch,
    WidgetStyle? mobile,
    WidgetStyle? tablet,
    WidgetStyle? desktop,
    WidgetStyle? bigDesktop,
  }) {
    if (watch == null &&
        mobile == null &&
        tablet == null &&
        desktop == null &&
        bigDesktop == null) {
      return this;
    }
    final added = <WindowSize, WidgetStyle>{
      WindowSize.watch: ?watch,
      WindowSize.mobile: ?mobile,
      WindowSize.tablet: ?tablet,
      WindowSize.desktop: ?desktop,
      WindowSize.bigDesktop: ?bigDesktop,
    };
    final existing = windowOverrides;
    if (existing == null) {
      return copyWith(windowOverrides: added);
    }
    return copyWith(
      windowOverrides: {
        ...existing,
        for (final entry in added.entries)
          entry.key: existing[entry.key]?.merge(entry.value) ?? entry.value,
      },
    );
  }

  /// Returns this value for [size] with every override at or below [size]
  /// layered on, smallest first (INV-11).
  ///
  /// A value with no override returns itself. Each override's null fields
  /// keep the value layered from smaller window sizes, per [merge].
  WidgetStyle resolve(WindowSize size) {
    final overrides = windowOverrides;
    if (overrides == null) return this;
    var resolved = copyWith(windowOverrides: null);
    for (final windowSize in WindowSize.values) {
      resolved = resolved.merge(overrides[windowSize]);
      if (windowSize == size) break;
    }
    return resolved;
  }

  /// Returns a copy where every non-null field of [other] replaces this one.
  ///
  /// A null field in [other] keeps this value, so null cannot clear a field.
  /// Pass an empty value instead: `[]` for shadows, `EdgeInsets.zero` for
  /// spacing, `AnimationStyle.noAnimation` for [animationStyle]. Lists are
  /// replaced whole, never concatenated.
  ///
  /// When either side carries [windowOverrides], the result's own fields are
  /// the two styles' own fields merged, and its override at each window size
  /// either side sets is `resolve(s).merge(other.resolve(s))`, a full
  /// snapshot, so resolving after a merge equals merging after a resolve
  /// (INV-12).
  WidgetStyle merge(WidgetStyle? other) {
    if (other == null) return this;
    Map<WindowSize, WidgetStyle>? mergedOverrides;
    if (hasWindowOverrides || other.hasWindowOverrides) {
      final sizes = {
        ...?windowOverrides?.keys,
        ...?other.windowOverrides?.keys,
      };
      mergedOverrides = {
        for (final size in WindowSize.values)
          if (sizes.contains(size))
            size: resolve(size).merge(other.resolve(size)),
      };
    }
    return WidgetStyle(
      opacity: other.opacity ?? opacity,
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      width: other.width ?? width,
      height: other.height ?? height,
      minWidth: other.minWidth ?? minWidth,
      maxWidth: other.maxWidth ?? maxWidth,
      minHeight: other.minHeight ?? minHeight,
      maxHeight: other.maxHeight ?? maxHeight,
      alignment: other.alignment ?? alignment,
      border: other.border ?? border,
      borderRadius: other.borderRadius ?? borderRadius,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      backgroundGradient: other.backgroundGradient ?? backgroundGradient,
      backgroundImage: other.backgroundImage ?? backgroundImage,
      backgroundBlur: other.backgroundBlur ?? backgroundBlur,
      foregroundColor: other.foregroundColor ?? foregroundColor,
      foregroundGradient: other.foregroundGradient ?? foregroundGradient,
      foregroundImage: other.foregroundImage ?? foregroundImage,
      foregroundBlur: other.foregroundBlur ?? foregroundBlur,
      clipBehavior: other.clipBehavior ?? clipBehavior,
      innerShadow: other.innerShadow ?? innerShadow,
      dropShadow: other.dropShadow ?? dropShadow,
      animationStyle: other.animationStyle ?? animationStyle,
      windowOverrides: mergedOverrides,
    );
  }

  /// Interpolates between two styles, for implicit animation.
  ///
  /// Takes styles already resolved for one window size ([resolve]); a style
  /// that still carries overrides loses them, which the debug assert flags.
  ///
  /// Returns [a] at `t == 0` and [b] at `t == 1`. A null style counts as
  /// `const WidgetStyle()`. A size switches at `t = 0.5` when one side is
  /// null, because null means unconstrained. [clipBehavior] switches at
  /// `t = 0.5`, and [animationStyle] always comes from [b]. Opacity,
  /// spacing, sizes, and blur are clamped to legal values, so a curve that
  /// overshoots cannot throw.
  static WidgetStyle? lerp(WidgetStyle? a, WidgetStyle? b, double t) {
    assert(
      !(a?.hasWindowOverrides ?? false) && !(b?.hasWindowOverrides ?? false),
      'WidgetStyle.lerp takes resolved styles; call resolve(WindowSize) first',
    );
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    final from = a ?? const WidgetStyle();
    final to = b ?? const WidgetStyle();
    return WidgetStyle(
      opacity: _lerpOpacity(from.opacity, to.opacity, t),
      padding: _lerpSpacing(from.padding, to.padding, t),
      margin: _lerpSpacing(from.margin, to.margin, t),
      width: _lerpSize(from.width, to.width, t),
      height: _lerpSize(from.height, to.height, t),
      minWidth: _lerpSize(from.minWidth, to.minWidth, t),
      maxWidth: _lerpSize(from.maxWidth, to.maxWidth, t),
      minHeight: _lerpSize(from.minHeight, to.minHeight, t),
      maxHeight: _lerpSize(from.maxHeight, to.maxHeight, t),
      alignment: AlignmentGeometry.lerp(from.alignment, to.alignment, t),
      border: Border.lerp(from.border, to.border, t),
      borderRadius: BorderRadiusGeometry.lerp(
        from.borderRadius,
        to.borderRadius,
        t,
      ),
      backgroundColor: Color.lerp(from.backgroundColor, to.backgroundColor, t),
      backgroundGradient: Gradient.lerp(
        from.backgroundGradient,
        to.backgroundGradient,
        t,
      ),
      backgroundImage: DecorationImage.lerp(
        from.backgroundImage,
        to.backgroundImage,
        t,
      ),
      backgroundBlur: ImageBlurFilter.lerp(
        from.backgroundBlur,
        to.backgroundBlur,
        t,
      ),
      foregroundColor: Color.lerp(from.foregroundColor, to.foregroundColor, t),
      foregroundGradient: Gradient.lerp(
        from.foregroundGradient,
        to.foregroundGradient,
        t,
      ),
      foregroundImage: DecorationImage.lerp(
        from.foregroundImage,
        to.foregroundImage,
        t,
      ),
      foregroundBlur: ImageBlurFilter.lerp(
        from.foregroundBlur,
        to.foregroundBlur,
        t,
      ),
      clipBehavior: t < 0.5 ? from.clipBehavior : to.clipBehavior,
      innerShadow: _lerpShadows(from.innerShadow, to.innerShadow, t),
      dropShadow: _lerpShadows(from.dropShadow, to.dropShadow, t),
      animationStyle: to.animationStyle,
    );
  }

  static double? _lerpOpacity(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    final value = lerpDouble(a ?? 1, b ?? 1, t)!;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }

  static EdgeInsetsGeometry? _lerpSpacing(
    EdgeInsetsGeometry? a,
    EdgeInsetsGeometry? b,
    double t,
  ) {
    final value = EdgeInsetsGeometry.lerp(a, b, t);
    if (value == null || value.isNonNegative) return value;
    return value.clamp(EdgeInsets.zero, EdgeInsetsGeometry.infinity);
  }

  static double? _lerpSize(double? a, double? b, double t) {
    if (a == null || b == null || !a.isFinite || !b.isFinite) {
      return t < 0.5 ? a : b;
    }
    final value = lerpDouble(a, b, t)!;
    return value < 0 ? 0 : value;
  }

  /// Like `BoxShadow.lerpList`, but a blur radius never goes below 0.
  ///
  /// `BoxShadow.lerpList` scales an unmatched shadow by `1 - t`, which is
  /// negative when a curve overshoots, and a negative blur radius fails the
  /// `Shadow` assertion.
  static List<BoxShadow>? _lerpShadows(
    List<BoxShadow>? a,
    List<BoxShadow>? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    final from = a ?? const <BoxShadow>[];
    final to = b ?? const <BoxShadow>[];
    final length = from.length > to.length ? from.length : to.length;
    return [
      for (var i = 0; i < length; i++)
        _lerpShadow(
          i < from.length ? from[i] : null,
          i < to.length ? to[i] : null,
          t,
        ),
    ];
  }

  /// An unmatched side counts as the other shadow scaled to nothing, as in
  /// `BoxShadow.lerpList`.
  static BoxShadow _lerpShadow(BoxShadow? a, BoxShadow? b, double t) {
    final from = a ?? b!.scale(0);
    final to = b ?? a!.scale(0);
    final blur = lerpDouble(from.blurRadius, to.blurRadius, t)!;
    return BoxShadow(
      color: Color.lerp(from.color, to.color, t)!,
      offset: Offset.lerp(from.offset, to.offset, t)!,
      blurRadius: blur < 0 ? 0 : blur,
      spreadRadius: lerpDouble(from.spreadRadius, to.spreadRadius, t)!,
      blurStyle: t < 0.5 ? from.blurStyle : to.blurStyle,
    );
  }
}
