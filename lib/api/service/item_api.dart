import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/model/item/item_enchantment_model.dart';
import 'package:stelaris/api/model/item/item_flag_model.dart';
import 'package:stelaris/api/model/item/item_lore_model.dart';
import 'package:stelaris/api/model/item_model.dart';

class ItemAPI extends BaseApi<ItemModel> {

  ItemAPI({required super.apiClient})
      : super(
    endpoint: 'item',
    fromJson: (p0) => ItemModel.fromJson(p0),
    toJson: (model) => model.toJson(),
  );

  Future<ItemEnchantmentModel> getEnchantments(String id) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint/enchantments/$id');
    final result = await apiClient.dio.getUri(uri);
    return ItemEnchantmentModel.fromJson(result.data!);
  }

  Future<ItemLoreModel> getLore(String id) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint/lore/$id');
    final result = await apiClient.dio.getUri(uri);
    return ItemLoreModel.fromJson(result.data!);
  }

  Future<ItemFlagModel> getFlags(String id) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint/flags/$id');
    final result = await apiClient.dio.getUri(uri);
    return ItemFlagModel.fromJson(result.data!);
  }
}