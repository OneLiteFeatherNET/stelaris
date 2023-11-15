import 'package:stelaris_ui/api/api_client.dart';
import 'package:stelaris_ui/api/client_api.dart';
import 'package:stelaris_ui/api/converter/ModeListConverter.dart';
import 'package:stelaris_ui/api/model/item_model.dart';

class ItemApi implements ClientAPI<ItemModel> {
  final ApiClient _apiClient;
  final ModelListConverter<ItemModel> _formatter = ModelListConverter((p0) => ItemModel.fromJson(p0));

  ItemApi(this._apiClient);

  @override
  Future<ItemModel> get() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(
        queryParameters: queryParams, path: '${baseUri.path}/api/items');
    final result = await _apiClient.dio.getUri(uri).then((value) =>
        ItemModel.fromJson(value.data!));
    return result;
  }

  @override
  Future<ItemModel> add(ItemModel item) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(
        queryParameters: queryParams, path: '${baseUri.path}/item');
    final result = await _apiClient.dio.postUri(uri, data: item.toJson()).then((
        value) => ItemModel.fromJson(value.data!));
    return result;
  }

  @override
  Future<List<ItemModel>> getAll() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(
        queryParameters: queryParams, path: '${baseUri.path}/item/getAll');
    final result = await _apiClient.dio.getUri(uri).then((value) =>
        _formatter.fromJson(value.data!));
    return result;
  }

  @override
  Future<ItemModel> update(ItemModel itemModel) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(
        queryParameters: queryParams, path: '${baseUri.path}/item/update');
    final result = await _apiClient.dio.postUri(uri, data: itemModel.toJson())
        .then((value) => ItemModel.fromJson(value.data!));
    return result;
  }

  @override
  Future<ItemModel> remove(ItemModel itemModel) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams,
        path: '${baseUri.path}/item/remove/${itemModel.id}');
    final result = await _apiClient.dio.deleteUri(uri).then((value) =>
        ItemModel.fromJson(value.data!));
    return result;
  }
}
