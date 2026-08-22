import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A minimal [HttpClientAdapter] double that never touches the network.
///
/// [ApiClient.dio.httpClientAdapter] is public and mutable, so this can be
/// swapped in for [ApiService]'s shared client in tests without touching any
/// production code.
class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this._handler);

  final ResponseBody Function(RequestOptions options) _handler;

  /// Responds with the given [json] payload and [statusCode] to any request.
  factory FakeHttpClientAdapter.json(
    Object? json, {
    int statusCode = 200,
  }) {
    return FakeHttpClientAdapter(
      (_) => ResponseBody.fromString(
        jsonEncode(json),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => _handler(options);

  @override
  void close({bool force = false}) {}
}
