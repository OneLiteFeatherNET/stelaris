import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/side_panel_layout.dart';

Future<void> _pump(
  WidgetTester tester, {
  required bool shown,
  required ValueChanged<double> onContentWidth,
}) {
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(
          width: 800,
          height: 400,
          child: SidePanelLayout(
            shown: shown,
            panelWidth: (width) => width * 0.3,
            panelPadding: const EdgeInsetsDirectional.only(start: 20),
            content: (context, width) {
              onContentWidth(width);
              return const SizedBox.expand();
            },
            panel: const SizedBox(height: 100, key: Key('panel')),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('the content takes the room the panel leaves', (tester) async {
    late double contentWidth;
    await _pump(tester, shown: true, onContentWidth: (w) => contentWidth = w);

    expect(find.byKey(SidePanelLayout.panelKey), findsOneWidget);
    expect(tester.getSize(find.byKey(const Key('panel'))).width, 240);
    expect(contentWidth, 800 - 240 - 20);
  });

  testWidgets('a hidden panel leaves the whole width to the content', (
    tester,
  ) async {
    late double contentWidth;
    await _pump(tester, shown: true, onContentWidth: (w) => contentWidth = w);

    await _pump(tester, shown: false, onContentWidth: (w) => contentWidth = w);
    await tester.pumpAndSettle();

    expect(find.byKey(SidePanelLayout.panelKey), findsNothing);
    expect(contentWidth, 800);
  });
}
