import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:stelaris/api/api_service.dart';

import 'fake_http_client_adapter.dart';

/// The JSON of an asset as the backend returns it.
Map<String, Object?> assetJson({
  required String id,
  required String key,
  required String kind,
  String? displayName,
  String projectId = 'p-1',
}) => {
  'id': id,
  'projectId': projectId,
  'key': key,
  'displayName': displayName ?? 'Name of $id',
  'kind': kind,
  'fileName': '$id.json',
  'contentType': 'application/json',
  'size': 64,
  'sha1': 'sha-$id',
  'derivedAssetIds': <String>[],
};

/// What [serveAssets] answered, so a test can wait for a lookup to finish.
class ServedAssets {
  /// Every request the fake received, in order.
  final List<RequestOptions> requests = [];

  /// The `kind` of each list request whose response was read in full, and
  /// `content` for each content request.
  final List<String?> answeredKinds = [];

  /// Passes [body] on, and records the list request of [kind] as answered
  /// once Dio has read the whole response.
  ResponseBody _answer(String? kind, ResponseBody body) => ResponseBody(
    body.stream.transform(
      StreamTransformer<Uint8List, Uint8List>.fromHandlers(
        handleDone: (sink) {
          answeredKinds.add(kind);
          sink.close();
        },
      ),
    ),
    body.statusCode,
    headers: body.headers,
  );
}

/// Serves [assets] per kind from the list endpoint, and an empty Minecraft
/// model for every content request, through the shared [ApiService].
///
/// Returns what was requested and answered.
ServedAssets serveAssets(List<Map<String, Object?>> assets) {
  final served = ServedAssets();
  ApiService().assetApi.apiClient.dio.httpClientAdapter = FakeHttpClientAdapter(
    (options) {
      served.requests.add(options);
      if (options.uri.path.endsWith('/content')) {
        return served._answer(
          'content',
          ResponseBody.fromBytes(
            utf8.encode(jsonEncode({'elements': <Object?>[]})),
            200,
          ),
        );
      }
      final kind = options.uri.queryParameters['kind'];
      final items = [
        for (final asset in assets)
          if (asset['kind'] == kind) asset,
      ];
      return served._answer(
        kind,
        FakeHttpClientAdapter.response({
          'items': items,
          'totalItems': items.length,
          'totalPages': 1,
          'currentPage': 0,
          'pageSize': 50,
        }),
      );
    },
  );
  return served;
}
