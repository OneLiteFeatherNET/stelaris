import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/dialogs/notes_edit_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';

/// Saves the notes, or fails like the backend can.
class _SaveNotes extends ReduxAction<AppState> {
  _SaveNotes(this.notes, this.saved, {this.error});

  final String? notes;
  final List<String?> saved;
  final Object? error;

  @override
  Future<AppState?> reduce() async {
    final error = this.error;
    if (error != null) throw error;
    saved.add(notes);
    return null;
  }
}

void main() {
  Future<List<String?>> pumpDialog(WidgetTester tester, {Object? error}) async {
    final saved = <String?>[];
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: Store<AppState>(initialState: const AppState()),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => NotesEditDialog(
                    name: 'Sword',
                    notes: null,
                    saveAction: (notes) =>
                        _SaveNotes(notes, saved, error: error),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return saved;
  }

  Finder saveButton() => find.widgetWithText(FilledButton, 'Save');

  testWidgets('saves the notes and closes', (tester) async {
    final saved = await pumpDialog(tester);

    await tester.enterText(find.byType(TextField), 'sharp');
    await tester.tap(saveButton());
    await tester.pumpAndSettle();

    expect(saved, ['sharp']);
    expect(find.byType(NotesEditDialog), findsNothing);
  });

  testWidgets('a failed save shows the error and keeps the dialog open', (
    tester,
  ) async {
    await pumpDialog(tester, error: Exception('backend down'));

    await tester.enterText(find.byType(TextField), 'sharp');
    await tester.tap(saveButton());
    await tester.pumpAndSettle();

    expect(find.byType(NotesEditDialog), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('backend down'), findsOneWidget);
    // Nothing typed is lost, and it can be saved again.
    expect(find.text('sharp'), findsOneWidget);
    expect(tester.widget<FilledButton>(saveButton()).onPressed, isNotNull);
  });
}
