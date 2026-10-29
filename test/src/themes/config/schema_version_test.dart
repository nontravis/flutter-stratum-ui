import 'package:flutter_test/flutter_test.dart';
import 'package:stratum_ui/src/src.dart';

void main() {
  group('StratumSchemaVersion.tryParse', () {
    test('reads stratum-theme/v<major>.<minor>.<patch>', () {
      expect(
        StratumSchemaVersion.tryParse('stratum-theme/v2.0.0'),
        StratumSchemaVersion.current,
      );
      expect(
        StratumSchemaVersion.tryParse('stratum-theme/v2.0.7'),
        const StratumSchemaVersion(2, 0, 7),
      );
    });

    test('gives null for any other form', () {
      for (final value in [
        'stratum-theme/1.0.0',
        'stratum-theme/v2.0',
        'stratum/v1.0.0',
      ]) {
        expect(StratumSchemaVersion.tryParse(value), isNull, reason: value);
      }
    });
  });

  group('StratumSchemaVersion.isSupported', () {
    test('fo01/us01/fr01/e08: every v1 version is unsupported', () {
      expect(const StratumSchemaVersion(1, 0, 0).isSupported, isFalse);
      expect(const StratumSchemaVersion(1, 5, 0).isSupported, isFalse);
      expect(const StratumSchemaVersion(1, 5, 9).isSupported, isFalse);
      expect(const StratumSchemaVersion(2, 0, 7).isSupported, isTrue);
      expect(const StratumSchemaVersion(2, 1, 0).isSupported, isFalse);
      expect(const StratumSchemaVersion(3, 0, 0).isSupported, isFalse);
    });
  });

  test('fo01/us01/fr01: the current version is stratum-theme/v2.0.0', () {
    expect('${StratumSchemaVersion.current}', 'stratum-theme/v2.0.0');
  });
}
