import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/api_client.dart';

import '../model/block_model.dart';

class BlockAPI {

  final ApiClient _apiClient;

  final StringToBlock _formatter = const StringToBlock();

  BlockAPI(this._apiClient);

  Future<BlockModel> getBlock() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/api/block');
    final result = await _apiClient.dio.getUri(uri).then((value) => BlockModel.fromJson(value.data!));
    return result;
  }

  Future<BlockModel> addBlock(BlockModel block) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/block/');
    final result = await _apiClient.dio.postUri(uri, data: block).then((value) => BlockModel.fromJson(value.data!));
    return result;
  }

  Future<List<BlockModel>> getAllBlocks() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/block/getAll');
    final result = await _apiClient.dio.getUri(uri).then((value) => _formatter.fromJson(value.data!));
    return result;
  }

  Future<BlockModel> update(BlockModel model) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/block/update');
    final result = await _apiClient.dio.postUri(uri, data: model.toJson()).then((value) => BlockModel.fromJson(value.data!));
    return result;
  }
}

class StringToBlock implements JsonConverter<List<BlockModel>, List<dynamic>> {

  const StringToBlock();

  @override
  List<BlockModel> fromJson(List<dynamic> json) {
    return json.map((e) => BlockModel.fromJson(e)).toList();
  }

  @override
  List<dynamic> toJson(List<BlockModel> object) {
    throw UnimplementedError();
  }
}
