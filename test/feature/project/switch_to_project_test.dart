import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/project/switch_to_project.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  const target = Project(id: 'q', displayName: 'Q', key: 'q');

  Widget switchButton() => Builder(
    builder: (context) => TextButton(
      onPressed: () => switchToProject(context, null, target),
      child: const Text('switch'),
    ),
  );

  Future<(GoRouter, Store<AppState>)> pumpAt(
    WidgetTester tester,
    String location,
  ) async {
    final store = Store<AppState>(
      initialState: const AppState(
        selectedProject: Project(id: 'p', displayName: 'P', key: 'p'),
      ),
    );
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/projects/:projectId/attributes',
          builder: (context, state) => Scaffold(body: switchButton()),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => Scaffold(body: switchButton()),
            ),
          ],
        ),
        GoRoute(
          path: '/items',
          builder: (context, state) => Scaffold(body: switchButton()),
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

  String locationOf(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.toString();

  testWidgets('a section below a project follows the switch', (tester) async {
    final (router, store) = await pumpAt(tester, '/projects/p/attributes');

    await tester.tap(find.text('switch'));
    await tester.pumpAndSettle();

    expect(store.state.selectedProject, target);
    expect(locationOf(router), '/projects/q/attributes');
  });

  testWidgets('a detail page goes to the list of the new project', (
    tester,
  ) async {
    // The model belongs to the old project, so there is no detail to keep.
    final (router, _) = await pumpAt(tester, '/projects/p/attributes/a');

    await tester.tap(find.text('switch'));
    await tester.pumpAndSettle();

    expect(locationOf(router), '/projects/q/attributes');
  });

  testWidgets('a section without a project stays where it is', (tester) async {
    final (router, store) = await pumpAt(tester, '/items');

    await tester.tap(find.text('switch'));
    await tester.pumpAndSettle();

    expect(store.state.selectedProject, target);
    expect(locationOf(router), '/items');
  });
}
