import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/routes.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Describes one list/detail route pair guarded by a detail redirect.
class _DetailRedirectCase {
  final String name;
  final String listPath;
  final GoRouterRedirect redirect;
  final ReduxAction<AppState> Function() selectAction;

  const _DetailRedirectCase({
    required this.name,
    required this.listPath,
    required this.redirect,
    required this.selectAction,
  });
}

final _detailCases = [
  _DetailRedirectCase(
    name: 'itemDetailRedirect',
    listPath: '/items',
    redirect: itemDetailRedirect,
    selectAction: () => SelectedItemAction(const ItemModel(uiName: 'Test')),
  ),
  _DetailRedirectCase(
    name: 'fontDetailRedirect',
    listPath: '/fonts',
    redirect: fontDetailRedirect,
    selectAction: () => SelectFontAction(const FontModel(uiName: 'Test')),
  ),
  _DetailRedirectCase(
    name: 'soundDetailRedirect',
    listPath: '/sound',
    redirect: soundDetailRedirect,
    selectAction: () => SelectSoundAction(SoundEventModel(uiName: 'Test')),
  ),
  _DetailRedirectCase(
    name: 'notificationDetailRedirect',
    listPath: '/notifications',
    redirect: notificationDetailRedirect,
    selectAction: () =>
        SelectedNotificationAction(const NotificationModel(uiName: 'Test')),
  ),
];

Widget _createApp(Store<AppState> store, GoRouter router) {
  return StoreProvider<AppState>(
    store: store,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

String _currentLocation(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.toString();

void main() {
  testWidgets(
    'projectSelectionRedirect sends user to /projects when selectedProject is null',
    (tester) async {
      final store = Store<AppState>(initialState: const AppState());
      final router = GoRouter(
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

      await tester.pumpWidget(_createApp(store, router));
      await tester.pumpAndSettle();

      expect(_currentLocation(router), projectSelectionRoute);
    },
  );

  for (final testCase in _detailCases) {
    group(testCase.name, () {
      final detailPath = '${testCase.listPath}/detail';

      GoRouter createRouter() => GoRouter(
        initialLocation: detailPath,
        redirect: testCase.redirect,
        routes: [
          GoRoute(
            path: testCase.listPath,
            builder: (context, state) => const Scaffold(body: Text('List')),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) =>
                    const Scaffold(body: Text('Detail')),
              ),
            ],
          ),
        ],
      );

      testWidgets(
        'redirects to ${testCase.listPath} when nothing is selected',
        (tester) async {
          final store = Store<AppState>(initialState: const AppState());
          final router = createRouter();

          await tester.pumpWidget(_createApp(store, router));
          await tester.pumpAndSettle();

          expect(_currentLocation(router), testCase.listPath);
        },
      );

      testWidgets('stays on $detailPath when a model is selected', (
        tester,
      ) async {
        final store = Store<AppState>(initialState: const AppState());
        store.dispatch(testCase.selectAction());
        final router = createRouter();

        await tester.pumpWidget(_createApp(store, router));
        await tester.pumpAndSettle();

        expect(_currentLocation(router), detailPath);
      });
    });
  }
}
