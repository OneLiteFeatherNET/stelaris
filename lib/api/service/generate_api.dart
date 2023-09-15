import 'package:dio/dio.dart';
import 'package:stelaris_ui/api/api_client.dart';

class GenerateApi {

  final ApiClient _apiClient;

  const GenerateApi(this._apiClient);

  Future<Response> generate(String branch) async {
    final queryParams = <String, dynamic>{
      "branch": branch
    };
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/generate');
    final data = await _apiClient.dio.getUri(uri).then((value) => value);
    return data;
  }

  Future<List<String>> branches() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/branches');
    final data = await _apiClient.dio.getUri(uri).then((value) {
      return value.data!;
    });
    return (data as List<dynamic>).map((e) => e as String).toList();
  }

  Future<List<int>> download(String branch) async {
    final queryParams = <String, dynamic>{
      "branch": branch
    };
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/download');
    final data = await _apiClient.dio.getUri(uri, options: Options(responseType: ResponseType.bytes)).then((value) => value.data! as List<int>);
    return data;
  }
}
