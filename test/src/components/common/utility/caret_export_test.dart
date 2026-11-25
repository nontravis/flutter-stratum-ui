import 'package:flutter_stratum_ui/flutter_stratum_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('co01_03/us01/fr01: StratumCaret and its two enums are public through '
      'package:stratum_ui', () {
    const caret = StratumCaret(
      style: StratumCaretGlyph.fill,
      direction: StratumCaretDirection.end,
    );

    expect(caret.style, StratumCaretGlyph.fill);
    expect(caret.direction, StratumCaretDirection.end);
  });
}
