import 'package:flutter_test/flutter_test.dart';
import 'package:stratum_ui/src/themes/constant/window_size.dart';

import 'window_size_policy.dart';

/// One warm analysis context serves every test in this file.
final WindowSizePolicyChecker _checker = WindowSizePolicyChecker();

/// A component-tree probe that compares window sizes by order (rule a).
const String _orderProbe = '''
import 'package:stratum_ui/src/themes/constant/window_size.dart';

bool f(WindowSize w) => w >= WindowSize.desktop;
''';

/// A component-tree probe whose switch over `WindowSize` keeps a `_` catch-all
/// (rule b).
const String _catchAllProbe = '''
import 'package:stratum_ui/src/themes/constant/window_size.dart';

String f(WindowSize w) => switch (w) {
      WindowSize.watch => 'watch',
      WindowSize.mobile => 'mobile',
      _ => 'other',
    };
''';

/// A component-tree probe that compares widget sizes by order: allowed.
const String _widgetOrderProbe = '''
import 'package:stratum_ui/src/themes/constant/widget_size.dart';

bool f(WidgetSize size) => size >= WidgetSize.large;
''';

/// An app-code probe: window-size order comparisons stay allowed there.
const String _appOrderProbe = '''
import 'package:stratum_ui/src/themes/constant/window_size.dart';

bool f(WindowSize w) => w >= WindowSize.desktop;
''';

/// A component-tree probe that maps each `WidgetSize` to a number (rule c).
const String _widgetTableProbe = '''
import 'package:stratum_ui/src/themes/constant/widget_size.dart';

double side(WidgetSize s) => switch (s) {
      WidgetSize.tiny => 8,
      WidgetSize.extraSmall => 12,
      WidgetSize.small => 16,
      WidgetSize.medium => 20,
      WidgetSize.large => 24,
      WidgetSize.extraLarge => 32,
      WidgetSize.huge => 40,
    };
''';

/// A component-tree probe that maps a `WindowSize` to a number through a
/// conditional expression (rule c).
const String _windowConditionalProbe = '''
import 'package:stratum_ui/src/themes/constant/window_size.dart';

double f(WindowSize w) => w == WindowSize.desktop ? 1 : 2;
''';

/// A probe passing a responsive value to a prop whose type is not responsive,
/// so it fails to compile (FO-07 US-03 FR-02 E01).
const String _responsivePropProbe = '''
import 'package:flutter/widgets.dart';
import 'package:stratum_ui/src/components/common/layout/page_layout.dart';
import 'package:stratum_ui/src/components/common/model/responsive/responsive.dart';

Widget f() => const PageLayout(rightAsOverlay: Responsive(false));
''';

void main() {
  test('fo08/us08/fr02/e02, s03/inv23: no component code compares window sizes by order', () async {
    final hits = await _checker.ruleHits(root: 'lib/src/components');
    final orderOrCatchAll = hits
        .where((hit) => hit.contains('INV-23'))
        .toList();
    expect(
      orderOrCatchAll,
      isEmpty,
      reason:
          'component tree holds a window-size order comparison or a '
          'catch-all switch:\n${orderOrCatchAll.join('\n')}',
    );
  });

  test('fo08/us08/fr01, s03/inv22: no component maps a window or widget size to a number', () async {
    final hits = await _checker.ruleHits(root: 'lib/src/components');
    final tables = hits.where((hit) => hit.contains('INV-22')).toList();
    expect(
      tables,
      isEmpty,
      reason:
          'component tree holds a size-to-number table:\n'
          '${tables.join('\n')}',
    );
  });

  test('fo08/us08/s4: a component that compares window sizes by order fails the rule', () async {
    final hits = await _checker.ruleHits(
      root: 'lib/src/components',
      overlays: {'lib/src/components/policy_probe.dart': _orderProbe},
    );
    final order = hits
        .where((hit) => hit.contains('order comparison'))
        .toList();
    expect(order, hasLength(1));
    expect(order.single, contains('lib/src/components/policy_probe.dart:3'));
  });

  test('fo08/us08/s3, fo08/us08/fr02/e01: a switch over WindowSize with a catch-all fails the rule', () async {
    final hits = await _checker.ruleHits(
      root: 'lib/src/components',
      overlays: {'lib/src/components/policy_probe.dart': _catchAllProbe},
    );
    final catchAll = hits
        .where((hit) => hit.contains('catch-all switch'))
        .toList();
    expect(catchAll, hasLength(1));
    expect(catchAll.single, contains('lib/src/components/policy_probe.dart:3'));
  });

  test(
    'fo08/us08/s6, fo08/us08/fr02/e04: a widget-size comparison passes',
    () async {
      final hits = await _checker.ruleHits(
        root: 'lib/src/components',
        overlays: {'lib/src/components/policy_probe.dart': _widgetOrderProbe},
      );
      expect(hits.where((hit) => hit.contains('policy_probe.dart')), isEmpty);
    },
  );

  test(
    'fo08/us08/s5, fo08/us08/fr02/e03: app code may compare window sizes',
    () async {
      final hits = await _checker.ruleHits(
        root: 'lib/src/components',
        overlays: {'lib/src/application/policy_probe.dart': _appOrderProbe},
      );
      expect(hits.where((hit) => hit.contains('policy_probe.dart')), isEmpty);
      expect(WindowSize.desktop >= WindowSize.tablet, isTrue);
    },
  );

  test('s03/inv22: a widget-size switch that maps every size to a number fails the rule', () async {
    final hits = await _checker.ruleHits(
      root: 'lib/src/components',
      overlays: {'lib/src/components/policy_probe.dart': _widgetTableProbe},
    );
    final tables = hits.where((hit) => hit.contains('size-to-number')).toList();
    expect(tables, hasLength(1));
    expect(tables.single, contains('lib/src/components/policy_probe.dart:3'));
  });

  test(
    's03/inv22: a window-size conditional that yields a number fails the rule',
    () async {
      final hits = await _checker.ruleHits(
        root: 'lib/src/components',
        overlays: {
          'lib/src/components/policy_probe.dart': _windowConditionalProbe,
        },
      );
      final tables = hits
          .where((hit) => hit.contains('size-to-number'))
          .toList();
      expect(tables, hasLength(1));
      expect(tables.single, contains('lib/src/components/policy_probe.dart:3'));
    },
  );

  test('fo07/us03/s4, fo07/us03/fr02/e01: a responsive value on a prop the docs do not name does not compile', () async {
    final errors = await _checker.compileErrors({
      'lib/src/components/policy_probe.dart': _responsivePropProbe,
    });
    final typeErrors = errors
        .where((error) => error.contains('argument_type_not_assignable'))
        .toList();
    expect(typeErrors, isNotEmpty);
    expect(typeErrors.first, contains('bool'));
  });
}
