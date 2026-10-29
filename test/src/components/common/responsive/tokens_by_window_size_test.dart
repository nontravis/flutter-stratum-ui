import 'package:flutter_test/flutter_test.dart';
import 'package:stratum_ui/src/src.dart';

import '../fakes/fake_stratum_theme.dart';

const ValueKey<String> _contentKey = ValueKey('content');

/// A box layout whose padding is the page space token for the current
/// window size; [paddings] records the token on every build.
class _PageSpaceProbe extends BoxLayout {
  const new({required this.paddings});

  final List<double> paddings;

  @override
  Widget buildContent(BuildContext context) {
    final pageSpace = context.theme.space.pageSpace;
    paddings.add(pageSpace);
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.all(pageSpace),
        child: const SizedBox(key: _contentKey, width: 10, height: 10),
      ),
    );
  }
}

/// A widget with the shared props that records its default widget size.
class _SizeProbe extends StratumStatelessWidget {
  const new({required this.sizes, super.size});

  final List<WidgetSize> sizes;

  @override
  Widget build(BuildContext context) {
    sizes.add(resolveDefaultSize(context));
    return const SizedBox();
  }
}

/// The package default with [layer] laid over it as the app layer.
StratumThemeData _themed(String layer) => StratumThemeSet.fromConfig(
  StratumThemeConfig.parse(
    base: const StratumThemeSource(
      id: 'stratum-default',
      folder: 'packages/stratum_ui/assets/themes/default',
      yaml: defaultThemeSource,
    ),
    layers: [
      StratumThemeSource(
        id: 'app',
        folder: 'themes/app',
        yaml: '\$schema: stratum-theme/v2.0.0\n$layer',
      ),
    ],
  ),
).light;

Widget _host(StratumThemeData data, Widget child) => StratumThemeApplication(
  themes: StratumThemeSet(light: data),
  themeMode: ThemeMode.light,
  child: child,
);

void _setView(WidgetTester tester, double width, double height) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.reset);
}

const _mobile = Size(400, 800);
const _tablet = Size(900, 800);
const _desktop = Size(1300, 800);
const _watch = Size(250, 250);

/// The pad the probe shows: the content's offset from the top left.
double _pad(WidgetTester tester) {
  final offset = tester.getTopLeft(find.byKey(_contentKey));
  expect(offset.dx, offset.dy);
  return offset.dx;
}

const _pageSpaceLayer = 'space:\n  page-space: { mobile: 16, desktop: 32 }\n';

