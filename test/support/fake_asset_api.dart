import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:stelaris/api/api_service.dart';

import 'fake_http_client_adapter.dart';

/// The JSON of an asset as the backend returns it.
Map<String, Object?> assetJson({
  required String id,
  required String key,
  required String kind,
  String projectId = 'p-1',
}) => {
  'id': id,
  'projectId': projectId,
  'key': key,
  'kind': kind,
  'fileName': '$id.json',
  'contentType': 'application/json',
  'size': 64,
  'sha1': 'sha-$id',
  'derivedAssetIds': <String>[],
};

/// Serves [assets] per kind from the list endpoint, and an empty Minecraft
/// model for every content request, through the shared [ApiService].
void serveAssets(List<Map<String, Object?>> assets) {
  ApiService().assetApi.apiClient.dio.httpClientAdapter = FakeHttpClientAdapter(
    (options) {
      if (options.uri.path.endsWith('/content')) {
        return ResponseBody.fromBytes(
          utf8.encode(jsonEncode({'elements': <Object?>[]})),
          200,
        );
      }
      final kind = options.uri.queryParameters['kind'];
      final items = [
        for (final asset in assets)
          if (asset['kind'] == kind) asset,
      ];
      return FakeHttpClientAdapter.response({
        'items': items,
        'totalItems': items.length,
        'totalPages': 1,
        'currentPage': 0,
        'pageSize': 50,
      });
    },
  );
}
