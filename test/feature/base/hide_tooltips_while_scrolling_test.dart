import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/hide_tooltips_while_scrolling.dart';

void main() {
  Future<void> pumpList(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HideTooltipsWhileScrolling(
            child: ListView(
              children: [
                for (var i = 0; i < 50; i++)
                  Tooltip(
                    message: 'Tip $i',
                    child: SizedBox(height: 40, child: Text('Row $i')),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<TestGesture> hover(WidgetTester tester, Offset position) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: position);
    await tester.pump();
    return gesture;
  }

  testWidgets('shows a tooltip on hover while the list rests', (tester) async {
    await pumpList(tester);
    await hover(tester, tester.getCenter(find.text('Row 2')));
    await tester.pumpAndSettle();

    expect(find.text('Tip 2'), findsOneWidget);
  });

  testWidgets('shows no tooltip for rows scrolled under the pointer', (
    tester,
  ) async {
    await pumpList(tester);
    final position = tester.getCenter(find.text('Row 2'));
    await hover(tester, position);
    await tester.pumpAndSettle();

    tester.binding.handlePointerEvent(
      PointerScrollEvent(position: position, scrollDelta: const Offset(0, 120)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Tip '), findsNothing);

    // Once the list settles the row under the pointer shows its tooltip.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Tip 5'), findsOneWidget);
  });
}
