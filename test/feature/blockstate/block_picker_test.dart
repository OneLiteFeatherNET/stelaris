import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/blockstate/block_picker.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('block picker', () {
    testWidgets('scrolling does not repaint the whole list', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: blockPickerWidth,
              height: blockPickerHeight,
              child: BlockPicker(onBlock: (_) {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final list = find.byType(ListView);
      tester.binding.handlePointerEvent(
        PointerScrollEvent(
          position: tester.getCenter(list),
          scrollDelta: const Offset(0, 100),
        ),
      );

      // The Material around the list holds the ink of the rows unless each
      // row has its own: then it would repaint all rows on every frame.
      final around = find
          .ancestor(of: list, matching: find.byType(Material))
          .first;
      expect(tester.renderObject(around).debugNeedsPaint, isFalse);
      await tester.pump();
    });
  });
}
