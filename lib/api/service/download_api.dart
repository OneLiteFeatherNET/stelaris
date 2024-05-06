import 'package:stelaris_ui/api/api_client.dart';

class DownloadAPI  {

  final ApiClient _apiClient;

  DownloadAPI(this._apiClient);

  Future<String> download(String branch) async {
    final queryParams = <String, dynamic>{
      "branch" : branch
    };
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/download');
    final result = await _apiClient.dio.getUri(uri).then((value) => value.data!);
    return result;
  }
}