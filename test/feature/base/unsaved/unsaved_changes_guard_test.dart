import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/unsaved/unsaved_changes_guard.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import '../../../support/fake_http_client_adapter.dart';
import '../../../support/pump_until.dart';

void main() {
  late Store<AppState> store;
  bool? result;

  Future<void> pump(WidgetTester tester, AppState state) async {
    store = Store<AppState>(initialState: state);
    result = null;
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async =>
                    result = await confirmLeaveIfDirty(context),
                child: const Text('leave'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('allows leaving without a dialog when nothing is unsaved', (
    tester,
  ) async {
    await pump(tester, const AppState());

    await tester.tap(find.text('leave'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(result, isTrue);
  });

  testWidgets('cancel keeps the user on the page', (tester) async {
    await pump(tester, const AppState(unsavedChanges: NavigationEntry.items));

    await tester.tap(find.text('leave'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.byKey(const Key('unsaved_dialog_cancel')));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(store.state.unsavedChanges, NavigationEntry.items);
  });

  testWidgets('discard clears the flag and allows leaving', (tester) async {
    await pump(tester, const AppState(unsavedChanges: NavigationEntry.items));

    await tester.tap(find.text('leave'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('unsaved_dialog_discard')));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(store.state.unsavedChanges, isNull);
  });

  testWidgets('a failed save shows why and stays on the page', (
    tester,
  ) async {
    ApiService().itemApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter.json(
          {'title': 'Broken', 'status': 500},
          statusCode: 500,
        );
    await pump(
      tester,
      const AppState(
        unsavedChanges: NavigationEntry.items,
        selectedItem: ItemModel(id: 'i1', uiName: 'Sword'),
      ),
    );

    await tester.tap(find.text('leave'));
    await tester.pumpAndSettle();
    await pumpUntil(
      tester,
      action: () => tester.tap(find.byKey(const Key('unsaved_dialog_save'))),
      done: () => find.byType(SnackBar).evaluate().isNotEmpty,
    );

    expect(result, isFalse);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(store.state.unsavedChanges, NavigationEntry.items);
  });
}
