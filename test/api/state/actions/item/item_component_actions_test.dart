import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/item/item_component_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../../support/recording_http_client_adapter.dart';

void main() {
  const item = ItemModel(id: 'item-1', uiName: 'Apple');
  const food = ItemComponentDto(
    id: 'c1',
    componentKey: 'minecraft:food',
    value: {'nutrition': 4, 'saturation': 2.4},
  );
  const glider = ItemComponentDto(
    id: 'c2',
    componentKey: 'minecraft:glider',
    value: <String, Object?>{},
  );

  Store<AppState> storeWith(List<ItemComponentDto> components) =>
      Store<AppState>(
        initialState: const AppState().copyWith(
          selectedItem: item,
          selectedItemComponents: components,
        ),
      );

  RecordingHttpClientAdapter respondWith(Object? json) {
    final adapter = RecordingHttpClientAdapter(json);
    ApiService().itemApi.apiClient.dio.httpClientAdapter = adapter;
    return adapter;
  }

  test('fetch loads the components of the selected item', () async {
    final store = storeWith(const []);
    final adapter = respondWith({
      'items': [food.toJson(), glider.toJson()],
      'totalItems': 2,
      'totalPages': 1,
      'currentPage': 0,
      'pageSize': 100,
    });

    await store.dispatchAndWait(ItemComponentFetchAction());

    expect(adapter.lastRequest!.uri.path, '/item/item-1/components');
    expect(store.state.selectedItemComponents, [food, glider]);
  });

  test('add appends the component the backend returns', () async {
    final store = storeWith(const [food]);
    final adapter = respondWith(glider.toJson());

    await store.dispatchAndWait(
      ItemComponentAddAction(
        const ItemComponentDto(
          componentKey: 'minecraft:glider',
          value: <String, Object?>{},
        ),
      ),
    );

    expect(adapter.lastRequest!.method, 'PUT');
    expect(store.state.selectedItemComponents, [food, glider]);
  });

  test('update replaces the component with the same id', () async {
    final store = storeWith(const [food, glider]);
    final changed = food.copyWith(value: {'nutrition': 8, 'saturation': 1.0});
    respondWith(changed.toJson());

    await store.dispatchAndWait(ItemComponentUpdateAction(changed));

    expect(store.state.selectedItemComponents.first.value, {
      'nutrition': 8,
      'saturation': 1.0,
    });
    expect(store.state.selectedItemComponents.last, glider);
  });

  test('delete removes the component', () async {
    final store = storeWith(const [food, glider]);
    final adapter = respondWith(food.toJson());

    await store.dispatchAndWait(ItemComponentDeleteAction(food));

    expect(adapter.lastRequest!.uri.path, '/item/item-1/component/c1');
    expect(store.state.selectedItemComponents, [glider]);
  });

  test('selecting another item clears the components', () async {
    final store = storeWith(const [food]);

    await store.dispatchAndWait(
      SelectedItemAction(const ItemModel(id: 'item-2', uiName: 'Stick')),
    );
    expect(store.state.selectedItemComponents, isEmpty);

    store.dispatch(SelectedItemAction(item));
    await store.dispatchAndWait(RemoveSelectItemAction());
    expect(store.state.selectedItemComponents, isEmpty);
  });
}
