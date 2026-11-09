import 'package:async_redux/async_redux.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/font/chars/char_list_item.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('CharListItem', () {
    Future<void> pumpItem(
      WidgetTester tester, {
      String line = '',
      int index = 0,
      int? expectedLength,
      VoidCallback? onEdit,
      VoidCallback? onDelete,
    }) {
      return tester.pumpWidget(
        StoreProvider<AppState>(
          store: Store<AppState>(initialState: const AppState()),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: CharListItem(
                fontString: FontStringDTO(id: '1', line: line),
                index: index,
                expectedLength: expectedLength,
                onEdit: onEdit ?? () {},
                onDelete: onDelete ?? () {},
              ),
            ),
          ),
        ),
      );
    }

    Color? badgeColor(WidgetTester tester) {
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byKey(const Key('font_char_length')),
          matching: find.byType(DecoratedBox),
        ),
      );
      return (box.decoration as BoxDecoration).color;
    }

    testWidgets('shows every code point as hex', (tester) async {
      await pumpItem(tester);

      expect(find.text('E000'), findsOneWidget);
      expect(find.text('E001'), findsOneWidget);
    });

    testWidgets('shows the row number', (tester) async {
      await pumpItem(tester, index: 2);

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows the number of code points', (tester) async {
      await pumpItem(tester, line: '', expectedLength: 3);

      final badge = find.byKey(const Key('font_char_length'));
      expect(
        find.descendant(of: badge, matching: find.text('3')),
        findsOneWidget,
      );
    });

    testWidgets('marks a length the other lines do not have', (tester) async {
      await pumpItem(tester, expectedLength: 2);
      final theme = Theme.of(tester.element(find.byType(CharListItem)));
      expect(badgeColor(tester), isNot(theme.colorScheme.errorContainer));

      await pumpItem(tester, expectedLength: 3);
      expect(badgeColor(tester), theme.colorScheme.errorContainer);
    });

    testWidgets('copies the characters themselves', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpItem(tester);

      await tester.tap(find.byIcon(Icons.copy_outlined));
      await tester.pump();

      expect(copied, '');
    });

    testWidgets('the card does not light up behind its buttons', (
      tester,
    ) async {
      await pumpItem(tester);
      InkWell card() => tester.widget<InkWell>(
        find
            .descendant(
              of: find.byType(CharListItem),
              matching: find.byType(InkWell),
            )
            .first,
      );
      expect(card().overlayColor, isNull);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(
        location: tester.getCenter(find.byIcon(Icons.copy_outlined)),
      );
      await tester.pump();

      expect(
        card().overlayColor?.resolve({WidgetState.hovered}),
        Colors.transparent,
      );
    });

    testWidgets('a tap on the card edits the line', (tester) async {
      var edited = 0;
      await pumpItem(tester, onEdit: () => edited++);

      await tester.tap(find.text('E000'));

      expect(edited, 1);
    });

    testWidgets('offers no edit button', (tester) async {
      var deleted = 0;
      await pumpItem(tester, onDelete: () => deleted++);

      expect(find.byIcon(Icons.edit), findsNothing);
      await tester.tap(find.byIcon(Icons.delete_forever));

      expect(deleted, 1);
    });
  });
}
