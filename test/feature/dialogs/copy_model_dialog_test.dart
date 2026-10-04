import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/dialogs/copy_model_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/copy_model_result.dart';
import 'package:stelaris_models/stelaris_models.dart';

const _current = Project(id: 'p1', displayName: 'Lobby', key: 'lobby');
const _other = Project(id: 'p2', displayName: 'Arena', key: 'arena');

final _relations = [
  CopyRelation('LORE', (l10n) => l10n.copy_relation_lore),
  CopyRelation('FLAGS', (l10n) => l10n.copy_relation_flags),
];

void main() {
  group('CopyModelDialog', () {
    late List<CopyModelResult> submitted;
    CopyModelResult? popped;

    Future<void> pump(
      WidgetTester tester, {
      List<Project> projects = const [_current, _other],
      List<CopyRelation> relations = const [],
      Object? error,
      Duration delay = Duration.zero,
    }) async {
      submitted = [];
      popped = null;
      // Room for the whole dialog, relations included, like a desktop window.
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  popped = await showDialog<CopyModelResult>(
                    context: context,
                    builder: (_) => CopyModelDialog(
                      title: 'Copy item',
                      projects: projects,
                      currentProject: _current,
                      initialName: 'Sword',
                      initialKey: 'sword',
                      relations: relations,
                      onSubmit: (result) async {
                        submitted.add(result);
                        await Future<void>.delayed(delay);
                        return error;
                      },
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    Future<void> submit(WidgetTester tester) async {
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
    }

    testWidgets('prefills name, key, project and preview', (tester) async {
      await pump(tester);

      expect(
        find.widgetWithText(TextFormField, 'Sword (Copy)'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'sword-copy'), findsOneWidget);
      expect(find.text('Lobby (lobby)'), findsOneWidget);
      expect(find.text('lobby:sword-copy'), findsOneWidget);
    });

    testWidgets('the preview follows the target project', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Lobby (lobby)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arena (arena)').last);
      await tester.pumpAndSettle();

      expect(find.text('arena:sword-copy'), findsOneWidget);
    });

    testWidgets('offers the open project even when the list lacks it', (
      tester,
    ) async {
      await pump(tester, projects: const [_other]);

      expect(find.text('Lobby (lobby)'), findsOneWidget);
      await submit(tester);
      expect(submitted.single.targetProject, _current);
    });

    testWidgets('shows no relations section without relations', (tester) async {
      await pump(tester);

      expect(find.byType(CheckboxListTile), findsNothing);
    });

    testWidgets('checks every relation and sends the checked ones', (
      tester,
    ) async {
      await pump(tester, relations: _relations);

      expect(find.byType(CheckboxListTile), findsNWidgets(2));
      await tester.tap(find.text('Flags'));
      await tester.pump();
      await submit(tester);

      expect(submitted.single.relations, {'LORE'});
    });

    testWidgets('trims the name and pops with the result', (tester) async {
      await pump(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Sword (Copy)'),
        '  Blade  ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'sword-copy'),
        'blade',
      );
      await submit(tester);

      expect(submitted.single.name, 'Blade');
      expect(submitted.single.key, 'blade');
      expect(popped?.key, 'blade');
      expect(find.byType(CopyModelDialog), findsNothing);
    });

    testWidgets('an invalid key blocks submitting', (tester) async {
      await pump(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'sword-copy'),
        'bad..key',
      );
      await submit(tester);

      expect(submitted, isEmpty);
      expect(find.byType(CopyModelDialog), findsOneWidget);
    });

    testWidgets('stays open on a failed copy and can be retried', (
      tester,
    ) async {
      await pump(tester, error: Exception('409'));

      await submit(tester);
      expect(find.byType(CopyModelDialog), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);

      await submit(tester);
      expect(submitted, hasLength(2));
    });

    testWidgets('a second tap while copying sends nothing more', (
      tester,
    ) async {
      await pump(tester, delay: const Duration(milliseconds: 100));

      await tester.tap(find.text('Copy'));
      await tester.pump();
      await tester.tap(find.text('Copy'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(submitted, hasLength(1));
    });

    testWidgets('cannot be cancelled while copying', (tester) async {
      await pump(tester, delay: const Duration(milliseconds: 100));

      await tester.tap(find.text('Copy'));
      await tester.pump();
      await tester.tap(find.text('Cancel'), warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close), warnIfMissed: false);
      await tester.pump();
      expect(find.byType(CopyModelDialog), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(CopyModelDialog), findsNothing);
      expect(popped?.key, 'sword-copy');
    });
  });
}