void main() {
  group('fo07/us02/fr01: the page space token per window size', () {
    testWidgets(
      'fo07/us02/s1, fo07/us02/fr01: page-space { mobile: 16, desktop: 32 } '
      'pads 32 px on desktop',
      (tester) async {
        _setView(tester, _desktop.width, _desktop.height);
        final paddings = <double>[];

        await tester.pumpWidget(
          _host(_themed(_pageSpaceLayer), _PageSpaceProbe(paddings: paddings)),
        );

        expect(_pad(tester), 32);
      },
    );

    for (final size in [_mobile, _tablet, _desktop, _watch]) {
      testWidgets(
        'fo07/us02/s2, fo07/us02/fr01/e01: a page space of 12 pads 12 px on '
        'a ${size.width} px window',
        (tester) async {
          _setView(tester, size.width, size.height);
          final paddings = <double>[];

          await tester.pumpWidget(
            _host(
              _themed('space:\n  page-space: 12\n'),
              _PageSpaceProbe(paddings: paddings),
            ),
          );

          expect(_pad(tester), 12);
        },
      );
    }

    testWidgets('fo07/us02/s2, fo07/us02/fr01/e01: a page space of 12 reads no '
        'WindowSizeScope, so crossing a breakpoint never rebuilds the probe', (
      tester,
    ) async {
      _setView(tester, _mobile.width, _mobile.height);
      final paddings = <double>[];
      await tester.pumpWidget(
        _host(
          _themed('space:\n  page-space: 12\n'),
          _PageSpaceProbe(paddings: paddings),
        ),
      );
      paddings.clear();

      _setView(tester, _desktop.width, _desktop.height);
      await tester.pump();

      expect(paddings, isEmpty);
      expect(_pad(tester), 12);
    });

    testWidgets(
      'fo07/us02/s3: mobile to desktop rebuilds the probe once, at 32 px',
      (tester) async {
        _setView(tester, _mobile.width, _mobile.height);
        final paddings = <double>[];
        await tester.pumpWidget(
          _host(_themed(_pageSpaceLayer), _PageSpaceProbe(paddings: paddings)),
        );
        paddings.clear();

        _setView(tester, _desktop.width, _desktop.height);
        await tester.pump();

        expect(paddings, [32]);
        expect(_pad(tester), 32);
      },
    );

    testWidgets(
      'fo07/us02/s4, fo07/us02/fr01/e02: tablet pads 16 px, the entry of '
      'the nearest smaller window size',
      (tester) async {
        _setView(tester, _tablet.width, _tablet.height);
        final paddings = <double>[];

        await tester.pumpWidget(
          _host(_themed(_pageSpaceLayer), _PageSpaceProbe(paddings: paddings)),
        );

        expect(_pad(tester), 16);
      },
    );

    testWidgets(
      'fo07/us02/s5: watch pads 16 px, the entry of the smallest window '
      'size that has one',
      (tester) async {
        _setView(tester, _watch.width, _watch.height);
        final paddings = <double>[];

        await tester.pumpWidget(
          _host(_themed(_pageSpaceLayer), _PageSpaceProbe(paddings: paddings)),
        );

        expect(_pad(tester), 16);
      },
    );

    testWidgets(
      'fo08/us08/s1: setting page-space.desktop to 40 in the theme pads '
      '40 px on desktop with no code change',
      (tester) async {
        _setView(tester, _desktop.width, _desktop.height);
        final paddings = <double>[];

        await tester.pumpWidget(
          _host(
            _themed('space:\n  page-space: { mobile: 16, desktop: 40 }\n'),
            _PageSpaceProbe(paddings: paddings),
          ),
        );

        expect(_pad(tester), 40);
      },
    );
  });

  group('fo07/us02/fr01: the default widget size per window size', () {
    const split =
        'component:\n  default-size: { mobile: medium, desktop: large }';

    testWidgets(
      'fo07/us02/s6, fo07/us02/fr01/e06: default-size { mobile: medium, '
      'desktop: large } gives medium on tablet',
      (tester) async {
        _setView(tester, _tablet.width, _tablet.height);
        final sizes = <WidgetSize>[];

        await tester.pumpWidget(
          _host(_themed(split), _SizeProbe(sizes: sizes)),
        );

        expect(sizes, [WidgetSize.medium]);
      },
    );

    testWidgets(
      'fo07/us02/fr01: default-size { mobile: medium, desktop: large } '
      'gives large on desktop',
      (tester) async {
        _setView(tester, _desktop.width, _desktop.height);
        final sizes = <WidgetSize>[];

        await tester.pumpWidget(
          _host(_themed(split), _SizeProbe(sizes: sizes)),
        );

        expect(sizes, [WidgetSize.large]);
      },
    );

    for (final size in [_mobile, _tablet, _desktop, _watch]) {
      testWidgets('fo07/us02/fr01/e05: a probe with its own size keeps it on a '
          '${size.width} px window', (tester) async {
        _setView(tester, size.width, size.height);
        final sizes = <WidgetSize>[];

        await tester.pumpWidget(
          _host(
            _themed(split),
            _SizeProbe(sizes: sizes, size: WidgetSize.small),
          ),
        );

        expect(sizes, [WidgetSize.small]);
      });
    }
  });

  test('fo07/us02/s7, fo07/us02/fr01/e04: every primitive space token of '
      'the default theme is uniform', () {
    final space = defaultThemeSet.light.space;
    final primitives = space.entries.where(
      (entry) => !entry.key.startsWith('page-space'),
    );

    expect(primitives, isNotEmpty);
    for (final entry in primitives) {
      expect(entry.value.isUniform, isTrue, reason: 'space.${entry.key}');
    }
    expect(space['page-space']!.isUniform, isFalse);
  });
}
