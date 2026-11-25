import 'package:flutter_stratum_ui/src/src.dart';
import 'package:flutter_stratum_ui/src/themes/config/plain_by_window_size.dart';
import 'package:flutter_stratum_ui/src/themes/config/window_size_yaml_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fo01/us05/fr01: the yaml name of a window size', () {
    test('yamlName is windowSizeNames at the size index, big-desktop last', () {
      for (final size in WindowSize.values) {
        expect(size.yamlName, windowSizeNames[size.index]);
      }
      expect(WindowSize.bigDesktop.yamlName, 'big-desktop');
    });

    test('windowSizeOfYamlName inverts yamlName', () {
      for (final size in WindowSize.values) {
        expect(windowSizeOfYamlName(size.yamlName), size);
      }
    });

    test('windowSizeOfYamlName throws for the v1 key bigDesktop', () {
      expect(() => windowSizeOfYamlName('bigDesktop'), throwsArgumentError);
      expect(() => windowSizeOfYamlName('huge'), throwsArgumentError);
    });
  });
}
