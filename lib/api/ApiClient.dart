

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {

  final String baseUrl;
  late Dio dio;

  ApiClient(this.baseUrl) {
    dio = Dio()
        ..options.baseUrl = baseUrl
        ..interceptors.add(
          QueuedInterceptorsWrapper(
            // Für token injection
            onRequest: (options, handler) async {

            },
              // Error Handlen
            onError: (error, handler) {

            }
          )
        );
    if (!kReleaseMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true
        )
      );
    }
  }
}