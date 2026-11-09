import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/font/font_string_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/font/chars/dialog/font_char_dialog.dart';
import 'package:stelaris/feature/font/chars/dialog/font_char_info_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Records the dispatched actions.
class _Recorder implements ActionObserver<AppState> {
  final List<ReduxAction<AppState>> dispatched = [];

  @override
  void observe(
    ReduxAction<AppState> action,
    int dispatchCount, {
    required bool ini,
  }) {
    if (ini) dispatched.add(action);
  }
}

/// Opens a [FontCharDialog] for [fontString]. No font is selected, so the
/// dispatched actions end before they call the API.
Future<_Recorder> _pump(
  WidgetTester tester, {
  FontStringDTO? fontString,
}) async {
  final recorder = _Recorder();
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: Store<AppState>(
        initialState: const AppState(),
        actionObservers: [recorder],
      ),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => FontCharDialog(fontString: fontString),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return recorder;
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('adds the characters the hex code points stand for', (
    tester,
  ) async {
    final recorder = await _pump(tester);

    await tester.enterText(find.byType(TextFormField), 'E000 F0000');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    final add = recorder.dispatched.whereType<FontStringAddAction>().single;
    expect(add.dto.line, String.fromCharCodes([0xE000, 0xF0000]));
    expect(find.byType(FontCharDialog), findsNothing);
  });

  testWidgets(
    'keeps the dialog open for a code point outside the Private Use Area',
    (tester) async {
      final recorder = await _pump(tester);

      await tester.enterText(find.byType(TextFormField), 'E000 0041');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text(l10n.validation_codepoint_private_use), findsOneWidget);
      expect(recorder.dispatched.whereType<FontStringAddAction>(), isEmpty);
      expect(find.byType(FontCharDialog), findsOneWidget);
    },
  );

  testWidgets('edits a line shown as its hex code points', (tester) async {
    const fontString = FontStringDTO(id: '1', line: '');
    final recorder = await _pump(tester, fontString: fontString);

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller!.text, 'E000 E001');
    await tester.enterText(find.byType(TextFormField), 'E000 E002');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    final edit = recorder.dispatched.whereType<FontStringEditAction>().single;
    expect(edit.dto.id, '1');
    expect(edit.dto.line, '');
  });

  testWidgets('an unchanged line closes without an update', (tester) async {
    const fontString = FontStringDTO(id: '1', line: '');
    final recorder = await _pump(tester, fontString: fontString);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(recorder.dispatched.whereType<FontStringEditAction>(), isEmpty);
    expect(find.byType(FontCharDialog), findsNothing);
  });

  testWidgets('the info button explains the Private Use Area', (tester) async {
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    expect(find.byType(FontCharInfoDialog), findsOneWidget);
    expect(find.text(l10n.font_char_info_title), findsOneWidget);
  });

  testWidgets('an empty field shows the format below it', (tester) async {
    await _pump(tester);

    expect(find.text(l10n.font_char_helper), findsOneWidget);
  });

  testWidgets('keeps everything but hex digits and spaces out', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextFormField), 'E00ß e001,X');

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller!.text, 'E00 e001');
  });
}
