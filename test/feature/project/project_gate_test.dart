import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/project/project_gate.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';

void main() {
  const projectA = Project(id: 'A', displayName: 'A', key: 'A');
  const projectB = Project(id: 'B', displayName: 'B', key: 'B');

  Future<(GoRouter, Store<AppState>)> pumpAt(
    WidgetTester tester,
    String location, {
    AppState state = const AppState(),
  }) async {
    final store = Store<AppState>(initialState: state);
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/projects',
          builder: (context, state) => const Scaffold(body: Text('Projects')),
        ),
        GoRoute(
          path: '/projects/:projectId/attributes',
          builder: (context, state) => Scaffold(
            body: ProjectGate(
              projectId: state.pathParameters['projectId']!,
              child: const Text('List'),
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    return (router, store);
  }

  testWidgets('shows the page right away when the project is selected', (
    tester,
  ) async {
    await pumpAt(
      tester,
      '/projects/A/attributes',
      state: const AppState(selectedProject: projectA),
    );

    expect(find.text('List'), findsOneWidget);
  });

  testWidgets('selects the named project before showing the page', (
    tester,
  ) async {
    final (_, store) = await pumpAt(
      tester,
      '/projects/B/attributes',
      state: const AppState(
        selectedProject: projectA,
        projects: [projectA, projectB],
      ),
    );

    expect(find.text('List'), findsNothing);

    await tester.pumpAndSettle();

    expect(store.state.selectedProject, projectB);
    expect(find.text('List'), findsOneWidget);
  });

  testWidgets('sends the person to the project list when the project is '
      'out of reach', (tester) async {
    (ApiService().projectApi as BaseApi<Project>)
        .apiClient
        .dio
        .httpClientAdapter = FakeHttpClientAdapter.json(
      const <String, Object>{},
      statusCode: 404,
    );
    final (router, _) = await pumpAt(tester, '/projects/missing/attributes');

    // The lookup goes through dio, which runs outside the fake clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/projects',
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.snackbar_project_not_found), findsOneWidget);
  });
}
