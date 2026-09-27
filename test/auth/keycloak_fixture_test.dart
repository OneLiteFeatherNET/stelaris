@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oidc/oidc.dart';
import 'package:stelaris/auth/auth_config.dart';
import 'package:stelaris/auth/claim_source.dart';
import 'package:stelaris/auth/provider_support.dart';
import 'package:stelaris/auth/role_mapper.dart';
import 'package:stelaris/auth/roles.dart';

import 'jwt_builder.dart';

/// Recorded from a real Keycloak 26.4 realm driven through the authorization
/// code flow with PKCE, with the same `config.json` a deployment would use.
///
/// Reads its fixtures off disk, so it runs on the VM only - there is no file
/// system in a browser. Nothing here is browser-specific: it exercises parsing,
/// the capability check and role mapping, all of which are plain Dart.
///
/// Fixtures rather than a live provider so this runs anywhere, and recorded
/// rather than hand-written because hand-written claims agree with whatever we
/// believed when we wrote them. Re-record by running the flow against a local
/// realm again; the tokens are from a throwaway realm and a made-up user.
Map<String, dynamic> fixture(String name) => jsonDecode(
  File('test/auth/fixtures/$name.json').readAsStringSync(),
) as Map<String, dynamic>;

void main() {
  group('a real Keycloak discovery document', () {
    test('describes a provider this application can use', () {
      final metadata = OidcProviderMetadata.fromJson(
        fixture('keycloak_discovery'),
      );

      expect(ProviderSupport.unsupportedReason(metadata), isNull);
    });

    test('advertises everything the flow depends on', () {
      final metadata = OidcProviderMetadata.fromJson(
        fixture('keycloak_discovery'),
      );

      expect(metadata.codeChallengeMethodsSupported, contains('S256'));
      expect(metadata.grantTypesSupportedOrDefault, contains('refresh_token'));
      expect(metadata.endSessionEndpoint, isNotNull);
    });
  });

  group('a real Entra ID discovery document', () {
    test('is accepted even though it advertises no PKCE methods', () {
      // Recorded from a live Entra ID v2.0 tenant: the document omits
      // code_challenge_methods_supported entirely, and omits
      // grant_types_supported with it. An earlier version of this check
      // refused on that absence, which would have rejected Entra outright.
      final metadata = OidcProviderMetadata.fromJson(fixture('entra_discovery'));

      expect(ProviderSupport.unsupportedReason(metadata), isNull);
    });

    test('really does omit the fields this turns on', () {
      // Guards the reason the rule is lenient. If a future recording carries
      // these fields, the leniency is no longer being exercised by it.
      final raw = fixture('entra_discovery');

      expect(raw.containsKey('code_challenge_methods_supported'), isFalse);
      expect(raw.containsKey('grant_types_supported'), isFalse);
    });

    test('still offers what the flow needs', () {
      final metadata = OidcProviderMetadata.fromJson(fixture('entra_discovery'));

      expect(metadata.authorizationEndpoint, isNotNull);
      expect(metadata.tokenEndpoint, isNotNull);
      expect(metadata.endSessionEndpoint, isNotNull);
      expect(metadata.responseTypesSupported, contains('code'));
    });
  });

  group('real Keycloak tokens', () {
    final Map<String, dynamic> recorded = fixture('keycloak_claims');

    Map<String, dynamic> accessClaims() =>
        recorded['access_token_claims'] as Map<String, dynamic>;
    Map<String, dynamic> idClaims() =>
        recorded['id_token_claims'] as Map<String, dynamic>;

    /// The recorded claims put back into tokens and decoded again, so the
    /// decoding path is exercised on real payloads without a signed token
    /// living in the repository.
    TokenClaims claimsFrom() => TokenClaims(
      accessToken: TokenClaims.decode(unsignedJwt(accessClaims())),
      idToken: TokenClaims.decode(unsignedJwt(idClaims())),
    );

    test('put the roles in the access token and not in the id token', () {
      // The reason the claim source is configuration rather than a constant.
      // Reading only the id token here would produce an empty role set and
      // look exactly like a permissions problem.
      final claims = claimsFrom();

      expect(claims.accessToken['realm_access'], isNotNull);
      expect(claims.idToken['realm_access'], isNull);
    });

    test('yield the granted role through the built-in claim paths', () {
      final roles = RoleMapper(
        paths: AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
        sources: AuthConfig.defaultRoleClaimsSource,
      ).rolesFrom(claimsFrom());

      expect(roles, contains(Roles.admin));
    });

    test('yield nothing when only the id token is searched', () {
      // The same tokens, one setting different. This is what a deployment that
      // names the wrong source would see.
      final roles = RoleMapper(
        paths: AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
        sources: const [ClaimSource.idToken],
      ).rolesFrom(claimsFrom());

      expect(roles, isEmpty);
    });

    test('carry a display name the interface can show', () {
      final claims = claimsFrom();

      expect(claims.idToken['name'], 'Ada Lovelace');
      expect(claims.idToken['preferred_username'], 'ada');
    });

    test('are readable without being validated', () {
      // The access token is parsed to decide what to offer. Validating it is
      // the backend's job, and this asserts only that parsing works on a real
      // payload - three segments, readable claims.
      final String token = unsignedJwt(accessClaims());

      expect(token.split('.'), hasLength(3));
      expect(TokenClaims.decode(token), isNotEmpty);
    });

    test('carry the audience the recording was made with', () {
      // Keycloak names no audience for our backend on a stock public client,
      // which is the reason the documentation insists on an audience mapper.
      expect(accessClaims()['aud'], anyOf(isNull, isNot(contains('stelaris'))));
    });
  });

  group('the config.json this was driven with', () {
    test('parses into the configuration the flow actually used', () {
      final config = AuthConfig.tryParse(<String, dynamic>{
        'issuer': 'http://localhost:18081/realms/stelaris',
        'clientId': 'stelaris-ui',
        'scopes': ['openid', 'profile', 'offline_access'],
        'roleClaimsSource': ['accessToken', 'idToken'],
      });

      expect(config, isNotNull);
      expect(config!.scopes, contains('offline_access'));
      expect(config.roleClaimsSource, const [
        ClaimSource.accessToken,
        ClaimSource.idToken,
      ]);
    });
  });
}
