import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/service/generator/generator_api.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Client API for the vulpes-generator, the service behind the generator page.
///
/// Unlike the backend clients, this one is not left to throw a `DioException`
/// for the UI to read: the generator's error body (`reason`, `message`,
/// `diagnostics`) is not a backend problem detail, so every failure is
/// converted here into a [GeneratorApiException] with the [GeneratorFailure]
/// the page shows.
class GeneratorClientApi implements GeneratorApi {
  final ApiClient apiClient;

  GeneratorClientApi({required this.apiClient});

  /// A local build or a publish clones and, for a new vulpes-base commit,
  /// builds the base first, which the service allows up to about twelve
  /// minutes for.
  static const Duration buildTimeout = Duration(minutes: 15);

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final Uri base = Uri.parse(apiClient.baseUrl);
    return base.replace(
      path: '${base.path}$path',
      queryParameters: query == null || query.isEmpty ? null : query,
    );
  }

  @override
  Future<List<String>> branches() => _guard(() async {
    final response = await apiClient.dio.getUri(_uri('/git/branches'));
    return (response.data as List<dynamic>).cast<String>();
  });

  @override
  Future<LocalBuildFile> localBuild(Project project, String baseBranch) async {
    final String id = _idOf(project);
    return _download(
      _uri('/projects/${Uri.encodeComponent(id)}/local-build', {
        'baseBranch': baseBranch,
      }),
      fallbackName: '${project.key}-local.zip',
    );
  }

  @override
  Future<PublishResult> publish(
    Project project,
    String version,
    String baseBranch,
  ) async {
    final String id = _idOf(project);
    return _guard(() async {
      final response = await apiClient.dio.postUri(
        _uri('/generator/release'),
        data: {'projectId': id, 'version': version, 'baseBranch': baseBranch},
        options: Options(receiveTimeout: buildTimeout),
      );
      return PublishResult.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<List<PublishedVersion>> publishedVersions(Project project) async {
    final String id = _idOf(project);
    return _guard(() async {
      final response = await apiClient.dio.getUri(
        _uri('/projects/${Uri.encodeComponent(id)}/releases'),
      );
      final Object? data = response.data;
      // The list sits next to `latest` in the answer; a bare list is read too.
      final Object? entries = data is Map<String, dynamic>
          ? data['versions']
          : data;
      return [
        for (final entry in (entries as List<dynamic>? ?? const []))
          PublishedVersion.fromJson(entry as Map<String, dynamic>),
      ];
    });
  }

  @override
  Future<LocalBuildFile> publishedVersionBuild(
    Project project,
    String version,
  ) async {
    final String id = _idOf(project);
    return _download(
      _uri(
        '/projects/${Uri.encodeComponent(id)}/releases/'
        '${Uri.encodeComponent(version)}/local-build',
      ),
      fallbackName: '${project.key}-$version.zip',
    );
  }

  Future<LocalBuildFile> _download(Uri uri, {required String fallbackName}) =>
      _guard(() async {
        final response = await apiClient.dio.getUri<List<int>>(
          uri,
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: buildTimeout,
          ),
        );
        return LocalBuildFile(
          Uint8List.fromList(response.data ?? const []),
          _filenameOf(response.headers.value('content-disposition')) ??
              fallbackName,
        );
      });

  static String _idOf(Project project) {
    final String? id = project.id;
    if (id == null || id.isEmpty) {
      throw const GeneratorApiException(
        GeneratorFailure(GeneratorFailureKind.unexpected),
      );
    }
    return id;
  }

  static String? _filenameOf(String? contentDisposition) {
    if (contentDisposition == null) return null;
    final match = RegExp(r'filename="?([^";]+)"?')
        .firstMatch(contentDisposition);
    return match?.group(1)?.trim();
  }

  static Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on GeneratorApiException {
      rethrow;
    } on DioException catch (error) {
      throw GeneratorApiException(failureOf(error));
    } catch (error) {
      // An answer the page cannot read is as unexpected as a 500. The raw
      // error is for the console, not for the page.
      debugPrint('Unreadable generator answer: $error');
      throw const GeneratorApiException(
        GeneratorFailure(GeneratorFailureKind.unexpected),
      );
    }
  }

  /// Maps a failed request to what the page shows for it.
  static GeneratorFailure failureOf(DioException error) {
    final Response<dynamic>? response = error.response;
    if (response == null) {
      debugPrint('Generator not reachable: $error');
      return const GeneratorFailure(GeneratorFailureKind.network);
    }
    final int? status = response.statusCode;
    final Map<String, dynamic>? body = _bodyOf(response.data);
    final kind = switch (status) {
      409 => GeneratorFailureKind.versionExists,
      422 => GeneratorFailureKind.rejected,
      502 => GeneratorFailureKind.unavailable,
      _ => GeneratorFailureKind.unexpected,
    };
    final Object? diagnostics = body?['diagnostics'];
    return GeneratorFailure(
      kind,
      statusCode: status,
      // A 502 names the infrastructure behind the generator (hosts,
      // repositories), which the page has no business showing; its fixed
      // text says enough.
      message: kind == GeneratorFailureKind.unavailable
          ? null
          : body?['message'] as String?,
      diagnostics: [
        if (diagnostics is List)
          for (final entry in diagnostics)
            if (entry is Map<String, dynamic>) Diagnostic.fromJson(entry),
      ],
      truncated: body?['truncated'] == true,
    );
  }

  /// The error body is JSON, but a download asked for bytes, so it may
  /// arrive as such.
  static Map<String, dynamic>? _bodyOf(Object? data) {
    if (data is Map<String, dynamic>) return data;
    try {
      final Object? decoded = switch (data) {
        final List<int> bytes => jsonDecode(utf8.decode(bytes)),
        final String text => jsonDecode(text),
        _ => null,
      };
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }
}
