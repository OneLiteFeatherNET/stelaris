import 'package:flutter/foundation.dart';
import 'package:stelaris/auth/claim_path.dart';
import 'package:stelaris/auth/claim_source.dart';

/// The identity provider a deployment authenticates against.
///
/// Absent from `config.json`, the app runs unauthenticated - which is how a
/// deployment runs while its backend does not yet validate tokens, and how
/// `flutter run` works without a provider to reach.
///
/// Nothing here is provider-specific. Every endpoint comes from the issuer's
/// discovery document at runtime, so moving between providers is a change to
/// these fields and nothing else.
@immutable
class AuthConfig {
  const AuthConfig({
    required this.issuer,
    required this.clientId,
    required this.scopes,
    required this.roleClaims,
    required this.roleClaimsSource,
    this.audience,
    this.roleAliases = const <String, String>{},
  });

  /// The claim paths used when a deployment names none.
  ///
  /// These cover the shapes the common providers emit. They are defaults rather
  /// than the whole story on purpose: a provider that puts roles somewhere else
  /// is a `roleClaims` entry, never a change here.
  static List<ClaimPath> defaultRoleClaimsFor(String clientId) => <ClaimPath>[
    // Entra ID, and Auth0 without a namespace.
    const ClaimPath('roles'),
    // Keycloak, realm-wide.
    const ClaimPath('realm_access.roles'),
    // Keycloak, for this client. Segments rather than a dotted string, because
    // the client id is not ours and may contain a dot.
    ClaimPath.segments(<String>['resource_access', clientId, 'roles']),
    // Okta, Authentik, Zitadel.
    const ClaimPath('groups'),
  ];

  /// The claim sets searched when a deployment names none.
  ///
  /// All of them, because a deployment that has not thought about it is better
  /// served finding its roles than not. One that has thought about it says so.
  static const List<ClaimSource> defaultRoleClaimsSource = <ClaimSource>[
    ClaimSource.accessToken,
    ClaimSource.idToken,
    ClaimSource.userInfo,
  ];

  /// Issuer URL. Its discovery document is the source for every endpoint.
  final Uri issuer;

  /// A public, browser-based client. There is no secret: a SPA cannot keep one.
  final String clientId;

  /// Scopes to request. Carries whatever makes the provider issue an access
  /// token the backend can validate.
  final List<String> scopes;

  /// Audience to request, for providers that want it named explicitly.
  final String? audience;

  /// Where to read role names from, in order. Every path that resolves
  /// contributes; see [ClaimPath] for how one is addressed.
  final List<ClaimPath> roleClaims;

  /// Which claim sets those paths are read from, in order.
  final List<ClaimSource> roleClaimsSource;

  /// Renames role values that arrive unreadable, keyed by the raw value.
  ///
  /// Some providers put identifiers where names would be useful. Entra ID's
  /// group claim emits an object id per group unless every group happens to be
  /// synced from an on-premises directory, and an object id differs per tenant,
  /// so gating code cannot name one. This maps them to names the application
  /// can be written against.
  ///
  /// Empty by default, and empty is the normal case: a provider that already
  /// emits names needs nothing here.
  final Map<String, String> roleAliases;

  /// Reads an `auth` block, or returns null when there is nothing usable.
  ///
  /// Incomplete is treated as absent, as a unit rather than field by field: a
  /// block missing an issuer, a client id or a scope cannot produce a sign-in
  /// that succeeds, and half-applying it would swap "no authentication" for
  /// "authentication that always fails". Every rejection says what was wrong,
  /// because the alternative is an app that silently runs unauthenticated and
  /// no way to tell that from a deployment that meant to.
  static AuthConfig? tryParse(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is! Map<String, dynamic>) {
      return _reject('the auth block is not an object');
    }

    final Uri? issuer = _issuerOf(raw['issuer']);
    if (issuer == null) {
      return null;
    }

    final String? clientId = _trimmed(raw['clientId']);
    if (clientId == null) {
      return _reject('auth.clientId is missing or blank');
    }

    final List<String> scopes = _strings(raw['scopes']);
    if (scopes.isEmpty) {
      return _reject('auth.scopes names no scope');
    }

