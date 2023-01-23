import 'dart:convert';
import 'dart:html' as html;
import 'dart:html';

import 'package:stelaris_ui/api/api_client.dart';

class GenerateApi {

  final ApiClient _apiClient;

  const GenerateApi(this._apiClient);


  Future<void> generate() async {
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

  Future<List<String>> branches() async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/branches');
    //final result = await _apiClient.dio.getUri(uri).then((value) => ItemModel.fromJson(value.data!));
    final data = await _apiClient.dio.getUri(uri).then((value) => jsonDecode(value.data!));
    return data as List<String>;
  }

  Future<void> download(String branch) async {
    final queryParams = <String, dynamic>{};
    final baseUri = Uri.parse(_apiClient.baseUrl);
    final uri = baseUri.replace(queryParameters: queryParams, path: '${baseUri.path}/download?branch=$branch');
    //final result = await _apiClient.dio.getUri(uri).then((value) => ItemModel.fromJson(value.data!));
    final data = await _apiClient.dio.getUri(uri).then((value) => value.data! as List<int>);
    final content = base64Encode(data);
    final anchor = AnchorElement(
        href: "data:application/octet-stream;charset=utf-16le;base64,$content")
      ..setAttribute("download", "generated.zip")
      ..click();
  }

}