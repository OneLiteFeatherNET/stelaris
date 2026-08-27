import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/project/dialog/project_edit_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('EditProjectDialog Widget Tests', () {
    const originalProject = Project(
      id: 'proj-123',
      displayName: 'Original Project',
      key: 'orig_key',
      description: 'Original Description',
      projectUrl: 'https://github.com/test/repo',
      docuUrl: 'https://docs.test.com',
      labor: false,
    );

    Future<Store<AppState>> pumpDialog(
      WidgetTester tester, {
      Project project = originalProject,
    }) async {
      final store = Store<AppState>(
        initialState: AppState(
          projects: [project],
          selectedProject: project,
        ),
      );

      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(
        project.copyWith(displayName: 'Updated Name').toJson(),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => EditProjectDialog(project: project),
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

      return store;
    }

    testWidgets('pre-populates all existing project properties', (tester) async {
      await pumpDialog(tester);

      expect(find.text('Edit project'), findsOneWidget);
      expect(find.text('Original Project'), findsOneWidget);
      expect(find.text('orig_key'), findsOneWidget);
      expect(find.text('Original Description'), findsOneWidget);
      expect(find.text('https://github.com/test/repo'), findsOneWidget);
      expect(find.text('https://docs.test.com'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('closes when Cancel is pressed', (tester) async {
      await pumpDialog(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Edit project'), findsNothing);
    });

    testWidgets('validates required display name and updates project on Save', (
      tester,
    ) async {
      final store = await pumpDialog(tester);

      // Clear display name to trigger validation error
      final displayNameFinder = find.byType(TextFormField).first;
      await tester.enterText(displayNameFinder, '');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Display name is required'), findsOneWidget);

      // Enter valid updated name
      await tester.enterText(displayNameFinder, 'Updated Name');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Edit project'), findsNothing);
      expect(store.state.projects.first.displayName, 'Updated Name');
      expect(store.state.selectedProject?.displayName, 'Updated Name');
    });
  });
}
