import 'package:flutter_stratum_ui/src/src.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _list(ScrollBehavior behavior) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: ScrollConfiguration(
      behavior: behavior,
      child: ListView(children: const [SizedBox(height: 2000)]),
    ),
  );
}

final Finder _indicator = find.byWidgetPredicate(
  (widget) =>
      widget is StretchingOverscrollIndicator ||
      widget is GlowingOverscrollIndicator,
);

void main() {
  group('StratumScrollBehavior', () {
    testWidgets('fo06_03/us02/fr03: builds no overscroll indicator', (
      tester,
    ) async {
      await tester.pumpWidget(_list(const StratumScrollBehavior()));

      expect(_indicator, findsNothing);
    });

    testWidgets('control: MaterialScrollBehavior builds one', (tester) async {
      await tester.pumpWidget(_list(const MaterialScrollBehavior()));

      expect(_indicator, findsOneWidget);
    });
  });
}
