import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/project/project_selection_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import 'package:stelaris/api/api_service.dart';
import '../../support/fake_http_client_adapter.dart';

void main() {
  group('ProjectSelectionPage Widget Tests', () {
    setUp(() {
      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(
        const PaginatedResult<Project>(
          items: [],
          totalItems: 0,
          totalPages: 0,
          currentPage: 1,
          pageSize: 50,
        ).toJson((p) => p.toJson()),
      );
    });

    testWidgets('renders empty state when no projects exist', (tester) async {
      final store = Store<AppState>(initialState: const AppState());

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProjectSelectionPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Welcome to Stelaris'), findsOneWidget);
      expect(find.text('Select Project'), findsOneWidget);
      expect(find.text('No projects found'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders list with projects when available', (tester) async {
      const projectA = Project(
        id: 'test_id_a',
        displayName: 'Test Project A',
        key: 'test_key_a',
        description: 'First project description',
      );
      const projectB = Project(
        id: 'test_id_b',
        displayName: 'Test Project B',
        key: 'test_key_b',
        description: 'Second project description',
        labor: true,
      );

      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(
        const PaginatedResult<Project>(
          items: [projectA, projectB],
          totalItems: 2,
          totalPages: 1,
          currentPage: 1,
          pageSize: 50,
        ).toJson((p) => p.toJson()),
      );

      final store = Store<AppState>(
        initialState: const AppState(projects: [projectA, projectB]),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProjectSelectionPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Welcome to Stelaris'), findsOneWidget);
      expect(find.text('Select Project'), findsOneWidget);
      expect(find.text('Test Project A'), findsOneWidget);
      expect(find.text('Test Project B'), findsOneWidget);
      expect(find.text('First project description'), findsOneWidget);
      expect(find.text('Second project description'), findsOneWidget);
      expect(find.text('Labor'), findsOneWidget);
      expect(find.text('Open Project'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));
    });

    testWidgets('tapping edit icon opens EditProjectDialog', (tester) async {
      const project = Project(
        id: 'test_id',
        displayName: 'Test Project',
        key: 'test_key',
        description: 'A test project description',
      );

      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(
        const PaginatedResult<Project>(
          items: [project],
          totalItems: 1,
          totalPages: 1,
          currentPage: 1,
          pageSize: 50,
        ).toJson((p) => p.toJson()),
      );

      final store = Store<AppState>(
        initialState: const AppState(projects: [project]),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProjectSelectionPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Edit project'), findsOneWidget);
      expect(find.text('test_key'), findsOneWidget);
    });
  });
}
