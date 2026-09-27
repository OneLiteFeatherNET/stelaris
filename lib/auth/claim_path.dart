import 'package:flutter/foundation.dart';

/// Where in a set of token claims a value lives.
///
/// OpenID Connect standardises nothing about role claims, so a deployment names
/// the paths it needs and this resolves them. Two shapes have to work at once:
///
///     realm_access.roles              a nested object, addressed by dots
///     https://stelaris.example/roles  one top-level key that contains dots
///
/// Splitting on every dot shatters the second; never splitting puts the first
/// out of reach. So a path written as a string is looked up whole first and
/// split only when no claim carries that exact key. That is deterministic for
/// any given token and right for both shapes, without asking whoever writes the
/// configuration to escape anything.
@immutable
class ClaimPath {
  /// A path as a deployment wrote it, resolved by the rule above.
  const ClaimPath(String path) : _raw = path, _segments = null;

  /// A path whose segments are already known, so nothing is ever split.
  ///
  /// The built-in defaults need this: `resource_access.<clientId>.roles`
  /// embeds a client id this application does not choose, and one containing a
  /// dot would otherwise be split into segments that match nothing.
  const ClaimPath.segments(List<String> segments)
    : _segments = segments,
      _raw = null;

  final String? _raw;
  final List<String>? _segments;

  /// How the path reads in a diagnostic.
  String get label => _raw ?? _segments!.join('.');

  /// Whether this path could ever address anything.
  bool get isEmpty {
    final String? raw = _raw;
    if (raw != null) {
      return raw.trim().isEmpty;
    }
    final List<String> segments = _segments!;
    return segments.isEmpty || segments.any((s) => s.trim().isEmpty);
  }

  /// The value at this path, or null when [claims] does not carry one.
  ///
  /// Null covers both "no such path" and "the path is there but holds null":
  /// nothing downstream needs to tell those apart, and a caller that treats
  /// every absent claim the same way cannot get the distinction wrong.
  Object? resolve(Map<String, dynamic> claims) {
    final List<String>? segments = _segments;
    if (segments != null) {
      return _walk(claims, segments);
    }
    final String raw = _raw!;
    if (claims.containsKey(raw)) {
      return claims[raw];
    }
    return _walk(claims, raw.split('.'));
  }

  static Object? _walk(Map<String, dynamic> claims, List<String> segments) {
    Object? current = claims;
    for (final String segment in segments) {
      if (current is! Map) {
        return null;
      }
      if (!current.containsKey(segment)) {
        return null;
      }
      current = current[segment];
    }
    return current;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClaimPath &&
          other._raw == _raw &&
          listEquals(other._segments, _segments);

  @override
  int get hashCode => Object.hash(_raw, Object.hashAll(_segments ?? const []));

  @override
  String toString() => 'ClaimPath($label)';
}
