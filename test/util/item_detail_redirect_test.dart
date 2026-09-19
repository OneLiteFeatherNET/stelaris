import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/routes.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('itemDetailRedirect', () {
    late GoRouter testRouter;

    Widget createWidget(Store<AppState> store) {
      testRouter = GoRouter(
        initialLocation: '/items/detail',
        redirect: itemDetailRedirect,
        routes: [
          GoRoute(
            path: '/items',
            builder: (context, state) =>
                const Scaffold(body: Text('Item List')),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) =>
                    const Scaffold(body: Text('Item Detail')),
              ),
            ],
          ),
        ],
      );

      return StoreProvider<AppState>(
        store: store,
        child: MaterialApp.router(
          routerConfig: testRouter,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
    }

    testWidgets(
      'redirects to /items when nothing is selected',
      (tester) async {
        final store = Store<AppState>(initialState: const AppState());

        await tester.pumpWidget(createWidget(store));
        await tester.pumpAndSettle();

        expect(
          testRouter.routerDelegate.currentConfiguration.uri.toString(),
          '/items',
        );
      },
    );

    testWidgets(
      'stays on /items/detail when an item is selected',
      (tester) async {
        final store = Store<AppState>(initialState: const AppState());
        store.dispatch(SelectedItemAction(const ItemModel(uiName: 'Test')));

        await tester.pumpWidget(createWidget(store));
        await tester.pumpAndSettle();

        expect(
          testRouter.routerDelegate.currentConfiguration.uri.toString(),
          '/items/detail',
        );
      },
    );
  });
}
