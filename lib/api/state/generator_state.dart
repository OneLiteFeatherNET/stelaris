import 'package:flutter/foundation.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/feature/build/publish/version_proposal.dart';

enum RequestStatus { idle, loading, done, failed }

/// Where one request of the generator page stands: its last value and, when
/// it failed, why.
@immutable
class RequestState<T> {
  const RequestState.idle() : this._(RequestStatus.idle);

  const RequestState.loading([T? previous])
    : this._(RequestStatus.loading, value: previous);

  const RequestState.done(T value) : this._(RequestStatus.done, value: value);

  const RequestState.failed(GeneratorFailure failure)
    : this._(RequestStatus.failed, failure: failure);

  const RequestState._(this.status, {this.value, this.failure});

  final RequestStatus status;
  final T? value;
  final GeneratorFailure? failure;

  bool get isLoading => status == RequestStatus.loading;
  bool get isDone => status == RequestStatus.done;
  bool get isFailed => status == RequestStatus.failed;

  @override
  bool operator ==(Object other) =>
      other is RequestState<T> &&
      other.status == status &&
      _valueEquals(other.value, value) &&
      other.failure == failure;

  static bool _valueEquals(Object? a, Object? b) =>
      a is List && b is List ? listEquals(a, b) : a == b;

  @override
  int get hashCode => Object.hash(
    status,
    value is List ? Object.hashAll(value as List) : value,
    failure,
  );
}

/// The state of the generator page. Transient: it lives in the store so
/// that the branch, the publish choices and the results survive tab
/// switches, and is never persisted.
@immutable
class GeneratorState {
  const GeneratorState({
    this.projectId,
    this.branches = const RequestState.idle(),
    this.selectedBranch,
    this.localBuild = const RequestState.idle(),
    this.versions = const RequestState.idle(),
    this.channel = ReleaseChannel.release,
    this.bump = BumpPart.patch,
    this.customVersion,
    this.publish = const RequestState.idle(),
    this.publishVersion,
    this.downloadingVersion,
    this.versionDownloadFailure,
  });

  /// The project the project-bound requests below were made for.
  final String? projectId;

  /// The vulpes-base branches.
  final RequestState<List<String>> branches;

  /// The branch "Test locally" and "Publish" build against.
  final String? selectedBranch;

  /// The last local build download; its value is the saved file name.
  final RequestState<String> localBuild;

  /// The published versions of the project, newest first.
  final RequestState<List<PublishedVersion>> versions;

  final ReleaseChannel channel;
  final BumpPart bump;

  /// The version typed under [BumpPart.custom], as `X.Y.Z` without
  /// `-SNAPSHOT`. `null` until a custom version is chosen.
  final String? customVersion;

  /// The last publish.
  final RequestState<PublishResult> publish;

  /// The version the last publish asked for.
  final String? publishVersion;

  /// The published version whose local build is being downloaded.
  final String? downloadingVersion;

  /// Why the last download of a published version failed.
  final GeneratorFailure? versionDownloadFailure;

  /// The project-bound part reset, for a newly selected project.
  GeneratorState forProject(String? projectId) => GeneratorState(
    projectId: projectId,
    branches: branches,
    selectedBranch: selectedBranch,
    channel: channel,
    bump: bump,
    customVersion: customVersion,
  );

  GeneratorState copyWith({
    RequestState<List<String>>? branches,
    String? Function()? selectedBranch,
    RequestState<String>? localBuild,
    RequestState<List<PublishedVersion>>? versions,
    ReleaseChannel? channel,
    BumpPart? bump,
    String? customVersion,
    RequestState<PublishResult>? publish,
    String? publishVersion,
    String? Function()? downloadingVersion,
    GeneratorFailure? Function()? versionDownloadFailure,
  }) => GeneratorState(
    projectId: projectId,
    branches: branches ?? this.branches,
    selectedBranch: selectedBranch == null
        ? this.selectedBranch
        : selectedBranch(),
    localBuild: localBuild ?? this.localBuild,
    versions: versions ?? this.versions,
    channel: channel ?? this.channel,
    bump: bump ?? this.bump,
    customVersion: customVersion ?? this.customVersion,
    publish: publish ?? this.publish,
    publishVersion: publishVersion ?? this.publishVersion,
    downloadingVersion: downloadingVersion == null
        ? this.downloadingVersion
        : downloadingVersion(),
    versionDownloadFailure: versionDownloadFailure == null
        ? this.versionDownloadFailure
        : versionDownloadFailure(),
  );

  @override
  bool operator ==(Object other) =>
      other is GeneratorState &&
      other.projectId == projectId &&
      other.branches == branches &&
      other.selectedBranch == selectedBranch &&
      other.localBuild == localBuild &&
      other.versions == versions &&
      other.channel == channel &&
      other.bump == bump &&
      other.customVersion == customVersion &&
      other.publish == publish &&
      other.publishVersion == publishVersion &&
      other.downloadingVersion == downloadingVersion &&
      other.versionDownloadFailure == versionDownloadFailure;

  @override
  int get hashCode => Object.hash(
    projectId,
    branches,
    selectedBranch,
    localBuild,
    versions,
    channel,
    bump,
    customVersion,
    publish,
    publishVersion,
    downloadingVersion,
    versionDownloadFailure,
  );
}
