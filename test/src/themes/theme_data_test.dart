import 'package:flutter_stratum_ui/src/src.dart';
import 'package:flutter_test/flutter_test.dart';

import '../components/common/fakes/fake_stratum_theme.dart';

StratumThemeData _withApp() => fakeTheme.copyWith(
  appColors: const {
    'mango': Color(0xFFFFAA00),
    'brand-accent': Color(0xFF112233),
  },
  appPalettes: const {
    'mint': {'500': Color(0xFF00FF88), '600': Color(0xFF00CC66)},
  },
);

void main() {
  group('app colors', () {
    test('appColor and maybeAppColor read color.<set>.app', () {
      final data = _withApp();

      expect(data.appColor('mango'), const Color(0xFFFFAA00));
      expect(data.maybeAppColor('mango'), const Color(0xFFFFAA00));
      expect(data.maybeAppColor('promo-banner'), isNull);
    });

    test('an unknown app color throws, listing the names', () {
      const message =
          'no app color "promo-banner"; this theme has: brand-accent, mango';

      expect(
        () => _withApp().appColor('promo-banner'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            message,
          ),
        ),
      );
      expect(
        () => fakeTheme.appColor('x'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'no app color "x"; this theme has: none',
          ),
        ),
      );
    });

    test('appPalette and shade read palette.app, and throw listing the '
        'names', () {
      final data = _withApp();

      expect(data.appPalette('mint').shade('500'), const Color(0xFF00FF88));
      expect(data.appPalette('mint').name, 'mint');
      expect(
        () => data.appPalette('kiwi'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'no app palette "kiwi"; this theme has: mint',
          ),
        ),
      );
      expect(
        () => data.appPalette('mint').shade('950'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'no shade "950" in app palette "mint"; it has: 500, 600',
          ),
        ),
      );
    });
  });

  group('component ladders', () {
    test("fo01/us06/fr03/e07: the default data's caret side ladder reads "
        '10, 12, 14, 16, 20, 24, 32', () {
      final caret = defaultThemeSet.light.component.caret;

      expect(
        [for (final size in WidgetSize.values) caret.side(size)],
        [10, 12, 14, 16, 20, 24, 32],
      );
    });

    test('fo01/us06/fr03/e07: data with no ladders throws an ArgumentError '
        'naming the missing step', () {
      final data = defaultThemeSet.light.copyWith(ladders: const {});

      expect(
        () => data.component.caret.side(WidgetSize.medium),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.toString(),
            'message',
            contains('component.caret.side.medium'),
          ),
        ),
      );
    });

    test('fo01/us06/fr03/e07: data whose ladder lacks a step names that '
        'step', () {
      final data = defaultThemeSet.light.copyWith(
        ladders: const {
          'caret.side': {WidgetSize.small: 14},
        },
      );

      expect(data.component.caret.side(WidgetSize.small), 14);
      expect(
        () => data.component.caret.side(WidgetSize.huge),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.toString(),
            'message',
            contains('component.caret.side.huge'),
          ),
        ),
      );
    });

    testWidgets("fo03/us10/fr01: the theme data exposes each component's "
        'widget-size ladders as a typed set', (tester) async {
      late StratumTheme theme;
      await tester.pumpWidget(
        StratumThemeApplication(
          themes: StratumThemeSet(light: defaultThemeSet.light),
          themeMode: ThemeMode.light,
          child: Builder(
            builder: (context) {
              theme = StratumTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      for (final size in WidgetSize.values) {
        expect(
          theme.component.caret.side(size),
          defaultThemeSet.light.component.caret.side(size),
        );
      }
    });
  });

  group('copyWith', () {
    test('with no argument keeps every field', () {
      final data = fakeTheme;
      final copy = data.copyWith();

      expect(copy.color, same(data.color));
      expect(copy.physics, same(data.physics));
      expect(copy.animation, same(data.animation));
      expect(copy.opacity, same(data.opacity));
      expect(copy.border, same(data.border));
      expect(copy.shadow, same(data.shadow));
      expect(copy.blur, same(data.blur));
    });

    test('covers every field, physics included', () {
      final base = defaultThemeSet.light;
      final other = defaultThemeSet.dark!;
      const typography = StratumTypography(
        fonts: {'geist': StratumFontData(family: 'Geist')},
        families: {},
        types: {},
      );
      final animation = motionTheme().animation;
      final opacity = StratumOpacityTokens.fromMap(const {
        'disabled': 0.3,
        'scrim': 0.5,
      });
      const transparent = StratumTransparentTokens.builtIn;
      // Wrapped so the generated getter's `_space is EqualUnmodifiableMapView`
      // check returns this exact view back unchanged, keeping the `same()`
      // pins below true: freezed wraps an unwrapped Map in a fresh view on
      // every read, which `same()` would never see as the one passed in.
      final space = EqualUnmodifiableMapView({
        'md': const StratumByWindowSize.all(StratumDimension.fixed(1)),
      });
      final radius = EqualUnmodifiableMapView({
        'md': const StratumByWindowSize.all(StratumDimension.fixed(2)),
      });
      final layouts = EqualUnmodifiableMapView({
        'max': const StratumByWindowSize.all(StratumDimension.fixed(3)),
      });
      final ladders = EqualUnmodifiableMapView({
        'caret.side': {WidgetSize.medium: 3.0},
      });
      final appColors = EqualUnmodifiableMapView({
        'x': const Color(0xFF000001),
      });
      final appPalettes = EqualUnmodifiableMapView({
        'y': {'500': const Color(0xFF000002)},
      });
      final extensions = EqualUnmodifiableMapView<String, Object?>({'z': 1});
      final border = StratumBorderTokens.fromMap(const {
        'sm': 2,
        'md': 3,
        'lg': 4,
      });
      final shadow = other.shadow;
      final blur = StratumBlurTokens.fromMap({
        for (final level in ['1', '2', '3', '4', '5', '6'])
          level: const ImageBlurFilter(sigmaX: 1, sigmaY: 1),
      });
      const systemStyle = SystemStyle(statusBarIcons: SystemBarIcons.dark);
      const scrollBehavior = ScrollBehavior();
      const physics = BouncingScrollPhysics();

      final copy = base.copyWith(
        themeMode: ThemeMode.dark,
        color: other.color,
        palette: other.palette,
        transparent: transparent,
        space: space,
        radius: radius,
        layouts: layouts,
        ladders: ladders,
        appColors: appColors,
        appPalettes: appPalettes,
        assets: other.assets,
        extensions: extensions,
        typography: typography,
        animation: animation,
        opacity: opacity,
        defaultWidgetSize: const StratumByWindowSize.all(WidgetSize.huge),
        border: border,
        shadow: shadow,
        blur: blur,
        systemStyle: systemStyle,
        splashFactory: InkRipple.splashFactory,
        scrollBehavior: scrollBehavior,
        physics: physics,
      );

      expect(copy.themeMode, ThemeMode.dark);
      expect(copy.color, same(other.color));
      expect(copy.palette, same(other.palette));
      expect(copy.transparent, same(transparent));
      expect(copy.space, same(space));
      expect(copy.radius, same(radius));
      expect(copy.layouts, same(layouts));
      expect(copy.ladders, same(ladders));
      expect(copy.appColors, same(appColors));
      expect(copy.appPalettes, same(appPalettes));
      expect(copy.assets, same(other.assets));
      expect(copy.extensions, same(extensions));
      expect(copy.typography, same(typography));
      expect(copy.animation, same(animation));
      expect(copy.opacity, same(opacity));
      expect(
        copy.defaultWidgetSize,
        const StratumByWindowSize.all(WidgetSize.huge),
      );
      expect(copy.border, same(border));
      expect(copy.shadow, same(shadow));
      expect(copy.blur, same(blur));
      expect(copy.systemStyle, systemStyle);
      expect(copy.splashFactory, same(InkRipple.splashFactory));
      expect(copy.scrollBehavior, same(scrollBehavior));
      expect(copy.physics, same(physics));
    });
  });

  group('D4: value equality', () {
    test('D4: a copy with no change equals its source, with the same hash '
        'code', () {
      final data = fakeTheme;

      expect(data.copyWith(), data);
      expect(data.copyWith().hashCode, data.hashCode);
    });

    test('D4: a copy that changes one field differs', () {
      final data = fakeTheme;

      expect(
        data.copyWith(physics: const BouncingScrollPhysics()),
        isNot(data),
      );
      expect(
        data.copyWith(
          defaultWidgetSize: const StratumByWindowSize.all(WidgetSize.small),
        ),
        isNot(data),
      );
    });

    test('D4: StratumAppPalette compares by name and shade content', () {
      StratumAppPalette make(String name) =>
          StratumAppPalette(name, {'500': const Color(0xFF00FF88)});

      expect(make('mint'), make('mint'));
      expect(make('mint').hashCode, make('mint').hashCode);
      expect(make('mint'), isNot(make('sea')));
      expect(make('mint').copyWith(name: 'sea'), make('sea'));
    });

    test("R4 Q2: StratumThemeData takes freezed's toString", () {
      expect(fakeTheme.toString(), startsWith('StratumThemeData('));
    });
  });
}
