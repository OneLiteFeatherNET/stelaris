import 'package:flutter/foundation.dart';
import 'package:stelaris/auth/claim_path.dart';
import 'package:stelaris/auth/claim_source.dart';

/// Turns a signed-in person's claims into the role names the interface gates on.
///
/// Every configured path that resolves, in every configured claim set,
/// contributes to one flat result: feature code asks whether a role is held,
/// never which token the provider chose to put it in. A provider emitting roles
/// in two places at once - Keycloak does, realm-wide and per client - therefore
/// needs no special case, and neither does one that emits them only from
/// userinfo.
///
/// Nothing here is enforcement. The backend is the authority; this decides what
/// is worth offering.
@immutable
class RoleMapper {
  const RoleMapper({
    required this.paths,
    required this.sources,
    this.aliases = const <String, String>{},
  });

  /// The paths to read, in the order they were configured.
  final List<ClaimPath> paths;

  /// The claim sets to read them from, in the order they were configured.
  final List<ClaimSource> sources;

  /// Renames raw claim values on the way in. See [AuthConfig.roleAliases].
  final Map<String, String> aliases;

  /// The roles [claims] grants, in the order they were found.
  ///
  /// An empty set is a valid answer, not a failure: a provider that grants no
  /// roles, a token from before roles were configured, and an access token that
  /// turned out to be opaque all produce one. Throwing here would lock someone
  /// out of an application the backend would have let them use.
  Set<String> rolesFrom(TokenClaims claims) {
    // Insertion-ordered, so a diagnostic reads in the order things were
    // configured rather than in hash order.
    final Set<String> roles = <String>{};
    for (final ClaimSource source in sources) {
      final Map<String, dynamic> claimSet = claims.of(source);
      if (claimSet.isEmpty) {
        continue;
      }
      for (final ClaimPath path in paths) {
        _collect(path, path.resolve(claimSet), roles);
      }
    }
    return Set<String>.unmodifiable(roles.map(_rename).toSet());
  }

  /// The configured name for [raw], or [raw] itself.
  ///
  /// Exact match first, then case-insensitively: object ids get written down by
  /// hand and copied out of portals that are inconsistent about case, and an
  /// alias table that silently misses because of it is worse than useless. An
  /// unmapped value passes through unchanged, so a token carrying real names
  /// and opaque ids at once ends up legible in both halves.
  String _rename(String raw) {
    final String? exact = aliases[raw];
    if (exact != null) {
      return exact;
    }
    for (final MapEntry<String, String> alias in aliases.entries) {
      if (alias.key.toLowerCase() == raw.toLowerCase()) {
        return alias.value;
      }
    }
    return raw;
  }

  static void _collect(ClaimPath path, Object? value, Set<String> into) {
    // Absent is the normal case, not a problem worth logging: the built-in
    // paths cover several providers at once, so most of them miss on any given
    // token and saying so every time would bury the diagnostics that matter.
    if (value == null) {
      return;
    }

    if (value is String) {
      _add(value, into);
      return;
    }

    if (value is List) {
      int skipped = 0;
      for (final Object? entry in value) {
        if (entry is String) {
          _add(entry, into);
        } else {
          skipped++;
        }
      }
      if (skipped > 0) {
        debugPrint(
          'Skipped $skipped entr${skipped == 1 ? 'y' : 'ies'} under the role '
          'claim "${path.label}": a role name has to be a string.',
        );
      }
      return;
    }

    debugPrint(
      'Ignoring the role claim "${path.label}": it holds '
      '${value.runtimeType}, not a string or a list of strings.',
    );
  }

  static void _add(String role, Set<String> into) {
    final String trimmed = role.trim();
    if (trimmed.isNotEmpty) {
      into.add(trimmed);
    }
  }
}