    return AuthConfig(
      issuer: issuer,
      clientId: clientId,
      scopes: scopes,
      audience: _trimmed(raw['audience']),
      roleClaims: _roleClaims(raw['roleClaims'], clientId),
      roleClaimsSource: _roleClaimsSource(raw['roleClaimsSource']),
      roleAliases: _roleAliases(raw['roleAliases']),
    );
  }

  /// An issuer has to be an absolute http(s) URL: the discovery document is
  /// resolved against it, so anything else fails later and further away.
  static Uri? _issuerOf(Object? value) {
    final String? text = _trimmed(value);
    if (text == null) {
      return _reject('auth.issuer is missing or blank');
    }
    final Uri? parsed = Uri.tryParse(text);
    if (parsed == null ||
        !parsed.isAbsolute ||
        (parsed.scheme != 'https' && parsed.scheme != 'http')) {
      return _reject('auth.issuer is not an absolute http(s) URL: $text');
    }
    return parsed;
  }

  /// Configured paths replace the defaults rather than extending them, so that
  /// a deployment naming its own can also exclude one it does not want read.
  /// Nothing usable falls back, which keeps a typo from turning into an empty
  /// role set that looks like a permissions problem.
  static List<ClaimPath> _roleClaims(Object? value, String clientId) {
    if (value == null) {
      return defaultRoleClaimsFor(clientId);
    }
    if (value is! List) {
      debugPrint('Ignoring auth.roleClaims: not a list. Using the defaults.');
      return defaultRoleClaimsFor(clientId);
    }

    final List<ClaimPath> paths = <ClaimPath>[];
    for (final Object? entry in value) {
      final String? text = _trimmed(entry);
      if (text == null) {
        debugPrint('Ignoring an auth.roleClaims entry that is not a path.');
        continue;
      }
      final ClaimPath path = ClaimPath(text);
      if (path.isEmpty) {
        continue;
      }
      paths.add(path);
    }

    if (paths.isEmpty) {
      debugPrint('auth.roleClaims named no usable path. Using the defaults.');
      return defaultRoleClaimsFor(clientId);
    }
    return List<ClaimPath>.unmodifiable(paths);
  }

  /// Named sources replace the default, for the same reason configured paths
  /// do: naming a source is also how a deployment excludes one it does not want
  /// read. A name nobody recognises is reported rather than dropped - it is
  /// almost always a typo, and silently searching two sources instead of three
  /// would surface later as roles that go missing for some people only.
  static List<ClaimSource> _roleClaimsSource(Object? value) {
    if (value == null) {
      return defaultRoleClaimsSource;
    }
    if (value is! List) {
      debugPrint(
        'Ignoring auth.roleClaimsSource: not a list. Searching all sources.',
      );
      return defaultRoleClaimsSource;
    }

    final List<ClaimSource> sources = <ClaimSource>[];
    for (final Object? entry in value) {
      final String? text = _trimmed(entry);
      final ClaimSource? source = text == null
          ? null
          : ClaimSource.tryParse(text);
      if (source == null) {
        debugPrint(
          'Ignoring the auth.roleClaimsSource entry "$entry": expected one of '
          '${ClaimSource.values.map((s) => s.name).join(', ')}.',
        );
        continue;
      }
      if (!sources.contains(source)) {
        sources.add(source);
      }
    }

    if (sources.isEmpty) {
      debugPrint(
        'auth.roleClaimsSource named no known source. Searching all of them.',
      );
      return defaultRoleClaimsSource;
    }
    return List<ClaimSource>.unmodifiable(sources);
  }

  /// Reads the alias table, skipping anything that is not a pair of strings.
  ///
  /// A malformed entry is dropped rather than failing the configuration: the
  /// rest of the table is still useful, and an unmapped value comes through as
  /// itself, which is legible enough to debug from.
  static Map<String, String> _roleAliases(Object? value) {
    if (value == null) {
      return const <String, String>{};
    }
    if (value is! Map) {
      debugPrint('Ignoring auth.roleAliases: not an object.');
      return const <String, String>{};
    }

    final Map<String, String> aliases = <String, String>{};
    value.forEach((Object? from, Object? to) {
      final String? source = _trimmed(from);
      final String? target = _trimmed(to);
      if (source == null || target == null) {
        debugPrint(
          'Ignoring an auth.roleAliases entry: both sides have to be names.',
        );
        return;
      }
      aliases[source] = target;
    });
    return Map<String, String>.unmodifiable(aliases);
  }

  static List<String> _strings(Object? value) {
    if (value is! List) {
      return const <String>[];
    }
    return List<String>.unmodifiable(
      value.map(_trimmed).whereType<String>(),
    );
  }

  static String? _trimmed(Object? value) {
    if (value is! String) {
      return null;
    }
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Always null, so a caller can `return _reject(...)` and read as one thought.
  static Null _reject(String reason) {
    debugPrint('Ignoring the auth configuration: $reason. '
        'Starting without authentication.');
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthConfig &&
          other.issuer == issuer &&
          other.clientId == clientId &&
          listEquals(other.scopes, scopes) &&
          other.audience == audience &&
          listEquals(other.roleClaims, roleClaims) &&
          listEquals(other.roleClaimsSource, roleClaimsSource) &&
          mapEquals(other.roleAliases, roleAliases);

  @override
  int get hashCode => Object.hash(
    issuer,
    clientId,
    Object.hashAll(scopes),
    audience,
    Object.hashAll(roleClaims),
    Object.hashAll(roleClaimsSource),
    Object.hashAll(roleAliases.entries.map((e) => Object.hash(e.key, e.value))),
  );
}
