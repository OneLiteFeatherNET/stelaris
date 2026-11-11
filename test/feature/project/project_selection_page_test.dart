import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/feature/project/dialog/project_create_dialog.dart';
import 'package:stelaris/feature/project/parts/project_pack_icon.dart';
import 'package:stelaris/feature/project/project_selection_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import 'package:stelaris/api/api_service.dart';
import '../../support/fake_http_client_adapter.dart';
import '../../support/pack_icon_pngs.dart';
import '../../support/settle_requests.dart';

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
      expect(find.text('Create new project'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));

      await tester.tap(find.text('Create new project'));
      await tester.pumpAndSettle();

      expect(find.text('Create new project'), findsNWidgets(2));

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Create new project'), findsOneWidget);
    });

    testWidgets('shows the pack icon of a project that has one', (
      tester,
    ) async {
      const projectA = Project(
        id: 'test_id_a',
        displayName: 'Test Project A',
        key: 'test_key_a',
      );
      const projectB = Project(
        id: 'test_id_b',
        displayName: 'Test Project B',
        key: 'test_key_b',
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
      final icon = ProjectPackIcon(
        asset: AssetModel(
          id: 'icon-1',
          projectId: 'test_id_a',
          displayName: 'pack.png',
          key: 'test_key_a:pack',
          kind: AssetKind.TEXTURE,
          fileName: 'pack.png',
          contentType: 'image/png',
          size: png16.length,
          sha1: 'sha-icon',
          width: 16,
          height: 16,
        ),
        bytes: Future.value(png16),
      );
      final loaded = <String>[];

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: Store<AppState>(
            initialState: const AppState(projects: [projectA, projectB]),
          ),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProjectSelectionPage(
              loadPackIcon: (projectId) async {
                loaded.add(projectId);
                return projectId == 'test_id_a' ? icon : null;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextureThumbnail), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Test Project A'),
          matching: find.byType(TextureThumbnail),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Test Project B'),
          matching: find.byIcon(Icons.folder_outlined),
        ),
        findsOneWidget,
      );

      // Selecting a project rebuilds the list without loading again.
      await tester.tap(find.text('Test Project B'));
      await tester.pumpAndSettle();
      expect(loaded, ['test_id_a', 'test_id_b']);

      // The edit dialog may change the icon, so it is loaded again after.
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await settleRequests(
        tester,
        () => find
            .byType(CircularProgressIndicator, skipOffstage: false)
            .evaluate()
            .isNotEmpty,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(loaded, ['test_id_a', 'test_id_b', 'test_id_a']);
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
      // The dialog loads the pack meta through the faked client.
      await settleRequests(
        tester,
        () => find
            .byType(CircularProgressIndicator, skipOffstage: false)
            .evaluate()
            .isNotEmpty,
      );

      expect(find.text('Edit project'), findsOneWidget);
      expect(find.text('test_key'), findsOneWidget);
    });

    testWidgets('a created project offers to set up its pack', (tester) async {
      const created = Project(
        id: 'p-new',
        displayName: 'My Project',
        key: 'my_project',
      );
      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            final path = options.uri.path;
            if (path.contains('/pack-meta/')) {
              return FakeHttpClientAdapter.response({
                'title': 'Not found',
                'status': 404,
              }, statusCode: 404);
            }
            if (options.method == 'POST') {
              return FakeHttpClientAdapter.response(created.toJson());
            }
            return FakeHttpClientAdapter.response(
              const PaginatedResult<Project>(
                items: [],
                totalItems: 0,
                totalPages: 0,
                currentPage: 1,
                pageSize: 50,
              ).toJson((p) => p.toJson()),
            );
          });

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: Store<AppState>(initialState: const AppState()),
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProjectSelectionPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'My Project');
      await tester.enterText(fields.at(1), 'my_project');
      await tester.tap(
        find.descendant(
          of: find.byType(CreateProjectDialog),
          matching: find.byType(FilledButton),
        ),
      );
      await settleRequests(
        tester,
        () => find.byType(SnackBar).evaluate().isEmpty,
      );

      expect(find.text('Project My Project created'), findsOneWidget);

      await tester.tap(find.text('Set up pack'));
      await settleRequests(
        tester,
        () => find
            .byType(CircularProgressIndicator, skipOffstage: false)
            .evaluate()
            .isNotEmpty,
      );

      expect(find.text('Edit project'), findsOneWidget);
      // The key sits in the project tab, which is mounted but not shown.
      expect(
        find.text('my_project', skipOffstage: false),
        findsOneWidget,
        reason: 'the dialog edits the created project',
      );
      final tabs = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabs.controller!.index, 1, reason: 'the pack tab is shown');
    });
  });
}
