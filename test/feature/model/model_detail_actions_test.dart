import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/dialogs/model_info_dialog.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/held_http_client_adapter.dart';

void main() {
  const item = ItemModel(id: 'item-1', uiName: 'Ruby Sword', key: 'ruby');

  late Store<AppState> store;
  ItemModel? removed;

  Future<void> pump(
    WidgetTester tester,
    AppState state, {
    bool withDelete = true,
  }) async {
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
                      removeAction: withDelete
                          ? (m) => _RecordRemove(m, (v) => removed = v)
                          : null,
                      readNotes: (m) => m.comment,
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
          localizationsDelegates: appLocalizationsDelegates,
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

  testWidgets('save shows that it saves while the section is saved, also '
      'when the save was started elsewhere', (tester) async {
    await pump(
      tester,
      const AppState(
        selectedItem: item,
        unsavedChanges: NavigationEntry.items,
      ),
    );
    final backend = HeldHttpClientAdapter();
    ApiService().itemApi.apiClient.dio.httpClientAdapter = backend;
    PageHeaderAction save() => tester.widget<PageHeaderAction>(
      find.ancestor(
        of: find.text('Save'),
        matching: find.byType(PageHeaderAction),
      ),
    );

    // As the unsaved changes dialog does, not through the button.
    store.dispatch(ItemDatabaseUpdate());
    // A connector hears of the store through a stream, a frame later.
    await tester.pump();
    await tester.pump();
    expect(save().loading, isTrue);

    backend.release({'id': 'item-1', 'uiName': 'Ruby Sword', 'key': 'ruby'});
    await tester.pumpAndSettle();
    expect(save().loading, isFalse);
  });

  testWidgets('info opens the model info dialog', (tester) async {
    await pump(tester, const AppState(selectedItem: item));

    await tester.tap(find.text('Info'));
    await tester.pumpAndSettle();

    expect(find.byType(ModelInfoDialog), findsOneWidget);
  });

  Badge notesBadge(WidgetTester tester) =>
      tester.widget<Badge>(find.byType(Badge));

  testWidgets('the notes action only shows its indicator when there are '
      'notes', (tester) async {
    await pump(tester, const AppState(selectedItem: item));
    expect(notesBadge(tester).isLabelVisible, isFalse);

    store.dispatch(UpdateItemAction(item.copyWith(comment: 'Boss drop')));
    await tester.pumpAndSettle();
    expect(notesBadge(tester).isLabelVisible, isTrue);
  });

  testWidgets('the notes action is disabled without notes', (tester) async {
    await pump(tester, const AppState(selectedItem: item));

    final notes = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Notes'),
        matching: find.bySubtype<FilledButton>(),
      ),
    );
    expect(notes.onPressed, isNull);
  });

  testWidgets('the notes open read-only and change nothing', (tester) async {
    await pump(
      tester,
      AppState(selectedItem: item.copyWith(comment: 'Boss drop\nNether only')),
    );

    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();

    expect(find.text('Notes for Ruby Sword'), findsOneWidget);
    expect(find.text('Boss drop\nNether only'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(store.state.unsavedChanges, isNull);
  });

  testWidgets('without a remove action the header has no Delete', (
    tester,
  ) async {
    await pump(tester, const AppState(selectedItem: item), withDelete: false);

    expect(find.text('Delete'), findsNothing);
    expect(find.text('Info'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
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
