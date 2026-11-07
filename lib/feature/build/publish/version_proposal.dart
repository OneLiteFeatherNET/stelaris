import 'package:flutter/foundation.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';

/// Which part of the latest release a publish raises, or [custom] for a
/// version typed by hand instead of proposed.
enum BumpPart { major, minor, patch, custom }

/// The version the publish tab offers, or why it offers none.
sealed class VersionProposal {
  const VersionProposal();
}

/// [version] is the next version to publish.
@immutable
final class ProposedVersion extends VersionProposal {
  const ProposedVersion(this.version);

  final String version;

  @override
  bool operator ==(Object other) =>
      other is ProposedVersion && other.version == version;

  @override
  int get hashCode => version.hashCode;

  @override
  String toString() => 'ProposedVersion($version)';
}

/// A published version, [raw], is neither `X.Y.Z` nor `X.Y.Z-SNAPSHOT`, so
/// no next version can be told.
@immutable
final class UnreadableVersion extends VersionProposal {
  const UnreadableVersion(this.raw);

  final String raw;

  @override
  bool operator ==(Object other) =>
      other is UnreadableVersion && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => 'UnreadableVersion($raw)';
}

/// The version of a project's first release.
const String firstRelease = '0.1.0';

const String _snapshotSuffix = '-SNAPSHOT';

/// A parsed `X.Y.Z` or `X.Y.Z-SNAPSHOT`.
@immutable
class SemanticVersion implements Comparable<SemanticVersion> {
  const SemanticVersion(
    this.major,
    this.minor,
    this.patch, {
    this.snapshot = false,
  });

  /// Numeric parts without leading zeros, as the generator accepts them.
  static final RegExp _pattern = RegExp(
    r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-SNAPSHOT)?$',
  );

  /// Reads [raw], or `null` when it is neither form.
  static SemanticVersion? tryParse(String raw) {
    final match = _pattern.firstMatch(raw);
    if (match == null) return null;
    final int? major = int.tryParse(match.group(1)!);
    final int? minor = int.tryParse(match.group(2)!);
    final int? patch = int.tryParse(match.group(3)!);
    if (major == null || minor == null || patch == null) return null;
    return SemanticVersion(
      major,
      minor,
      patch,
      snapshot: match.group(4) != null,
    );
  }

  final int major;
  final int minor;
  final int patch;
  final bool snapshot;

  SemanticVersion bump(BumpPart part) => switch (part) {
    BumpPart.major => SemanticVersion(major + 1, 0, 0),
    BumpPart.minor => SemanticVersion(major, minor + 1, 0),
    BumpPart.patch => SemanticVersion(major, minor, patch + 1),
    BumpPart.custom => throw ArgumentError.value(
      part,
      'part',
      'a custom version is typed, not bumped',
    ),
  };

  /// Newer is greater; a release is newer than the snapshot of its version.
  @override
  int compareTo(SemanticVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    if (snapshot == other.snapshot) return 0;
    return snapshot ? -1 : 1;
  }

  @override
  bool operator ==(Object other) =>
      other is SemanticVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch, snapshot);

  @override
  String toString() => '$major.$minor.$patch${snapshot ? _snapshotSuffix : ''}';
}

/// The next version on [channel] after the newest release in [published],
/// raised at [bump]. Without a release it is [firstRelease]. A snapshot is
/// the release proposal with `-SNAPSHOT`.
///
/// Never throws: a published version that cannot be read gives an
/// [UnreadableVersion] instead of a guess.
VersionProposal proposeVersion({
  required ReleaseChannel channel,
  required BumpPart bump,
  required Iterable<String> published,
}) {
  SemanticVersion? latestRelease;
  for (final raw in published) {
    final SemanticVersion? version = SemanticVersion.tryParse(raw);
    if (version == null) return UnreadableVersion(raw);
    if (version.snapshot) continue;
    if (latestRelease == null || version.compareTo(latestRelease) > 0) {
      latestRelease = version;
    }
  }
  final String next = latestRelease == null
      ? firstRelease
      : latestRelease.bump(bump).toString();
  return ProposedVersion(
    channel == ReleaseChannel.snapshot ? '$next$_snapshotSuffix' : next,
  );
}

/// The version a typed [raw] publishes as on [channel]: `X.Y.Z`, with
/// `-SNAPSHOT` on the snapshot channel. `null` when [raw] is not `X.Y.Z`.
String? customVersion(String raw, ReleaseChannel channel) {
  final SemanticVersion? version = SemanticVersion.tryParse(raw);
  if (version == null || version.snapshot) return null;
  return channel == ReleaseChannel.snapshot ? '$raw$_snapshotSuffix' : raw;
}

/// [version] without `-SNAPSHOT`, the `X.Y.Z` a custom version starts from.
String releaseNumber(String version) => version.endsWith(_snapshotSuffix)
    ? version.substring(0, version.length - _snapshotSuffix.length)
    : version;

/// [versions] newest first. Unreadable versions go last, in their order.
List<PublishedVersion> newestFirst(Iterable<PublishedVersion> versions) {
  final indexed = versions.toList();
  final List<(PublishedVersion, SemanticVersion?, int)> keyed = [
    for (var i = 0; i < indexed.length; i++)
      (indexed[i], SemanticVersion.tryParse(indexed[i].version), i),
  ];
  keyed.sort((a, b) {
    final SemanticVersion? left = a.$2;
    final SemanticVersion? right = b.$2;
    if (left == null && right == null) return a.$3.compareTo(b.$3);
    if (left == null) return 1;
    if (right == null) return -1;
    return right.compareTo(left);
  });
  return [for (final entry in keyed) entry.$1];
}

/// The newest release in [published], ignoring snapshots and versions that
/// cannot be read; `null` when there is none.
String? latestRelease(Iterable<String> published) =>
    _latest(published, snapshot: false);

/// The newest snapshot in [published]; `null` when there is none.
String? latestSnapshot(Iterable<String> published) =>
    _latest(published, snapshot: true);

String? _latest(Iterable<String> published, {required bool snapshot}) {
  SemanticVersion? latest;
  for (final raw in published) {
    final SemanticVersion? version = SemanticVersion.tryParse(raw);
    if (version == null || version.snapshot != snapshot) continue;
    if (latest == null || version.compareTo(latest) > 0) latest = version;
  }
  return latest?.toString();
}
