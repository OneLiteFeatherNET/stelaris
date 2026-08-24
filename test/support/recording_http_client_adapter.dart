import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'fake_http_client_adapter.dart';

/// A [HttpClientAdapter] fake that records the [RequestOptions] of the
/// last request it received and responds with a canned JSON [json] payload.
class RecordingHttpClientAdapter implements HttpClientAdapter {
  RecordingHttpClientAdapter(this.json, {this.statusCode = 200});

  final Object? json;
  final int statusCode;

  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return FakeHttpClientAdapter.json(
      json,
      statusCode: statusCode,
    ).fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {}
}
