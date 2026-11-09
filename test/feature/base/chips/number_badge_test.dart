import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/chips/number_badge.dart';

void main() {
  Future<void> pumpBadge(WidgetTester tester, int number) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: NumberBadge(number: number)),
        ),
      ),
    );
  }

  testWidgets('is a circle for one digit', (tester) async {
    await pumpBadge(tester, 7);

    final size = tester.getSize(find.byType(NumberBadge));
    expect(size.width, size.height);
  });

  testWidgets('grows into a pill for more digits', (tester) async {
    await pumpBadge(tester, 12345);

    final size = tester.getSize(find.byType(NumberBadge));
    expect(find.text('12345'), findsOneWidget);
    expect(size.width, greaterThan(size.height));
  });
}
