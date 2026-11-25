import 'package:flutter_stratum_ui/src/themes/constant/widget_size.dart';

/// The widget size names a `theme.yaml` `component` group may hold, in
/// `WidgetSize` order. A test pins them to `WidgetSize.values`.
/// Internal: not exported.
const widgetSizeNames = <String>[
  'tiny',
  'extra-small',
  'small',
  'medium',
  'large',
  'extra-large',
  'huge',
];

/// The [WidgetSize] that `theme.yaml` spells [name]; null when [name] is
/// not in [widgetSizeNames].
WidgetSize? widgetSizeOfName(String name) {
  final index = widgetSizeNames.indexOf(name);
  return index < 0 ? null : WidgetSize.values[index];
}
