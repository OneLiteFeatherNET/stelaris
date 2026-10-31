import 'package:stelaris/api/service/item_api.dart';
import 'package:stelaris/feature/item/components/item_model_preview_slot.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The items whose item model component names [key].
List<ItemModel> usedBy(
  String key,
  Map<ItemModel, List<ItemComponentDto>> components,
) => [
  for (final MapEntry(key: item, value: itemComponents) in components.entries)
    if (itemModelKeyOf(itemComponents) == key) item,
];

/// Loads every item of [projectId] with its data components.
///
/// The store only holds the components of the open item, so this asks the
/// backend once per item. Fine for a prototype; a query by component value in
/// the backend would replace it.
Future<Map<ItemModel, List<ItemComponentDto>>> loadItemComponents(
  ItemAPI api,
  String projectId,
) async {
  final items = <ItemModel>[];
  var page = 1;
  while (true) {
    final result = await api.getPage(
      page: page,
      size: 100,
      projectId: projectId,
    );
    items.addAll(result.items);
    if (result.items.isEmpty || page >= result.totalPages) break;
    page++;
  }
  final components = <ItemModel, List<ItemComponentDto>>{};
  for (final item in items) {
    final id = item.id;
    if (id == null) continue;
    components[item] = await _allComponents(api, id);
  }
  return components;
}

Future<List<ItemComponentDto>> _allComponents(ItemAPI api, String id) async {
  final components = <ItemComponentDto>[];
  var page = 1;
  while (true) {
    final result = await api.getComponents(id, page: page);
    components.addAll(result.items);
    if (result.items.isEmpty || page >= result.totalPages) break;
    page++;
  }
  return components;
}
