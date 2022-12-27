import 'dart:html' as html;

import 'package:stelaris_ui/api/api_client.dart';

class GenerateApi {

  final ApiClient _apiClient;

  const GenerateApi(this._apiClient);


  Future<void> download() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    /*final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/generate');
    //final result = await _apiClient.dio.getUri(uri).then((value) => ItemModel.fromJson(value.data!));
    final data = await _apiClient.dio.getUri(uri).then((value) => value.data!);
    final uriStream = Uri.dataFromBytes(data);*/
    html.AnchorElement anchorElement = html.AnchorElement(href: '${baseUri.path}/generate');
    anchorElement.download = 'generated.zip';
    anchorElement.click();

  }

}