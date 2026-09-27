import 'package:flutter/foundation.dart';
// jose comes through oidc's public surface, which re-exports it. Importing it
// from there rather than directly keeps one dependency to pin instead of two
// that have to stay compatible with each other.
import 'package:oidc/oidc.dart';

/// A set of claims a provider makes available, and which one to read from.
///
/// Providers disagree about where roles live: Keycloak puts realm and client
/// roles in the access token and needs an extra mapper to copy them into the ID
/// token, Entra ID emits them in both, and several providers expose group
/// membership only from the userinfo endpoint. Reading the wrong one yields an
/// empty role set that looks exactly like a permissions problem, so a
/// deployment names its sources rather than leaving the app to search.
enum ClaimSource {
  /// The access token, parsed without being validated.
  ///
  /// Sound for deciding what to put on screen and for nothing else. The backend
  /// validates the same token and refuses anything the roles did not really
  /// allow, so a forged claim buys a visible button and a 403. A provider that
  /// issues an opaque access token simply contributes nothing here.
  accessToken,

  /// The ID token. Always a JSON Web Token; the flow already verified it.
  idToken,

  /// The userinfo response, where the provider returned one.
  userInfo;

  /// The name as a deployment writes it, matched case-insensitively.
  static ClaimSource? tryParse(String raw) {
    final String needle = raw.trim().toLowerCase();
    for (final ClaimSource source in ClaimSource.values) {
      if (source.name.toLowerCase() == needle) {
        return source;
      }
    }
    return null;
  }
}

/// The claims of one signed-in person, kept apart by where they came from.
@immutable
class TokenClaims {
  const TokenClaims({
    this.accessToken = const <String, dynamic>{},
    this.idToken = const <String, dynamic>{},
    this.userInfo = const <String, dynamic>{},
  });

  /// Nothing at all - nobody signed in.
  static const TokenClaims empty = TokenClaims();

  final Map<String, dynamic> accessToken;
  final Map<String, dynamic> idToken;
  final Map<String, dynamic> userInfo;

  /// The claims for [source], empty when that source carried none.
  Map<String, dynamic> of(ClaimSource source) => switch (source) {
    ClaimSource.accessToken => accessToken,
    ClaimSource.idToken => idToken,
    ClaimSource.userInfo => userInfo,
  };

  /// Reads a serialised JWT without verifying it, or gives back nothing.
  ///
  /// Every failure lands in the same place on purpose: an access token that is
  /// opaque, truncated, or not a JWT at all is a provider that does not put
  /// claims there, not an error this application can act on. The remaining
  /// sources are still read, and the session stays valid.
  static Map<String, dynamic> decode(String? serialised) {
    if (serialised == null || serialised.trim().isEmpty) {
      return const <String, dynamic>{};
    }
    try {
      return JsonWebToken.unverified(serialised).claims.toJson();
      // Anything: jose throws several unrelated types for a malformed token,
      // and the answer is the same for all of them.
    } catch (_) {
      debugPrint(
        'The access token is not a readable JSON Web Token, so no claims were '
        'read from it. This is normal for a provider that issues opaque access '
        'tokens; roles then have to come from another source.',
      );
      return const <String, dynamic>{};
    }
  }
}
