import 'package:stelaris_ui/api/api_client.dart';
import 'package:stelaris_ui/api/client_api.dart';
import 'package:stelaris_ui/api/converter/model_list_converter.dart';
import 'package:stelaris_ui/api/model/block_model.dart';

class BlockAPI implements ClientAPI<BlockModel> {

  final ApiClient _apiClient;
  final ModelListConverter<BlockModel> _formatter = ModelListConverter((p0) => BlockModel.fromJson(p0));

  BlockAPI(this._apiClient);

  @override
  Future<BlockModel> get() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/block');
    final result = await _apiClient.dio.getUri(uri).then((value) => BlockModel.fromJson(value.data!));
    return result;
  }

  @override
  Future<BlockModel> add(BlockModel block) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/block');
    final result = await _apiClient.dio.postUri(uri, data: block.toJson()).then((value) => BlockModel.fromJson(value.data!));
    return result;
  }

  @override
  Future<List<BlockModel>> getAll() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/block/getAll');
    final result = await _apiClient.dio.getUri(uri).then((value) => _formatter.fromJson(value.data!));
    return result;
  }

  @override
  Future<BlockModel> update(BlockModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/block/update');
    final result = await _apiClient.dio.postUri(uri, data: model.toJson()).then((value) => BlockModel.fromJson(value.data!));
    return result;
  }

  @override
  Future<BlockModel> remove(BlockModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/block/remove/${model.id}');
    final result = await _apiClient.dio.deleteUri(uri).then((value) => BlockModel.fromJson(value.data!));
    return result;
  }
}
