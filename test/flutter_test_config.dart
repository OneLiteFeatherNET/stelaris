import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_service.dart';

/// Runs around the tests of every file.
///
/// Tests fake the backend by swapping the adapter of the client all of
/// [ApiService]'s model APIs share. Without a reset, a test that fakes
/// nothing would get the answers the test before it set up.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  tearDown(() {
    ApiService().itemApi.apiClient.dio.httpClientAdapter = HttpClientAdapter();
  });
  await testMain();
}
