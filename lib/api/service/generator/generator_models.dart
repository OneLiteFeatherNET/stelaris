import 'package:flutter/foundation.dart';

/// The Maven channel of a published version: `X.Y.Z` is a release,
/// `X.Y.Z-SNAPSHOT` a snapshot.
enum ReleaseChannel {
  release,
  snapshot;

  /// Reads the `channel` field of the generator, `null` for anything else.
  static ReleaseChannel? tryParse(Object? value) => switch (value) {
    'release' => ReleaseChannel.release,
    'snapshot' => ReleaseChannel.snapshot,
    _ => null,
  };
}

/// One version of a project in the releases or snapshots repository.
@immutable
class PublishedVersion {
  const PublishedVersion({
    required this.version,
    required this.channel,
    required this.coordinates,
    required this.repositoryUrl,
    this.jarUrl,
  });

  factory PublishedVersion.fromJson(Map<String, dynamic> json) {
    final String version = json['version'] as String;
    return PublishedVersion(
      version: version,
      channel:
          ReleaseChannel.tryParse(json['channel']) ??
          (version.endsWith('-SNAPSHOT')
              ? ReleaseChannel.snapshot
              : ReleaseChannel.release),
      coordinates: json['coordinates'] as String,
      repositoryUrl: json['repositoryUrl'] as String,
      jarUrl: json['jarUrl'] as String?,
    );
  }

  final String version;
  final ReleaseChannel channel;

  /// `net.onelitefeather.vulpes.content:<project>:<version>`.
  final String coordinates;
  final String repositoryUrl;
  final String? jarUrl;

  @override
  bool operator ==(Object other) =>
      other is PublishedVersion &&
      other.version == version &&
      other.channel == channel &&
      other.coordinates == coordinates &&
      other.repositoryUrl == repositoryUrl &&
      other.jarUrl == jarUrl;

  @override
  int get hashCode =>
      Object.hash(version, channel, coordinates, repositoryUrl, jarUrl);
}

/// The vulpes-base commit a publish was compiled against.
@immutable
class BaseCommit {
  const BaseCommit({
    required this.repository,
    required this.branch,
    required this.commit,
  });

  factory BaseCommit.fromJson(Map<String, dynamic> json) => BaseCommit(
    repository: json['repository'] as String,
    branch: json['branch'] as String,
    commit: json['commit'] as String,
  );

  final String repository;
  final String branch;

  /// The full 40-character SHA.
  final String commit;

  @override
  bool operator ==(Object other) =>
      other is BaseCommit &&
      other.repository == repository &&
      other.branch == branch &&
      other.commit == commit;

  @override
  int get hashCode => Object.hash(repository, branch, commit);
}

/// The answer of a successful publish.
@immutable
class PublishResult {
  const PublishResult({
    required this.coordinates,
    required this.revision,
    required this.base,
    required this.repositoryUrl,
  });

  factory PublishResult.fromJson(Map<String, dynamic> json) => PublishResult(
    coordinates: json['coordinates'] as String,
    revision: json['revision'] as String,
    base: BaseCommit.fromJson(json['base'] as Map<String, dynamic>),
    repositoryUrl: json['repositoryUrl'] as String,
  );

  final String coordinates;
  final String revision;
  final BaseCommit base;
  final String repositoryUrl;

  /// The line a Gradle build adds to depend on this version.
  String get gradleLine => gradleLineFor(coordinates);

  @override
  bool operator ==(Object other) =>
      other is PublishResult &&
      other.coordinates == coordinates &&
      other.revision == revision &&
      other.base == base &&
      other.repositoryUrl == repositoryUrl;

  @override
  int get hashCode => Object.hash(coordinates, revision, base, repositoryUrl);
}

/// The Gradle dependency line of the Vulpes plugin for [coordinates].
String gradleLineFor(String coordinates) => 'vulpes("$coordinates")';

/// A downloaded local build: the zip and the name to save it under.
@immutable
class LocalBuildFile {
  const LocalBuildFile(this.bytes, this.filename);

  final Uint8List bytes;
  final String filename;
}

/// One compiler error of a rejected build.
@immutable
class Diagnostic {
  const Diagnostic({required this.message, this.file, this.line});

  factory Diagnostic.fromJson(Map<String, dynamic> json) => Diagnostic(
    file: json['file'] as String?,
    line: (json['line'] as num?)?.toInt(),
    message: json['message'] as String? ?? '',
  );

  final String? file;
  final int? line;
  final String message;

  /// `items/Sword.java:12`, or what of it is known.
  String? get location {
    final String? file = this.file;
    if (file == null) return null;
    return line == null ? file : '$file:$line';
  }

  @override
  bool operator ==(Object other) =>
      other is Diagnostic &&
      other.file == file &&
      other.line == line &&
      other.message == message;

  @override
  int get hashCode => Object.hash(file, line, message);
}

/// What went wrong with a generator request, as far as the page cares.
enum GeneratorFailureKind {
  /// `409`: the release version is already published.
  versionExists,

  /// `422`: the generator refused the project or its code did not compile.
  rejected,

  /// `502`: the backend, vulpes-base or the Maven repository is unreachable.
  unavailable,

  /// The request never got an answer.
  network,

  /// Any other status, or an error that is not from the generator at all.
  unexpected,
}

/// A failed generator request, mapped from the error answer of the service.
@immutable
class GeneratorFailure {
  const GeneratorFailure(
    this.kind, {
    this.statusCode,
    this.message,
    this.diagnostics = const [],
    this.truncated = false,
  });

  final GeneratorFailureKind kind;
  final int? statusCode;

  /// The `message` of the error body, if the service sent one. Only the
  /// service's own text goes here, never a raw exception: it is shown as is.
  final String? message;

  /// The compiler errors of a `422`, capped by the service at 100.
  final List<Diagnostic> diagnostics;

  /// Whether the service cut [diagnostics].
  final bool truncated;

  @override
  bool operator ==(Object other) =>
      other is GeneratorFailure &&
      other.kind == kind &&
      other.statusCode == statusCode &&
      other.message == message &&
      listEquals(other.diagnostics, diagnostics) &&
      other.truncated == truncated;

  @override
  int get hashCode => Object.hash(
    kind,
    statusCode,
    message,
    Object.hashAll(diagnostics),
    truncated,
  );
}

/// Thrown by the generator API for every failed request.
class GeneratorApiException implements Exception {
  const GeneratorApiException(this.failure);

  final GeneratorFailure failure;

  @override
  String toString() =>
      'GeneratorApiException(${failure.kind.name}, ${failure.statusCode}, '
      '${failure.message})';
}
