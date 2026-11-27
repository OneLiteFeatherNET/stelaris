import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/advancement_actions.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/actions/block_state_actions.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/actions/expression/expression_function_actions.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/attribute/attribute_vm_state.dart';
import 'package:stelaris/api/state/factory/blockstate/block_state_vm_state.dart';
import 'package:stelaris/api/state/factory/expression/expression_vm_state.dart';
import 'package:stelaris/api/state/factory/expression_function/expression_function_vm_state.dart';
import 'package:stelaris/api/state/factory/font/font_vm_state.dart';
import 'package:stelaris/api/state/factory/item/item_vm_state.dart';
import 'package:stelaris/api/state/factory/advancement/advancement_vm_state.dart';
import 'package:stelaris/api/state/factory/sound/sound_vm_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

/// The list pages stay mounted under their detail page, so a view model
/// that changed with the selection would rebuild the whole list each time
/// an entry is opened or closed.
void main() {
  const base = AppState(
    selectedProject: Project(displayName: 'P', id: 'proj-1', key: 'p'),
  );

  /// Whether [factory]'s view model is the same with and without [selected].
  bool unchangedBySelection(
    VmFactory<AppState, Widget?, Vm> Function() factory,
    AppState selected,
  ) {
    final before = Vm.createFrom(
      Store<AppState>(initialState: base),
      factory(),
    );
    final after = Vm.createFrom(
      Store<AppState>(initialState: selected),
      factory(),
    );
    return before == after;
  }

  group('list view models ignore the selection', () {
    test('items', () {
      expect(
        unchangedBySelection(
          ItemVmFactory.new,
          base.copyWith(selectedItem: const ItemModel(uiName: 'Sword')),
        ),
        isTrue,
      );
    });

    test('fonts', () {
      expect(
        unchangedBySelection(
          FontVmFactory.new,
          base.copyWith(selectedFont: const FontModel(uiName: 'Runes')),
        ),
        isTrue,
      );
    });

    test('sounds', () {
      expect(
        unchangedBySelection(
          SoundVmFactory.new,
          base.copyWith(selectedSoundEvent: SoundEventModel(uiName: 'Break')),
        ),
        isTrue,
      );
    });

    test('advancements', () {
      expect(
        unchangedBySelection(
          AdvancementVmFactory.new,
          base.copyWith(
            selectedAdvancement: const AdvancementModel(uiName: 'Done'),
          ),
        ),
        isTrue,
      );
    });

    test('attributes', () {
      expect(
        unchangedBySelection(
          AttributeVmFactory.new,
          base.copyWith(
            selectedAttribute: const AttributeModel(uiName: 'Mana'),
          ),
        ),
        isTrue,
      );
    });
  });

  /// A list of [first] with a second page left to load.
  PaginatedResult<T> twoPages<T>(T first) => PaginatedResult<T>(
    items: [first],
    totalItems: 2,
    totalPages: 2,
    currentPage: 1,
    pageSize: 1,
  );

  /// The list page shows its load-more footer from [isLoadingMore] of its
  /// view model, which only rebuilds the page when the view model changes.
  group('list view models tell while the next page loads', () {
    final cases =
        <
          String,
          (
            AppState,
            VmFactory<AppState, Widget?, Vm> Function(),
            ReduxAction<AppState> Function(),
            bool Function(Vm vm),
          )
        >{
          'items': (
            base.copyWith(items: twoPages(const ItemModel(uiName: 'a'))),
            ItemVmFactory.new,
            LoadMoreItemsAction.new,
            (vm) => (vm as ItemViewModel).isLoadingMore,
          ),
          'advancements': (
            base.copyWith(
              advancements: twoPages(const AdvancementModel(uiName: 'a')),
            ),
            AdvancementVmFactory.new,
            LoadMoreAdvancementsAction.new,
            (vm) => (vm as AdvancementViewModel).isLoadingMore,
          ),
          'attributes': (
            base.copyWith(
              attributes: twoPages(const AttributeModel(uiName: 'a')),
            ),
            AttributeVmFactory.new,
            LoadMoreAttributesAction.new,
            (vm) => (vm as AttributeViewModel).isLoadingMore,
          ),
          'fonts': (
            base.copyWith(fonts: twoPages(const FontModel(uiName: 'a'))),
            FontVmFactory.new,
            LoadMoreFontsAction.new,
            (vm) => (vm as FontViewModel).isLoadingMore,
          ),
          'sounds': (
            base.copyWith(soundEvents: twoPages(SoundEventModel(uiName: 'a'))),
            SoundVmFactory.new,
            LoadMoreSoundEventsAction.new,
            (vm) => (vm as SoundViewModel).isLoadingMore,
          ),
          'expressions': (
            base.copyWith(
              expressions: twoPages(const ExpressionModel(uiName: 'a')),
            ),
            ExpressionVmFactory.new,
            LoadMoreExpressionsAction.new,
            (vm) => (vm as ExpressionViewModel).isLoadingMore,
          ),
          'functions': (
            base.copyWith(
              expressionFunctions: twoPages(
                const ExpressionFunctionModel(uiName: 'a', name: 'a'),
              ),
            ),
            ExpressionFunctionVmFactory.new,
            LoadMoreExpressionFunctionsAction.new,
            (vm) => (vm as ExpressionFunctionViewModel).isLoadingMore,
          ),
          'blockstates': (
            base.copyWith(
              blockStates: twoPages(const BlockStateModel(uiName: 'a')),
            ),
            BlockStateVmFactory.new,
            LoadMoreBlockStatesAction.new,
            (vm) => (vm as BlockStateViewModel).isLoadingMore,
          ),
        };

    for (final MapEntry(
          key: name,
          value: (state, factory, loadMore, isLoadingMore),
        )
        in cases.entries) {
      test(name, () async {
        final store = Store<AppState>(initialState: state);
        bool? whileLoading;
        ApiService().itemApi.apiClient.dio.httpClientAdapter =
            FakeHttpClientAdapter((options) {
              whileLoading = isLoadingMore(Vm.createFrom(store, factory()));
              return FakeHttpClientAdapter.response({
                'items': <Object>[],
                'totalItems': 1,
                'totalPages': 1,
                'currentPage': 2,
                'pageSize': 1,
              });
            });

        expect(isLoadingMore(Vm.createFrom(store, factory())), isFalse);
        await store.dispatchAndWait(loadMore());

        expect(whileLoading, isTrue);
        expect(isLoadingMore(Vm.createFrom(store, factory())), isFalse);
      });
    }
  });
}
