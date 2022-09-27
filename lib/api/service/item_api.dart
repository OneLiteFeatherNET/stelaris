import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/ApiClient.dart';
import 'package:stelaris_ui/api/model/item_model.dart';

class ItemApi {
  final ApiClient apiClient;

  ItemApi(this.apiClient);

  Future<Item> getItem() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: baseUri.path + '/api/items');
    final result = await apiClient.dio.getUri(uri).then((value) => Item.fromJson(value.data!));
    return result;
  }

  Future<Item> addItem(Item item) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/item/');
    final result = await apiClient.dio.postUri(uri, data: item).then((value) => Item.fromJson(value.data!));
    return result;
  }

  Future<List<Item>> getAllItems() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/item/getAll');
    final result = await apiClient.dio.getUri(uri).then((value) => const StringToItems().fromJson(value.data!));
    return result;
  }
}

class StringToItems implements JsonConverter<List<Item>, List<dynamic>> {

  const StringToItems();

  @override
  List<Item> fromJson(List<dynamic> json) {
    return json.map((e) => Item.fromJson(e)).toList();
  }

  @override
  List<dynamic> toJson(List<Item> object) {
    throw UnimplementedError();
  }

}