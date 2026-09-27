import 'package:flutter_test/flutter_test.dart';
import 'package:oidc/oidc.dart';
import 'package:stelaris/auth/provider_support.dart';

/// A discovery document with everything this application needs, built the way
/// a real one arrives - as JSON off the wire - so the field names under test
/// are the ones a provider actually publishes.
OidcProviderMetadata document({
  Object? authorizationEndpoint = 'https://idp.example/authorize',
  Object? tokenEndpoint = 'https://idp.example/token',
  Object? grantTypesSupported = const ['authorization_code', 'refresh_token'],
  Object? responseTypesSupported = const ['code'],
  Object? codeChallengeMethodsSupported = const ['S256'],
}) => OidcProviderMetadata.fromJson(<String, dynamic>{
  'issuer': 'https://idp.example',
  'jwks_uri': 'https://idp.example/keys',
  'authorization_endpoint': ?authorizationEndpoint,
  'token_endpoint': ?tokenEndpoint,
  'grant_types_supported': ?grantTypesSupported,
  'response_types_supported': ?responseTypesSupported,
  'code_challenge_methods_supported': ?codeChallengeMethodsSupported,
});

void main() {
  group('ProviderSupport', () {
    test('accepts a provider that advertises the flow', () {
      expect(ProviderSupport.unsupportedReason(document()), isNull);
    });

    test('accepts a response type listed alongside others', () {
      // "code id_token" is one entry, and it does include code.
      expect(
        ProviderSupport.unsupportedReason(
          document(
            responseTypesSupported: const ['code id_token', 'id_token'],
          ),
        ),
        isNull,
      );
    });

    test('accepts an omitted grant list', () {
      // The specification's default includes authorization_code, so silence
      // here is not a refusal.
      expect(
        ProviderSupport.unsupportedReason(document(grantTypesSupported: null)),
        isNull,
      );
    });

    test('accepts a provider that advertises no PKCE methods at all', () {
      // Regression: this used to refuse, on the reasoning that no
      // specification makes PKCE a default. A live Entra ID v2.0 document
      // omits the field and supports S256 anyway, so the strict reading
      // rejected one of the two providers this was built for.
      expect(
        ProviderSupport.unsupportedReason(
          document(codeChallengeMethodsSupported: null),
        ),
        isNull,
      );
    });

    test('refuses a provider that lists its methods and leaves S256 out', () {
      // Different from silence: this provider is saying it cannot do S256.
      final reason = ProviderSupport.unsupportedReason(
        document(codeChallengeMethodsSupported: const ['plain']),
      );

      expect(reason, contains('PKCE'));
    });

    test('refuses a provider without the authorization code grant', () {
      final reason = ProviderSupport.unsupportedReason(
        document(grantTypesSupported: const ['implicit']),
      );

      expect(reason, contains('authorization_code'));
    });

    test('refuses a provider with no authorization endpoint', () {
      final reason = ProviderSupport.unsupportedReason(
        document(authorizationEndpoint: null),
      );

      expect(reason, contains('authorization endpoint'));
    });

    test('names everything that is missing, not just the first', () {
      final reason = ProviderSupport.unsupportedReason(
        document(
          tokenEndpoint: null,
          codeChallengeMethodsSupported: const ['plain'],
        ),
      );

      expect(reason, contains('token endpoint'));
      expect(reason, contains('PKCE'));
    });

    test('accepts a real Keycloak document', () {
      // Trimmed to the fields under test, field names verbatim.
      final metadata = OidcProviderMetadata.fromJson(const {
        'issuer': 'https://kc.example/realms/stelaris',
        'authorization_endpoint':
            'https://kc.example/realms/stelaris/protocol/openid-connect/auth',
        'token_endpoint':
            'https://kc.example/realms/stelaris/protocol/openid-connect/token',
        'end_session_endpoint':
            'https://kc.example/realms/stelaris/protocol/openid-connect/logout',
        'jwks_uri':
            'https://kc.example/realms/stelaris/protocol/openid-connect/certs',
        'grant_types_supported': [
          'authorization_code',
          'refresh_token',
          'password',
        ],
        'response_types_supported': ['code', 'none', 'id_token token'],
        'code_challenge_methods_supported': ['plain', 'S256'],
      });

      expect(ProviderSupport.unsupportedReason(metadata), isNull);
    });

    test('accepts a real Entra ID document', () {
      final metadata = OidcProviderMetadata.fromJson(const {
        'issuer': 'https://login.microsoftonline.com/contoso/v2.0',
        'authorization_endpoint':
            'https://login.microsoftonline.com/contoso/oauth2/v2.0/authorize',
        'token_endpoint':
            'https://login.microsoftonline.com/contoso/oauth2/v2.0/token',
        'end_session_endpoint':
            'https://login.microsoftonline.com/contoso/oauth2/v2.0/logout',
        'jwks_uri': 'https://login.microsoftonline.com/contoso/discovery/v2.0/keys',
        'response_types_supported': [
          'code',
          'id_token',
          'code id_token',
          'id_token token',
        ],
        'code_challenge_methods_supported': ['plain', 'S256'],
      });

      expect(ProviderSupport.unsupportedReason(metadata), isNull);
    });
  });
}
