import 'package:dio/dio.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris_models/stelaris_models.dart';

class GenerateApi {
  final ApiClient _apiClient;

  const GenerateApi(this._apiClient);

  Future<Response> generate(String branch) async {
    final queryParams = <String, dynamic>{'branch': branch};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(
      queryParameters: queryParams,
      path: '${baseUri.path}/generate',
    );
    final data = await _apiClient.dio.getUri(uri).then((value) => value);
    return data;
  }

  Future<List<String>> branches() async {
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/git/branches');
    final data = await _apiClient.dio.getUri(uri).then((value) {
      return value.data!;
    });
    return (data as List<dynamic>).map((e) => e as String).toList();
  }

  Future<(List<int>, String)> download(String branch, String projectId) async {
    final queryParams = <String, dynamic>{
      'branch': branch,
      'projectId': projectId,
    };
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(
      queryParameters: queryParams,
      path: '${baseUri.path}/download',
    );

    final response = await _apiClient.dio.getUri(
      uri,
      options: Options(responseType: ResponseType.bytes),
    );

    final contentDisposition = response.headers.value('content-disposition');
    String filename = 'vulpes-$branch.zip';

    if (contentDisposition != null) {
      final regex = RegExp(r'filename="?([^";\s]+)"?');
      final match = regex.firstMatch(contentDisposition);
      if (match != null) {
        filename = match.group(1)!;
      }
    }

    return (response.data! as List<int>, filename);
  }

  Future<ReleaseModel> buildInformation() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(
      queryParameters: queryParams,
      path: '${baseUri.path}/build/data',
    );
    return await _apiClient.dio.getUri(uri).then((value) {
      return ReleaseModel.fromJson(value.data! as Map<String, dynamic>);
    });
  }
}
