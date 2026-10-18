import 'package:async_redux/async_redux.dart';
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
                fontString: const FontStringDTO(id: '1', line: 'ABC'),
                onEdit: onEdit ?? () {},
                onDelete: onDelete ?? () {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('a tap on the card edits the line', (tester) async {
      var edited = 0;
      await pumpItem(tester, onEdit: () => edited++);

      await tester.tap(find.text('ABC'));

      expect(edited, 1);
    });

    testWidgets('offers only a delete button', (tester) async {
      var deleted = 0;
      await pumpItem(tester, onDelete: () => deleted++);

      expect(find.byIcon(Icons.edit), findsNothing);
      await tester.tap(find.byIcon(Icons.delete_forever));

      expect(deleted, 1);
    });
  });
}
