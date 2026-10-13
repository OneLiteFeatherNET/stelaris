import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/settings/rows/project_settings_row.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('ProjectSettingsRow Widget Tests', () {
    const projectA = Project(
      id: 'a',
      displayName: 'Project A',
      key: 'project_a',
    );
    const projectB = Project(
      id: 'b',
      displayName: 'Project B',
      key: 'project_b',
      labor: true,
    );

    Future<Store<AppState>> pumpRow(
      WidgetTester tester, {
      AppState state = const AppState(
        projects: [projectA, projectB],
        selectedProject: projectA,
      ),
    }) async {
      final store = Store<AppState>(initialState: state);

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(child: ProjectSettingsRow()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return store;
    }

    /// Opens the choice dialog and picks project B.
    Future<void> pickProjectB(WidgetTester tester) async {
      await tester.tap(find.text('Project A (project_a)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Project B (project_b)'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the heading and the active project', (tester) async {
      await pumpRow(tester);

      expect(find.text('Project'), findsOneWidget);
      expect(find.text('Project A (project_a)'), findsOneWidget);
    });

    testWidgets('shows the first project when none is selected', (
      tester,
    ) async {
      await pumpRow(
        tester,
        state: const AppState(projects: [projectA, projectB]),
      );

      expect(find.text('Project A (project_a)'), findsOneWidget);
    });

    testWidgets('shows the first project when the selected one is gone', (
      tester,
    ) async {
      await pumpRow(
        tester,
        state: const AppState(
          projects: [projectA, projectB],
          selectedProject: Project(id: 'x', displayName: 'Gone', key: 'gone'),
        ),
      );

      expect(find.text('Project A (project_a)'), findsOneWidget);
      expect(find.text('Gone (gone)'), findsNothing);
    });

    testWidgets('lists the projects with the labor badge in the choice', (
      tester,
    ) async {
      await pumpRow(tester);

      await tester.tap(find.text('Project A (project_a)'));
      await tester.pumpAndSettle();

      expect(find.text('Project B (project_b)'), findsOneWidget);
      expect(find.text('Labor'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog when selecting another project', (
      tester,
    ) async {
      await pumpRow(tester);

      await pickProjectB(tester);

      expect(find.text('Switch project?'), findsOneWidget);
    });

    testWidgets('keeps selected project unchanged when dialog is cancelled', (
      tester,
    ) async {
      final store = await pumpRow(tester);
      await pickProjectB(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(store.state.selectedProject, projectA);
      expect(find.text('Switch project?'), findsNothing);
    });

    testWidgets('switches selected project when dialog is confirmed', (
      tester,
    ) async {
      final store = await pumpRow(tester);
      await pickProjectB(tester);

      await tester.tap(find.text('Switch project'));
      await tester.pumpAndSettle();

      expect(store.state.selectedProject, projectB);
    });

    testWidgets('does not ask when the current project is picked again', (
      tester,
    ) async {
      final store = await pumpRow(tester);

      await tester.tap(find.text('Project A (project_a)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Project A (project_a)').last);
      await tester.pumpAndSettle();

      expect(find.text('Switch project?'), findsNothing);
      expect(store.state.selectedProject, projectA);
    });

    testWidgets('asks about unsaved edits after the switch is confirmed', (
      tester,
    ) async {
      await pumpRow(
        tester,
        state: const AppState(
          projects: [projectA, projectB],
          selectedProject: projectA,
          unsavedChanges: NavigationEntry.items,
        ),
      );
      await pickProjectB(tester);

      await tester.tap(find.text('Switch project'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('unsaved_dialog_discard')), findsOneWidget);
    });

    testWidgets('keeps the project when the unsaved prompt is cancelled', (
      tester,
    ) async {
      final store = await pumpRow(
        tester,
        state: const AppState(
          projects: [projectA, projectB],
          selectedProject: projectA,
          unsavedChanges: NavigationEntry.items,
        ),
      );
      await pickProjectB(tester);
      await tester.tap(find.text('Switch project'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('unsaved_dialog_cancel')));
      await tester.pumpAndSettle();

      expect(store.state.selectedProject, projectA);
    });

    testWidgets('shows the heading and an empty state without projects', (
      tester,
    ) async {
      await pumpRow(tester, state: const AppState());

      expect(find.text('Project'), findsOneWidget);
      expect(find.text('No projects yet'), findsOneWidget);
    });
  });
}
