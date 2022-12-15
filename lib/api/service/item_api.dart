import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/api_client.dart';
import 'package:stelaris_ui/api/model/item_model.dart';

class ItemApi {
  final ApiClient apiClient;

  final StringToItems _formatter = const StringToItems();

  ItemApi(this.apiClient);

  Future<ItemModel> getItem() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/api/items');
    final result = await apiClient.dio.getUri(uri).then((value) => ItemModel.fromJson(value.data!));
    return result;
  }

  Future<ItemModel> addItem(ItemModel item) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/item/');
    final result = await apiClient.dio.postUri(uri, data: item).then((value) => ItemModel.fromJson(value.data!));
    return result;
  }

  Future<List<ItemModel>> getAllItems() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/item/getAll');
    final result = await apiClient.dio.getUri(uri).then((value) => _formatter.fromJson(value.data!));
    return result;
  }
}

class StringToItems implements JsonConverter<List<ItemModel>, List<dynamic>> {

  const StringToItems();

  @override
  List<ItemModel> fromJson(List<dynamic> json) {
    return json.map((e) => ItemModel.fromJson(e)).toList();
  }

  @override
  List<dynamic> toJson(List<ItemModel> object) {
    throw UnimplementedError();
  }

}