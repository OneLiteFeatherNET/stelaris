import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  final String baseUrl;
  late Dio dio;

  ApiClient(
    this.baseUrl, {
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
    )..interceptors.add(
        QueuedInterceptorsWrapper(
          onRequest: (options, handler) async {
            return handler.next(options);
          },
          onError: (err, handler) {
            if (err.error is SocketException) {
              return handler.reject(err);
            }
            if (err.response?.statusCode != null &&
                err.response!.statusCode == 401) {
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
}
