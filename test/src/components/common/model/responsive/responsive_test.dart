import 'package:flutter_test/flutter_test.dart';
import 'package:stratum_ui/src/src.dart';

void main() {
  test('fo07/us03/fr01/e01: no override set gives the base value on every window size', () {
    const value = Responsive<int>(1);
    for (final size in WindowSize.values) {
      expect(value.resolve(size), 1, reason: 'window size $size');
    }
  });

  test('fo07/us03/fr01/e02: only a desktop override, on a big desktop window, gives the desktop override', () {
    const value = Responsive<int>(1, desktop: 2);
    expect(value.resolve(WindowSize.bigDesktop), 2);
  });

  test('fo07/us03/fr01/e03: only a desktop override, on a tablet window, gives the base', () {
    const value = Responsive<int>(1, desktop: 2);
    expect(value.resolve(WindowSize.tablet), 1);
  });

  test('fo07/us03/fr01, s03/inv5: Responsive(1, watch: 2, tablet: 3) gives '
      '2, 2, 3, 3, 3 from watch to big desktop', () {
    const value = Responsive<int>(1, watch: 2, tablet: 3);
    final resolved = [
      value.resolve(WindowSize.watch),
      value.resolve(WindowSize.mobile),
      value.resolve(WindowSize.tablet),
      value.resolve(WindowSize.desktop),
      value.resolve(WindowSize.bigDesktop),
    ];
    expect(resolved, [2, 2, 3, 3, 3]);
  });

  test(
    'fo07/us03/fr01: a const Responsive(false, tablet: true) defaults a prop',
    () {
      const value = Responsive<bool>(false, tablet: true);
      expect(value.base, isFalse);
      expect(value.tablet, isTrue);
      const again = Responsive<bool>(false, tablet: true);
      expect(identical(value, again), isTrue);
    },
  );

  test('fo08/us08/fr02/e01: resolve answers every WindowSize.values entry', () {
    const value = Responsive<String>(
      'base',
      mobile: 'mobile',
      bigDesktop: 'big',
    );
    final resolved = {
      for (final size in WindowSize.values) size: value.resolve(size),
    };
    expect(resolved[WindowSize.watch], 'base');
    expect(resolved[WindowSize.mobile], 'mobile');
    expect(resolved[WindowSize.tablet], 'mobile');
    expect(resolved[WindowSize.desktop], 'mobile');
    expect(resolved[WindowSize.bigDesktop], 'big');
  });
}
