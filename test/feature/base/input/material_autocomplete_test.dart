import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/input/material_autocomplete.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    double? height,
  }) async {
    if (height != null) {
      tester.view.physicalSize = Size(400, height);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: brightness,
          ),
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 300,
              child: MaterialAutocomplete(
                onSelected: (_) {},
                fieldBuilder: (context, controller, focusNode, onSubmitted) =>
                    TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onFieldSubmitted: (_) => onSubmitted(),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.tap(find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField), text);
    await tester.pump();
  }

  group('suggestion list', () {
    testWidgets('is as wide as the field', (tester) async {
      await pumpField(tester);

      await type(tester, 'diamond');

      expect(tester.getSize(find.byType(ListView)).width, 300);
    });

    for (final brightness in Brightness.values) {
      testWidgets('uses the menu surface of the $brightness theme', (
        tester,
      ) async {
        await pumpField(tester, brightness: brightness);

        await type(tester, 'diamond');

        final scheme = Theme.of(
          tester.element(find.byType(TextFormField)),
        ).colorScheme;
        final panel = tester.widget<Material>(
          find
              .ancestor(
                of: find.byType(ListView),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(panel.color, scheme.surfaceContainer);
        expect(panel.elevation, 3);
      });
    }

    testWidgets('scrolls the highlighted suggestion into view', (tester) async {
      // Leaves room for roughly two of the five suggestions.
      await pumpField(tester, height: 230);
      final last = suggestMaterials('diamond').last;

      await type(tester, 'diamond');
      expect(
        find.text(last.key),
        findsNothing,
        reason: 'the last suggestion fits without scrolling',
      );

      for (var i = 0; i < maxMaterialSuggestions - 1; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
      }

      expect(find.text(last.key), findsOneWidget);
      final list = tester.getRect(find.byType(ListView));
      final item = tester.getRect(find.text(last.key));
      expect(
        list.contains(item.center),
        isTrue,
        reason: 'the highlighted suggestion is outside the list',
      );
    });

    testWidgets('scrolls back up when the highlight wraps around', (
      tester,
    ) async {
      await pumpField(tester, height: 230);
      final first = suggestMaterials('diamond').first;

      await type(tester, 'diamond');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(
        tester.getRect(find.byType(ListView)).contains(
          tester.getRect(find.text(first.key)).center,
        ),
        isTrue,
      );
    });
  });
}
