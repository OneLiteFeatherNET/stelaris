import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/model/shared_model_gate.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Stands in for an open action: selects the attribute once [done]
/// completes, or fails when [done] completes with an error.
class _FakeOpen extends ReduxAction<AppState> {
  _FakeOpen(this.id, this.done);

  final String id;
  final Future<void> done;

  @override
  Future<AppState?> reduce() async {
    await done;
    return state.copyWith(
      selectedAttribute: AttributeModel(uiName: id, id: id),
    );
  }
}

void main() {
  late int opened;
  late Completer<void> done;

  GoRouter routerAt(String location) => GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: '/projects/:projectId/attributes',
        builder: (context, state) => const Scaffold(body: Text('List')),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => Scaffold(
              body: SharedModelGate(
                projectId: state.pathParameters['projectId']!,
                id: state.pathParameters['id']!,
                open: (projectId, id) {
                  opened++;
                  return _FakeOpen(id, done.future);
                },
                isOpen: (state, id) => state.selectedAttribute?.id == id,
                listLocation: '/projects/p/attributes',
                child: const Text('Detail'),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  Future<GoRouter> pumpAt(
    WidgetTester tester,
    String location, {
    AppState state = const AppState(),
  }) async {
    // Created inside the test, not in setUp: a completer made outside the
    // test's fake async zone completes on the real event loop, which the
    // pumps below never get to.
    opened = 0;
    done = Completer<void>();
    final router = routerAt(location);
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: Store<AppState>(initialState: state),
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();
    return router;
  }

  testWidgets('loads the named model once, then shows the page', (
    tester,
  ) async {
    await pumpAt(tester, '/projects/p/attributes/a');

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Detail'), findsNothing);

    done.complete();
    await tester.pumpAndSettle();

    expect(find.text('Detail'), findsOneWidget);
    expect(opened, 1);
  });

  testWidgets('shows a model that is open already without loading it', (
    tester,
  ) async {
    await pumpAt(
      tester,
      '/projects/p/attributes/a',
      state: const AppState(
        selectedAttribute: AttributeModel(uiName: 'a', id: 'a'),
      ),
    );

    expect(find.text('Detail'), findsOneWidget);
    expect(opened, 0);
  });

  testWidgets('falls back to the list with a notice when loading fails', (
    tester,
  ) async {
    final router = await pumpAt(tester, '/projects/p/attributes/a');

    done.completeError(Exception('404'));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/projects/p/attributes',
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.snackbar_shared_model_not_found), findsOneWidget);
  });
}
