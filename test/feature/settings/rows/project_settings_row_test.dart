import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
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
    );

    Future<Store<AppState>> pumpRow(WidgetTester tester) async {
      final store = Store<AppState>(
        initialState: const AppState(
          projects: [projectA, projectB],
          selectedProject: projectA,
        ),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: ProjectSettingsRow()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return store;
    }

    testWidgets('shows confirmation dialog when selecting another project', (
      tester,
    ) async {
      await pumpRow(tester);

      await tester.tap(find.byType(DropdownButton<Project>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Project B').last);
      await tester.pumpAndSettle();

      expect(find.text('Switch project?'), findsOneWidget);
    });

    testWidgets('keeps selected project unchanged when dialog is cancelled', (
      tester,
    ) async {
      final store = await pumpRow(tester);

      await tester.tap(find.byType(DropdownButton<Project>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Project B').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(store.state.selectedProject, projectA);
      expect(find.text('Switch project?'), findsNothing);
    });

    testWidgets('switches selected project when dialog is confirmed', (
      tester,
    ) async {
      final store = await pumpRow(tester);

      await tester.tap(find.byType(DropdownButton<Project>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Project B').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Switch project'));
      await tester.pumpAndSettle();

      expect(store.state.selectedProject, projectB);
    });
  });
}
