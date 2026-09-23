import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/dialogs/model_info_dialog.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  const item = ItemModel(id: 'item-1', uiName: 'Ruby Sword', key: 'ruby');

  late Store<AppState> store;
  ItemModel? removed;

  Future<void> pump(WidgetTester tester, AppState state) async {
    store = Store<AppState>(initialState: state);
    removed = null;
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
                body: PageHeader(
                  title: 'Ruby Sword',
                  actions: [
                    ModelDetailActions<ItemModel>(
                      entry: NavigationEntry.items,
                      selectModel: (state) => state.selectedItem,
                      nameSelector: (m) => m.uiName,
                      keySelector: (m) => m.key ?? '',
                      deleteTitle: 'Delete item',
                      removeAction: (m) => _RecordRemove(m, (v) => removed = v),
                    ),
                  ],
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

  testWidgets('save is disabled while nothing is unsaved', (tester) async {
    await pump(tester, const AppState(selectedItem: item));

    final save = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Save'),
        matching: find.bySubtype<FilledButton>(),
      ),
    );
    expect(save.onPressed, isNull);
  });

  testWidgets('save is enabled when this section has unsaved edits', (
    tester,
  ) async {
    await pump(
      tester,
      const AppState(
        selectedItem: item,
        unsavedChanges: NavigationEntry.items,
      ),
    );

    final save = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Save'),
        matching: find.bySubtype<FilledButton>(),
      ),
    );
    expect(save.onPressed, isNotNull);
  });

  testWidgets('info opens the model info dialog', (tester) async {
    await pump(tester, const AppState(selectedItem: item));

    await tester.tap(find.text('Info'));
    await tester.pumpAndSettle();

    expect(find.byType(ModelInfoDialog), findsOneWidget);
  });

  testWidgets('deleting with unsaved edits skips the guard and returns to '
      'the list', (tester) async {
    await pump(
      tester,
      const AppState(
        selectedItem: item,
        unsavedChanges: NavigationEntry.items,
      ),
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Ruby Sword');
    await tester.pumpAndSettle();
    // The dialog's confirm button (FormDialog action, labelled with
    // tooltip_delete) sits in the overlay above the header's Delete.
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Item List'), findsOneWidget);
    expect(removed, item);
    expect(store.state.unsavedChanges, isNull);
  });
}

class _RecordRemove extends ReduxAction<AppState> {
  _RecordRemove(this.model, this.onRemove);

  final ItemModel model;
  final void Function(ItemModel) onRemove;

  @override
  AppState? reduce() {
    onRemove(model);
    return null;
  }
}
