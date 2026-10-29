import 'package:stratum_ui/src/themes/config/plain_by_window_size.dart';
import 'package:stratum_ui/src/themes/constant/window_size.dart';

/// The `theme.yaml` spelling of a [WindowSize].
extension WindowSizeYamlName on WindowSize {
  /// The name `theme.yaml` writes for this size: `big-desktop` for
  /// [WindowSize.bigDesktop], the enum name otherwise.
  String get yamlName => windowSizeNames[index];
}

/// The [WindowSize] that `theme.yaml` spells [name].
///
/// Throws [ArgumentError] when [name] is not in `windowSizeNames`.
WindowSize windowSizeOfYamlName(String name) {
  final index = windowSizeNames.indexOf(name);
  if (index < 0) {
    throw ArgumentError.value(name, 'name', 'not a window size name');
  }
  return WindowSize.values[index];
}
