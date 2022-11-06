import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/ApiClient.dart';

import '../model/block_model.dart';

class BlockAPI {

  final ApiClient apiClient;

  BlockAPI(this.apiClient);

  Future<BlockModel> getBlock() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/api/block');
    final result = await apiClient.dio.getUri(uri).then((value) => BlockModel.fromJson(value.data!));
    return result;
  }

  Future<BlockModel> addBlock(BlockModel block) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/block/');
    final result = await apiClient.dio.postUri(uri, data: block).then((value) => BlockModel.fromJson(value.data!));
    return result;
  }

  Future<List<BlockModel>> getAllBlocks() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/block/getAll');
    final result = await apiClient.dio.getUri(uri).then((value) => const StringToBlock().fromJson(value.data!));
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
