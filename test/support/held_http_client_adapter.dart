import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'fake_http_client_adapter.dart';

/// An [HttpClientAdapter] double that holds every request open until
/// [release] answers it with a JSON payload, so a test can look at what
/// shows while an action waits for the backend.
class HeldHttpClientAdapter implements HttpClientAdapter {
  final Completer<ResponseBody> _response = Completer<ResponseBody>();

  /// Answers the held requests with [json].
  void release(Object? json) =>
      _response.complete(FakeHttpClientAdapter.response(json));

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _response.future;

  @override
  void close({bool force = false}) {}
}
