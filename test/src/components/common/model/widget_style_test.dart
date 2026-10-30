import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stratum_ui/src/components/common/model/image_blur_filter.dart';
import 'package:stratum_ui/src/components/common/model/widget_style.dart';
import 'package:stratum_ui/src/themes/constant/window_size.dart';

void main() {
  const base = WidgetStyle(
    padding: EdgeInsets.all(8),
    borderRadius: BorderRadius.all(Radius.circular(4)),
    backgroundColor: Color(0xFF000000),
    backgroundBlur: ImageBlurFilter(sigmaX: 4, sigmaY: 4),
    dropShadow: [BoxShadow(blurRadius: 2)],
  );

  group('equals', () {
    test('fo05/us01/fr01: two instances built with equal field values compare '
        '== and share hashCode; the style holds every visual field (fill, '
        'border, radius, shadow, blur, padding, animation) as one immutable '
        'value', () {
      final build = base.copyWith(
        border: const Border.fromBorderSide(BorderSide(width: 2)),
        animationStyle: const AnimationStyle(
          duration: Duration(milliseconds: 100),
        ),
      );
      final sameValues = base.copyWith(
        border: const Border.fromBorderSide(BorderSide(width: 2)),
        animationStyle: const AnimationStyle(
          duration: Duration(milliseconds: 100),
        ),
      );
      final unequal = base.copyWith(
        border: const Border.fromBorderSide(BorderSide(width: 3)),
      );

      expect(identical(build, sameValues), isFalse);
      expect(build, sameValues);
      expect(build.hashCode, sameValues.hashCode);
      expect(build, isNot(unequal));
    });
  });

  group('copyWith(field: null)', () {
    const full = WidgetStyle(
      opacity: 0.5,
      width: 100,
      height: 200,
      minWidth: 10,
      maxWidth: 300,
      minHeight: 20,
      maxHeight: 400,
    );

    test('5.3: copyWith(opacity: null) clears opacity and keeps the rest', () {
      final cleared = full.copyWith(opacity: null);

      expect(cleared.opacity, isNull);
      expect(
        cleared,
        const WidgetStyle(
          width: 100,
          height: 200,
          minWidth: 10,
          maxWidth: 300,
          minHeight: 20,
          maxHeight: 400,
        ),
      );
    });

    test('5.3: copyWith(width: null) clears width and keeps the rest', () {
      final cleared = full.copyWith(width: null);

      expect(cleared.width, isNull);
      expect(
        cleared,
        const WidgetStyle(
          opacity: 0.5,
          height: 200,
          minWidth: 10,
          maxWidth: 300,
          minHeight: 20,
          maxHeight: 400,
        ),
      );
    });

    test('5.3: copyWith(height: null) clears height and keeps the rest', () {
      final cleared = full.copyWith(height: null);

      expect(cleared.height, isNull);
      expect(
        cleared,
        const WidgetStyle(
          opacity: 0.5,
          width: 100,
          minWidth: 10,
          maxWidth: 300,
          minHeight: 20,
          maxHeight: 400,
        ),
      );
    });

    test(
      '5.3: copyWith(minWidth: null) clears minWidth and keeps the rest',
      () {
        final cleared = full.copyWith(minWidth: null);

        expect(cleared.minWidth, isNull);
        expect(
          cleared,
          const WidgetStyle(
            opacity: 0.5,
            width: 100,
            height: 200,
            maxWidth: 300,
            minHeight: 20,
            maxHeight: 400,
          ),
        );
      },
    );

    test(
      '5.3: copyWith(maxWidth: null) clears maxWidth and keeps the rest',
      () {
        final cleared = full.copyWith(maxWidth: null);

        expect(cleared.maxWidth, isNull);
        expect(
          cleared,
          const WidgetStyle(
            opacity: 0.5,
            width: 100,
            height: 200,
            minWidth: 10,
            minHeight: 20,
            maxHeight: 400,
          ),
        );
      },
    );

    test(
      '5.3: copyWith(minHeight: null) clears minHeight and keeps the rest',
      () {
        final cleared = full.copyWith(minHeight: null);

        expect(cleared.minHeight, isNull);
        expect(
          cleared,
          const WidgetStyle(
            opacity: 0.5,
            width: 100,
            height: 200,
            minWidth: 10,
            maxWidth: 300,
            maxHeight: 400,
          ),
        );
      },
    );

    test(
      '5.3: copyWith(maxHeight: null) clears maxHeight and keeps the rest',
      () {
        final cleared = full.copyWith(maxHeight: null);

        expect(cleared.maxHeight, isNull);
        expect(
          cleared,
          const WidgetStyle(
            opacity: 0.5,
            width: 100,
            height: 200,
            minWidth: 10,
            maxWidth: 300,
            minHeight: 20,
          ),
        );
      },
    );
  });

  group('merge', () {
    test('returns the same instance when other is null', () {
      expect(identical(base.merge(null), base), isTrue);
    });

    test('non-null fields of other replace this values', () {
      final merged = base.merge(
        const WidgetStyle(
          padding: EdgeInsets.all(16),
          backgroundColor: Color(0xFFFFFFFF),
        ),
      );

      expect(merged.padding, const EdgeInsets.all(16));
      expect(merged.backgroundColor, const Color(0xFFFFFFFF));
    });

    test('null fields of other keep this values', () {
      final merged = base.merge(const WidgetStyle(opacity: 0.5));

      expect(
        merged,
        const WidgetStyle(
          opacity: 0.5,
          padding: EdgeInsets.all(8),
          borderRadius: BorderRadius.all(Radius.circular(4)),
          backgroundColor: Color(0xFF000000),
          backgroundBlur: ImageBlurFilter(sigmaX: 4, sigmaY: 4),
          dropShadow: [BoxShadow(blurRadius: 2)],
        ),
      );
    });

    test('keeps every field when the other side is empty', () {
      const full = WidgetStyle(
        opacity: 0.5,
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(4),
        width: 120,
        height: 48,
        minWidth: 40,
        maxWidth: 320,
        minHeight: 24,
        maxHeight: 96,
        alignment: Alignment.center,
        border: Border.fromBorderSide(BorderSide()),
        borderRadius: BorderRadius.all(Radius.circular(4)),
        backgroundColor: Color(0xFF000000),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF000000), Color(0xFFFFFFFF)],
        ),
        backgroundImage: DecorationImage(image: AssetImage('background.png')),
        backgroundBlur: ImageBlurFilter(sigmaX: 4, sigmaY: 4),
        foregroundColor: Color(0x1F000000),
        foregroundGradient: LinearGradient(
          colors: [Color(0x00000000), Color(0x1F000000)],
        ),
        foregroundImage: DecorationImage(image: AssetImage('foreground.png')),
        foregroundBlur: ImageBlurFilter(sigmaX: 2, sigmaY: 2),
        clipBehavior: Clip.antiAlias,
        innerShadow: [BoxShadow(blurRadius: 1)],
        dropShadow: [BoxShadow(blurRadius: 2)],
        animationStyle: AnimationStyle.noAnimation,
      );

      expect(full.merge(const WidgetStyle()), full);
      expect(const WidgetStyle().merge(full), full);
    });

    test('lists are replaced, and an empty list clears them', () {
      final replaced = base.merge(
        const WidgetStyle(dropShadow: [BoxShadow(blurRadius: 8)]),
      );
      final cleared = base.merge(const WidgetStyle(dropShadow: []));

      expect(replaced.dropShadow, const [BoxShadow(blurRadius: 8)]);
      expect(cleared.dropShadow, isEmpty);
    });
  });

  group('lerp', () {
    const a = WidgetStyle(
      opacity: 1,
      padding: EdgeInsets.all(8),
      width: 100,
      backgroundColor: Color(0xFF000000),
      clipBehavior: Clip.none,
      animationStyle: AnimationStyle(duration: Duration(milliseconds: 100)),
    );
    const b = WidgetStyle(
      opacity: 0.5,
      padding: EdgeInsets.all(16),
      width: 200,
      backgroundColor: Color(0xFFFFFFFF),
      clipBehavior: Clip.antiAlias,
      animationStyle: AnimationStyle(duration: Duration(milliseconds: 300)),
    );

    test('fo05/us03/fr01: returns a at t = 0 and b at t = 1', () {
      expect(identical(WidgetStyle.lerp(a, b, 0), a), isTrue);
      expect(identical(WidgetStyle.lerp(a, b, 1), b), isTrue);
    });

    test('interpolates opacity, spacing, sizes, and colors', () {
      final mid = WidgetStyle.lerp(a, b, 0.5)!;

      expect(mid.opacity, 0.75);
      expect(mid.padding, const EdgeInsets.all(12));
      expect(mid.width, 150);
      expect(
        mid.backgroundColor,
        Color.lerp(a.backgroundColor, b.backgroundColor, 0.5),
      );
    });

    test(
      'switches clipBehavior at t = 0.5 and takes animationStyle from b',
      () {
        expect(WidgetStyle.lerp(a, b, 0.4)!.clipBehavior, Clip.none);
        expect(WidgetStyle.lerp(a, b, 0.6)!.clipBehavior, Clip.antiAlias);
        expect(WidgetStyle.lerp(a, b, 0.1)!.animationStyle, b.animationStyle);
      },
    );

    test('switches a size at t = 0.5 when one side is null', () {
      const unsized = WidgetStyle();
      const sized = WidgetStyle(height: 48);

      expect(WidgetStyle.lerp(unsized, sized, 0.4)!.height, isNull);
      expect(WidgetStyle.lerp(unsized, sized, 0.6)!.height, 48);
    });

    test('treats a null style as an empty style', () {
      const target = WidgetStyle(
        backgroundColor: Color(0xFFFFFFFF),
        opacity: 0.5,
      );
      final mid = WidgetStyle.lerp(null, target, 0.5)!;

      expect(
        mid.backgroundColor,
        Color.lerp(null, const Color(0xFFFFFFFF), 0.5),
      );
      expect(mid.opacity, 0.75);
    });

    test('keeps values legal when the curve overshoots', () {
      final over = WidgetStyle.lerp(b, a, 2.5)!;

      expect(over.opacity, 1);
      expect(over.padding!.isNonNegative, isTrue);
      expect(over.width, 0);
    });

    test('keeps shadow blur legal when the curve overshoots', () {
      const shadowed = WidgetStyle(
        dropShadow: [BoxShadow(blurRadius: 8)],
        innerShadow: [BoxShadow(blurRadius: 4)],
      );
      const plain = WidgetStyle();

      final removed = WidgetStyle.lerp(shadowed, plain, 1.2)!;
      final added = WidgetStyle.lerp(plain, shadowed, -0.2)!;

      expect(removed.dropShadow!.single.blurRadius, 0);
      expect(removed.innerShadow!.single.blurRadius, 0);
      expect(added.dropShadow!.single.blurRadius, 0);
    });

    test('switches a non-finite size at t = 0.5', () {
      const full = WidgetStyle(width: double.infinity);
      const fixed = WidgetStyle(width: 200);

      expect(WidgetStyle.lerp(full, fixed, 0.25)!.width, double.infinity);
      expect(WidgetStyle.lerp(full, fixed, 0.75)!.width, 200);
    });
  });

  group('window-size overrides', () {
    test('fo05/us04/fr01/e01: no override, resolve returns the style '
        'unchanged', () {
      const style = WidgetStyle(padding: EdgeInsets.all(16));

      expect(style.resolve(WindowSize.tablet), same(style));
      expect(style.hasWindowOverrides, isFalse);
    });

    test('fo05/us04/fr01, fo05/us04/s2: a fill with 16 px padding, a tablet '
        'override of 24 px padding, and a desktop override of a new fill '
        'resolve on desktop to the desktop fill with 24 px padding', () {
      final cascaded =
          const WidgetStyle(
            padding: EdgeInsets.all(16),
            backgroundColor: Color(0xFF000000),
          ).at(
            tablet: const WidgetStyle(padding: EdgeInsets.all(24)),
            desktop: const WidgetStyle(backgroundColor: Color(0xFFFFFFFF)),
          );

      final onDesktop = cascaded.resolve(WindowSize.desktop);

      expect(onDesktop.backgroundColor, const Color(0xFFFFFFFF));
      expect(onDesktop.padding, const EdgeInsets.all(24));
    });

    test('fo05/us04/fr01/e02: a window smaller than every override resolves '
        'to the base', () {
      final styled = const WidgetStyle(padding: EdgeInsets.all(16))
          .at(desktop: const WidgetStyle(padding: EdgeInsets.all(32)));

      expect(
        styled.resolve(WindowSize.mobile),
        const WidgetStyle(padding: EdgeInsets.all(16)),
      );
    });

    test('fo05/us04/fr01/e03: an override null field keeps the cascaded '
        'value', () {
      final styled =
          const WidgetStyle(
            padding: EdgeInsets.all(16),
            backgroundColor: Color(0xFF000000),
          ).at(
            tablet: const WidgetStyle(padding: EdgeInsets.all(24)),
            desktop: const WidgetStyle(backgroundColor: Color(0xFFFFFFFF)),
          );

      expect(
        styled.resolve(WindowSize.desktop).padding,
        const EdgeInsets.all(24),
      );
    });

    test('fo05/us04/fr01: two .at() calls merge their overrides per window '
        'size', () {
      final styled = const WidgetStyle(padding: EdgeInsets.all(16))
          .at(tablet: const WidgetStyle(width: 320))
          .at(tablet: const WidgetStyle(height: 48));

      expect(styled.windowOverrides, {
        WindowSize.tablet: const WidgetStyle(width: 320, height: 48),
      });
      expect(
        styled.resolve(WindowSize.tablet),
        const WidgetStyle(padding: EdgeInsets.all(16), width: 320, height: 48),
      );
    });

    test('fo05/us04/fr01: at() with no override returns the same style', () {
      const style = WidgetStyle(padding: EdgeInsets.all(16));

      expect(style.at(), same(style));
      expect(
        style.at(tablet: const WidgetStyle(width: 320)).at(),
        style.at(tablet: const WidgetStyle(width: 320)),
      );
    });

    test('fo05/us04/fr01: lerp asserts on a style that still carries '
        'overrides', () {
      final styled = const WidgetStyle(padding: EdgeInsets.all(16))
          .at(desktop: const WidgetStyle(padding: EdgeInsets.all(32)));
      const plain = WidgetStyle();

      expect(
        () => WidgetStyle.lerp(styled, plain, 0.5),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => WidgetStyle.lerp(plain, styled, 0.5),
        throwsA(isA<AssertionError>()),
      );
    });

    test('fo05/us04/fr03/e01: the override sets only a fill at the base '
        'level, and the base carries a desktop override of 32 px padding, so '
        'on a desktop window the merged style shows the override fill with '
        '32 px padding', () {
      final base = const WidgetStyle(padding: EdgeInsets.all(16))
          .at(desktop: const WidgetStyle(padding: EdgeInsets.all(32)));
      const override = WidgetStyle(backgroundColor: Color(0xFFFFFFFF));

      final onDesktop = base.merge(override).resolve(WindowSize.desktop);

      expect(onDesktop.backgroundColor, const Color(0xFFFFFFFF));
      expect(onDesktop.padding, const EdgeInsets.all(32));
    });

    test('fo05/us04/fr03/e02: the override carries a desktop override and '
        'the base carries none, so the merged style gains the override '
        'desktop fields', () {
      const base = WidgetStyle(padding: EdgeInsets.all(16));
      final override = const WidgetStyle().at(
        desktop: const WidgetStyle(padding: EdgeInsets.all(32)),
      );

      final onDesktop = base.merge(override).resolve(WindowSize.desktop);

      expect(onDesktop.padding, const EdgeInsets.all(32));
      expect(base.merge(override).resolve(WindowSize.mobile), base);
    });

    test('fo05/us04/fr03/e03: the override sets a fill at its base level and '
        'the base desktop override sets another fill, so on a desktop window '
        'the override fill shows', () {
      final base = const WidgetStyle(padding: EdgeInsets.all(16))
          .at(desktop: const WidgetStyle(backgroundColor: Color(0xFF000000)));
      const override = WidgetStyle(backgroundColor: Color(0xFFFFFFFF));

      expect(
        base.merge(override).resolve(WindowSize.desktop).backgroundColor,
        const Color(0xFFFFFFFF),
      );
    });

    test('fo05/us04/fr03/e04: neither side carries an override, so the '
        'layering rule of US-01 FR-02 applies unchanged', () {
      const base = WidgetStyle(padding: EdgeInsets.all(16));
      const override = WidgetStyle(backgroundColor: Color(0xFFFFFFFF));

      expect(
        base.merge(override),
        const WidgetStyle(
          padding: EdgeInsets.all(16),
          backgroundColor: Color(0xFFFFFFFF),
        ),
      );
    });

    test('fo05/us04/fr03, s03/inv12: base.merge(o).resolve(W) equals '
        'base.resolve(W).merge(o.resolve(W)) on all five window sizes', () {
      final base =
          const WidgetStyle(
            padding: EdgeInsets.all(16),
            backgroundColor: Color(0xFF000000),
          ).at(
            tablet: const WidgetStyle(padding: EdgeInsets.all(24)),
            desktop: const WidgetStyle(width: 320),
          );
      final other = const WidgetStyle(opacity: 0.5).at(
        mobile: const WidgetStyle(height: 48),
        desktop: const WidgetStyle(backgroundColor: Color(0xFFFFFFFF)),
      );
      final merged = base.merge(other);

      for (final size in WindowSize.values) {
        expect(
          merged.resolve(size),
          base.resolve(size).merge(other.resolve(size)),
          reason: '$size',
        );
      }
    });

    test('fo05/us04/fr03, s03/inv12: when both sides override the same '
        'field at the same size, the override wins there and above', () {
      final base = const WidgetStyle(padding: EdgeInsets.all(16))
          .at(desktop: const WidgetStyle(padding: EdgeInsets.all(32)));
      final other = const WidgetStyle().at(
        desktop: const WidgetStyle(padding: EdgeInsets.all(24)),
      );
      final merged = base.merge(other);

      expect(
        merged.resolve(WindowSize.tablet).padding,
        const EdgeInsets.all(16),
      );
      expect(
        merged.resolve(WindowSize.desktop).padding,
        const EdgeInsets.all(24),
      );
      expect(
        merged.resolve(WindowSize.bigDesktop).padding,
        const EdgeInsets.all(24),
      );
      for (final size in WindowSize.values) {
        expect(
          merged.resolve(size),
          base.resolve(size).merge(other.resolve(size)),
          reason: '$size',
        );
      }
    });

    test('fo05/us04/fr01, s03/inv11: a watch-only override applies on every '
        'window size up to big desktop', () {
      final style = const WidgetStyle(padding: EdgeInsets.all(1))
          .at(watch: const WidgetStyle(padding: EdgeInsets.all(2)));

      expect(
        style.resolve(WindowSize.bigDesktop).padding,
        const EdgeInsets.all(2),
      );
    });
  });
}
