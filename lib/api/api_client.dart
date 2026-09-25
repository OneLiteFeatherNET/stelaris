import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:stelaris/auth/token_source.dart';

class ApiClient {
  final String baseUrl;
  late Dio dio;

  /// Where the bearer credential comes from, or null in a deployment that
  /// configured no identity provider.
  ///
  /// Optional and named so every existing call site and test keeps compiling,
  /// and so a test can hand in a double without building a session. Omitted,
  /// this client behaves exactly as it did before authentication existed: no
  /// header, no renewal, a `401` rejected as it arrives.
  ///
  /// A client is only given one when it talks to the backend or the generator.
  /// That is what keeps the token off every other request - the configuration
  /// document, the provider's own discovery and key set - without a rule about
  /// which hosts are allowed to see it, and therefore without a rule anyone can
  /// get wrong when a new call site appears.
  final TokenSource? tokens;

  /// Marks a request that has already been retried once, so a backend that
  /// answers `401` whatever we send cannot put this in a loop.
  static const String _retriedKey = 'stelaris.auth.retried';

  /// The token a request went out with, so a `401` can tell "this token is
  /// stale" from "somebody already replaced it".
  static const String _sentTokenKey = 'stelaris.auth.sentToken';

  /// Re-issues a retry without going back through the interceptor below.
  ///
  /// It has to be a second client. [QueuedInterceptorsWrapper] serialises its
  /// callbacks, so a request started from inside `onError` would queue behind
  /// the very callback that is waiting for it.
  late final Dio _retryClient = Dio(
    BaseOptions(
      baseUrl: dio.options.baseUrl,
      connectTimeout: dio.options.connectTimeout,
      receiveTimeout: dio.options.receiveTimeout,
      sendTimeout: dio.options.sendTimeout,
    ),
  );

  ApiClient(
    this.baseUrl, {
    this.tokens,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 15),
    Duration sendTimeout = const Duration(seconds: 10),
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      ),
      // Queued, not the plain wrapper, and that is load-bearing rather than
      // incidental: it serialises interception, so a burst of requests hitting
      // an expired token cannot start a renewal each. Providers rotate refresh
      // tokens, and one presented twice ends the session for everybody.
    )..interceptors.add(
        QueuedInterceptorsWrapper(
          onRequest: (options, handler) async {
            final String? token = tokens?.accessToken;
            if (token != null) {
              options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
              options.extra[_sentTokenKey] = token;
            }
            return handler.next(options);
          },
          onError: (err, handler) async {
            if (err.error is SocketException) {
              return handler.reject(err);
            }
            if (err.response?.statusCode != null &&
                err.response!.statusCode == 401) {
              final Response<dynamic>? retried = await _retryAfterRenewal(err);
              if (retried != null) {
                return handler.resolve(retried);
              }
              return handler.reject(err);
            }
            return handler.next(err);
          },
        ),
      );
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  /// One renewal and one retry for a rejected request, or null to let the
  /// rejection stand.
  ///
  /// Null covers every case where retrying is pointless or already spent: no
  /// session to renew, a retry already made, a renewal that failed. `403` never
  /// reaches here - the credential was accepted and the action was not, which
  /// no amount of renewing changes.
  Future<Response<dynamic>?> _retryAfterRenewal(DioException err) async {
    final TokenSource? source = tokens;
    if (source == null) {
      return null;
    }

    final RequestOptions options = err.requestOptions;
    if (options.extra[_retriedKey] == true) {
      return null;
    }
    options.extra[_retriedKey] = true;

    // Somebody renewed while this request was in flight - its own 401 is stale
    // news. Renewing again would present the rotated refresh token a second
    // time, which is how a provider decides the session has been replayed.
    final String? current = source.accessToken;
    final bool alreadyRenewed =
        current != null && current != options.extra[_sentTokenKey];

    if (!alreadyRenewed && !await source.refresh()) {
      return null;
    }

    final String? token = source.accessToken;
    if (token == null) {
      return null;
    }
    options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    options.extra[_sentTokenKey] = token;

    try {
      // The adapter is read now rather than at construction: tests swap it on
      // `dio` after the client exists, and the retry has to go to the same
      // place the original request did.
      _retryClient.httpClientAdapter = dio.httpClientAdapter;
      return await _retryClient.fetch<dynamic>(options);
    } on DioException catch (_) {
      return null;
    }
  }
}
