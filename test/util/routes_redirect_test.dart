import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/routes.dart';

void main() {
  testWidgets('GoRouter redirect sends user to /projects when selectedProject is null', (
    tester,
  ) async {
    final store = Store<AppState>(initialState: const AppState());

    final testRouter = GoRouter(
      initialLocation: '/test',
      redirect: projectSelectionRedirect,
      routes: [
        GoRoute(
          path: '/test',
          builder: (context, state) =>
              const Scaffold(body: Text('Protected Content')),
        ),
        GoRoute(
          path: projectSelectionRoute,
          builder: (context, state) =>
              const Scaffold(body: Text('Project Selection Page')),
        ),
      ],
    );

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp.router(
          routerConfig: testRouter,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      testRouter.routerDelegate.currentConfiguration.uri.toString(),
      projectSelectionRoute,
    );
  });
}
