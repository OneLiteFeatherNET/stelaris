import 'dart:io';

import 'package:dio/dio.dart';

class ApiClient {

  final String baseUrl;
  late Dio dio;

  ApiClient(this.baseUrl) {
    dio = Dio()
        ..options.baseUrl = baseUrl
        ..interceptors.add(
          QueuedInterceptorsWrapper(
            onRequest: (options, handler) async {
              return handler.next(options);
              /*final token = tokenProvider();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
                return handler.next(options);
              } else {
                return handler.reject(DioError(requestOptions: options));
              }*/
            },
            onError: (err, handler) {
              if (err.error is SocketException) {
                handler.reject(err);
              }
              if (err.response?.statusCode != null &&
                  err.response!.statusCode == 401) {
                handler.reject(err);
              }
              handler.reject(err);
            },
          ),
        );
    dio.interceptors.add(
        LogInterceptor(
            requestBody: true,
            responseBody: true
        )
    );
  }
}