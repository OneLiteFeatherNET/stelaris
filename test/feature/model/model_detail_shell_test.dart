import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  late Store<AppState> store;

  Future<void> pump(
    WidgetTester tester, {
    AppState state = const AppState(),
    String? title = 'Ruby Sword',
  }) async {
    store = Store<AppState>(initialState: state);
    final router = GoRouter(
      initialLocation: '/items/detail',
      routes: [
        GoRoute(
          path: '/items',
          builder: (context, state) => const Scaffold(body: Text('Item List')),
          routes: [
            GoRoute(
              path: 'detail',
              builder: (context, state) => Scaffold(
                body: ModelDetailShell(
                  entry: NavigationEntry.items,
                  title: title,
                  actions: const [Text('action')],
                  body: const Text('Body content'),
                ),
              ),
            ),
          ],
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
    await tester.pumpAndSettle();
  }

  testWidgets('shows the header with title and actions above the body', (
    tester,
  ) async {
    await pump(tester);

    expect(find.byType(PageHeader), findsOneWidget);
    expect(find.text('Ruby Sword'), findsOneWidget);
    expect(find.text('action'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(PageHeader)).dy,
      lessThan(tester.getTopLeft(find.text('Body content')).dy),
    );
  });

  testWidgets('renders without a title', (tester) async {
    await pump(tester, title: null);
    expect(find.text('Body content'), findsOneWidget);
  });

  testWidgets('back goes to the list when nothing is unsaved', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('page_header_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('Item List'), findsOneWidget);
  });

  testWidgets('shows the unsaved dot and asks before going back', (
    tester,
  ) async {
    await pump(
      tester,
      state: const AppState(unsavedChanges: NavigationEntry.items),
    );
    expect(
      find.byKey(const Key('page_header_unsaved_indicator')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('page_header_back_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('unsaved_dialog_cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Body content'), findsOneWidget);

    await tester.tap(find.byKey(const Key('page_header_back_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('unsaved_dialog_discard')));
    await tester.pumpAndSettle();
    expect(find.text('Item List'), findsOneWidget);
  });

  testWidgets('another section being dirty does not mark this one', (
    tester,
  ) async {
    await pump(
      tester,
      state: const AppState(unsavedChanges: NavigationEntry.font),
    );
    expect(find.byKey(const Key('page_header_unsaved_indicator')), findsNothing);
  });
}
