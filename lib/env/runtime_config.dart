import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:stelaris/env/environment.dart';

/// Settings the app reads when it starts instead of at build time.
///
/// The container image is built once and promoted from staging to production,
/// so the backend it talks to must not be compiled into the bundle - an image
/// that only works in one environment cannot be promoted between them. The web
/// server renders [configFileName] from its own environment and the app adopts
/// whatever it finds there.
///
/// [Environment] stays the source for a local `flutter run`, where nothing
/// serves a configuration: its values are the fallback for every field the
/// served configuration leaves empty.
@immutable
class RuntimeConfig {
  const RuntimeConfig({required this.backendUrl, required this.generatorUrl});

  /// The document the web server renders from its environment.
  ///
  /// Relative on purpose: it resolves against the base href, so a deployment
  /// under a sub path keeps working.
  static const String configFileName = 'config.json';

  /// Values compiled into the bundle. Used unchanged when nothing is served.
  static const RuntimeConfig compiledIn = RuntimeConfig(
    backendUrl: Environment.backendURl,
    generatorUrl: Environment.generatorUrl,
  );

  static RuntimeConfig _current = compiledIn;

  /// The configuration in effect. Reads [compiledIn] until [load] has run.
  static RuntimeConfig get current => _current;

  /// Base URL of the Stelaris backend.
  final String backendUrl;

  /// Base URL of the code generator service.
  final String generatorUrl;

  /// Fetches [configFileName] and adopts what it provides.
  ///
  /// Never throws. A configuration that is missing, unreachable or malformed
  /// leaves [compiledIn] in place: starting against the compiled-in defaults is
  /// better than not starting at all, and the failure is visible in the console
  /// and in the first failing API call.
  ///
  /// Pass [client] to drive this from a test without touching the network.
  static Future<void> load({Dio? client}) async {
    final Dio dio =
        client ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );

    try {
      final Response<String> response = await dio.get<String>(
        configFileName,
        options: Options(responseType: ResponseType.plain),
      );
      final String? raw = response.data;
      if (raw == null || raw.trim().isEmpty) {
        return;
      }
      _current = _parse(raw);
      // Anything at all: a malformed configuration must not keep the app from
      // starting, and there is no error type worth distinguishing here.
    } catch (error) {
      debugPrint(
        'Could not load $configFileName ($error); '
        'falling back to the compiled-in configuration.',
      );
    }
  }

  /// Restores [compiledIn]. Tests share process state, so they need this.
  @visibleForTesting
  static void reset() => _current = compiledIn;

  static RuntimeConfig _parse(String raw) {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('config.json must contain a JSON object');
    }
    return RuntimeConfig(
      backendUrl: _valueOr(decoded['backendUrl'], compiledIn.backendUrl),
      generatorUrl: _valueOr(decoded['generatorUrl'], compiledIn.generatorUrl),
    );
  }

  /// An absent, non-string or blank value falls back, so a half-filled
  /// configuration cannot silently point a client at an empty URL.
  static String _valueOr(Object? value, String fallback) {
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return fallback;
  }
}
