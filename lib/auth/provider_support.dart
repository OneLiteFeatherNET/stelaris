import 'package:flutter/foundation.dart';
import 'package:oidc/oidc.dart';

/// Whether a provider's discovery document describes a provider this app can
/// actually use, and what is missing when it does not.
///
/// Worth checking up front rather than discovering it at the first redirect:
/// a provider that cannot do this flow fails in the browser, on the provider's
/// own error page, with nothing in the application to point at. Named here, it
/// fails at startup with a sentence that says which setting is wrong.
abstract final class ProviderSupport {
  /// Null when [metadata] describes a usable provider; otherwise what is
  /// missing, phrased for whoever configured the deployment.
  static String? unsupportedReason(OidcProviderMetadata metadata) {
    final List<String> missing = <String>[];

    if (metadata.authorizationEndpoint == null) {
      missing.add('an authorization endpoint');
    }
    if (metadata.tokenEndpoint == null) {
      missing.add('a token endpoint');
    }

    // Absent means the two defaults from the specification, of which
    // authorization_code is one - so an omitted field is not a refusal.
    if (!metadata.grantTypesSupportedOrDefault.contains('authorization_code')) {
      missing.add('the authorization_code grant');
    }

    final List<String>? responseTypes = metadata.responseTypesSupported;
    if (responseTypes != null &&
        !responseTypes.any((t) => t.split(' ').contains('code'))) {
      missing.add('the code response type');
    }

    // Silence is not a refusal. This started out strict, on the reasoning that
    // no specification makes PKCE a default - and then a real Microsoft Entra
    // ID v2.0 document turned out to omit the field entirely while supporting
    // S256 perfectly well. Refusing on absence would have rejected one of the
    // two providers this was written for.
    //
    // A provider that says nothing still gets the code challenge; one that
    // ignores it degrades to a plain authorization code flow, which is what a
    // provider without PKCE would have given us anyway. A provider that does
    // list its methods and leaves S256 out is a different matter: it is
    // telling us it cannot do this, and that is worth refusing.
    final List<String>? challengeMethods = metadata.codeChallengeMethodsSupported;
    if (challengeMethods != null && !challengeMethods.contains('S256')) {
      missing.add('PKCE with S256');
    } else if (challengeMethods == null) {
      debugPrint(
        'The configured provider does not advertise which PKCE methods it '
        'supports. Continuing with S256, which is what the authorization '
        'request sends either way - Entra ID omits this field and accepts it.',
      );
    }

    if (missing.isEmpty) {
      return null;
    }
    return 'The configured provider does not advertise ${_list(missing)}. '
        'This application signs in with the authorization code flow and PKCE '
        'and cannot use a provider without them.';
  }

  static String _list(List<String> parts) {
    if (parts.length == 1) {
      return parts.single;
    }
    return '${parts.sublist(0, parts.length - 1).join(', ')} '
        'or ${parts.last}';
  }
}
