import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/service/item_api.dart';
import 'package:stelaris/feature/asset/models/model_usage.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

ItemComponentDto _itemModel(String key) =>
    ItemComponentDto(componentKey: 'minecraft:item_model', value: key);

Map<String, Object?> _page(List<Object?> items, {int totalPages = 1}) => {
  'items': items,
  'totalItems': items.length,
  'totalPages': totalPages,
  'currentPage': 0,
  'pageSize': items.length,
};

void main() {
  const ruby = ItemModel(uiName: 'Ruby', id: 'i1');
  const sword = ItemModel(uiName: 'Sword', id: 'i2');
  const plain = ItemModel(uiName: 'Plain', id: 'i3');

  group('usedBy', () {
    final components = {
      ruby: [_itemModel('vulpes:item/ruby')],
      sword: [_itemModel('vulpes:item/sword')],
      plain: [
        const ItemComponentDto(componentKey: 'minecraft:food', value: {}),
      ],
    };

    test('keeps the items whose item model is the key', () {
      expect(usedBy('vulpes:item/ruby', components), [ruby]);
    });

    test('is empty when no item uses the key', () {
      expect(usedBy('vulpes:item/axe', components), isEmpty);
    });

    test('skips items without an item model', () {
      expect(usedBy('minecraft:food', components), isEmpty);
    });
  });

  test('loadItemComponents reads every item page and its components', () async {
    final apiClient = ApiClient('http://backend.test/api');
    final requested = <String>[];
    apiClient.dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      final path = options.uri.path;
      final page = options.uri.queryParameters['page'];
      requested.add('$path?page=$page');
      if (path.endsWith('/components')) {
        final id = path.split('/').reversed.elementAt(1);
        return FakeHttpClientAdapter.response(
          _page([
            {'componentKey': 'minecraft:item_model', 'value': 'vulpes:$id'},
          ]),
        );
      }
      return FakeHttpClientAdapter.response(
        _page([
          page == '0'
              ? {'id': 'i1', 'uiName': 'Ruby'}
              : {'id': 'i2', 'uiName': 'Sword'},
        ], totalPages: 2),
      );
    });

    final result = await loadItemComponents(
      ItemAPI(apiClient: apiClient),
      'p-1',
    );

    expect(result.keys.map((item) => item.id), ['i1', 'i2']);
    expect(result.values.map((components) => components.single.value), [
      'vulpes:i1',
      'vulpes:i2',
    ]);
  });
}
