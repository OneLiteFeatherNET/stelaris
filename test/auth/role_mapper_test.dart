import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/auth/auth_config.dart';
import 'package:stelaris/auth/claim_path.dart';
import 'package:stelaris/auth/claim_source.dart';
import 'package:stelaris/auth/role_mapper.dart';

import 'jwt_builder.dart';

/// The mapper as a deployment gets it when it names nothing of its own.
RoleMapper defaultsFor(String clientId) => RoleMapper(
  paths: AuthConfig.defaultRoleClaimsFor(clientId),
  sources: AuthConfig.defaultRoleClaimsSource,
);

/// A mapper for one path, searching everywhere.
RoleMapper mapperFor(List<ClaimPath> paths) =>
    RoleMapper(paths: paths, sources: AuthConfig.defaultRoleClaimsSource);

void main() {
  group('RoleMapper - claim shapes the defaults cover', () {
    test('reads a flat list of roles', () {
      // Entra ID, and Auth0 without a namespace.
      final roles = defaultsFor('stelaris-ui').rolesFrom(const TokenClaims(accessToken: {
        'roles': ['stelaris.admin', 'stelaris.editor'],
      }));

      expect(roles, {'stelaris.admin', 'stelaris.editor'});
    });

    test('reads realm and client roles together', () {
      // Keycloak puts them in two places at once, and both count.
      final roles = defaultsFor('stelaris-ui').rolesFrom(const TokenClaims(accessToken: {
        'realm_access': {
          'roles': ['offline_access', 'default-roles-stelaris'],
        },
        'resource_access': {
          'stelaris-ui': {
            'roles': ['editor'],
          },
          'another-client': {
            'roles': ['not-ours'],
          },
        },
      }));

      expect(roles, contains('offline_access'));
      expect(roles, contains('editor'));
      // Roles granted to a different client are not this application's.
      expect(roles, isNot(contains('not-ours')));
    });

    test('reads a groups claim', () {
      // Okta, Authentik, Zitadel.
      final roles = defaultsFor('stelaris-ui').rolesFrom(const TokenClaims(accessToken: {
        'groups': ['Stelaris Admins'],
      }));

      expect(roles, {'Stelaris Admins'});
    });

    test('reads a single role given as a bare string', () {
      final roles = defaultsFor('stelaris-ui').rolesFrom(const TokenClaims(accessToken: {'roles': 'admin'}));

      expect(roles, {'admin'});
    });

    test('finds client roles when the client id contains a dot', () {
      // The client id is the provider's, not ours. Splitting the default path
      // on every dot would look for resource_access -> my -> client -> roles.
      final roles = defaultsFor('my.client').rolesFrom(const TokenClaims(accessToken: {
        'resource_access': {
          'my.client': {
            'roles': ['editor'],
          },
        },
      }));

      expect(roles, {'editor'});
    });

    test('merges roles found under several paths into one set', () {
      final roles = defaultsFor('stelaris-ui').rolesFrom(const TokenClaims(accessToken: {
        'roles': ['admin'],
        'groups': ['admin', 'viewer'],
      }));

      // A role granted twice is still one role.
      expect(roles, {'admin', 'viewer'});
    });
  });

  group('RoleMapper - paths the defaults do not cover', () {
    test('reads a namespaced claim named in the configuration', () {
      // The acceptance test for an open provider set: a claim key that is
      // itself full of dots and slashes, reached by configuration alone.
      const path = ClaimPath('https://stelaris.example/roles');
      final roles = mapperFor(const [path]).rolesFrom(const TokenClaims(accessToken: {
        'https://stelaris.example/roles': ['admin'],
      }));

      expect(roles, {'admin'});
    });

    test('reads a nested path named in the configuration', () {
      final roles = mapperFor(const [ClaimPath('app.access.roles')]).rolesFrom(const TokenClaims(accessToken: {
        'app': {
          'access': {
            'roles': ['editor'],
          },
        },
      }));

      expect(roles, {'editor'});
    });

    test('prefers an exact key over splitting it', () {
      // Both readings exist in this token. The literal key wins, which is the
      // only rule that makes a namespaced claim addressable at all.
      final roles = mapperFor(const [ClaimPath('a.b')]).rolesFrom(const TokenClaims(accessToken: {
        'a.b': ['literal'],
        'a': {'b': 'split'},
      }));

      expect(roles, {'literal'});
    });

    test('a named path reads nothing the defaults would have found', () {
      // Configuring paths replaces the defaults; this is what that means.
      final roles = mapperFor(const [ClaimPath('urn:example:roles')])
          .rolesFrom(const TokenClaims(accessToken: {
        'roles': ['admin'],
      }));

      expect(roles, isEmpty);
    });
  });

  group('RoleMapper - which claim set is read', () {
    const TokenClaims spread = TokenClaims(
      accessToken: {
        'realm_access': {
          'roles': ['from-access-token'],
        },
      },
      idToken: {
        'roles': ['from-id-token'],
      },
      userInfo: {
        'groups': ['from-userinfo'],
      },
    );

    test('reads every source when the configuration names none', () {
      final roles = defaultsFor('stelaris-ui').rolesFrom(spread);

      expect(roles, {'from-access-token', 'from-id-token', 'from-userinfo'});
    });

    test('reads roles that live only in the access token', () {
      // Keycloak's realm and client roles, without a mapper copying them into
      // the ID token.
      final roles = RoleMapper(
        paths: AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
        sources: const [ClaimSource.accessToken],
      ).rolesFrom(spread);

      expect(roles, {'from-access-token'});
    });

    test('reads roles that live only in the userinfo response', () {
      final roles = RoleMapper(
        paths: AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
        sources: const [ClaimSource.userInfo],
      ).rolesFrom(spread);

      expect(roles, {'from-userinfo'});
    });

    test('does not read a source the configuration leaves out', () {
      // Naming a source is also how a deployment excludes one.
      final roles = RoleMapper(
        paths: AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
        sources: const [ClaimSource.idToken, ClaimSource.userInfo],
      ).rolesFrom(spread);

      expect(roles, isNot(contains('from-access-token')));
      expect(roles, {'from-id-token', 'from-userinfo'});
    });

    test('an empty source contributes nothing and stops nothing', () {
      // What an opaque access token looks like by the time it gets here.
      const TokenClaims opaque = TokenClaims(
        idToken: {
          'roles': ['editor'],
        },
      );

      expect(defaultsFor('stelaris-ui').rolesFrom(opaque), {'editor'});
    });
  });

  group('TokenClaims.decode', () {
    // Assembled rather than pasted: a literal token is a high-entropy blob a
    // secret scanner cannot tell from a real credential. See jwt_builder.dart.
    final String jwt = unsignedJwt(const {
      'sub': 'abc',
      'roles': ['admin'],
    });

    test('reads the claims of a JSON Web Token', () {
      expect(TokenClaims.decode(jwt), containsPair('roles', ['admin']));
    });

    test('gives back nothing for an opaque token', () {
      // Entra ID without an API scope hands out something like this.
      expect(TokenClaims.decode('0.AAAAopaque-blob'), isEmpty);
    });

    test('gives back nothing for a truncated token', () {
      // A header and nothing after it. Cut from a built token rather than
      // written out: even a lone JWT header is the base64 shape scanners match.
      final String headerOnly = unsignedJwt(const {'sub': 'abc'}).split('.').first;

      expect(TokenClaims.decode(headerOnly), isEmpty);
    });

    test('gives back nothing for no token at all', () {
      expect(TokenClaims.decode(null), isEmpty);
      expect(TokenClaims.decode('   '), isEmpty);
    });

    test('a decoded opaque token still leaves the other sources readable', () {
      final claims = TokenClaims(
        accessToken: TokenClaims.decode('not-a-jwt'),
        idToken: const {
          'roles': ['editor'],
        },
      );

      expect(defaultsFor('stelaris-ui').rolesFrom(claims), {'editor'});
    });
  });

  group('RoleMapper - renaming raw values', () {
    RoleMapper withAliases(Map<String, String> aliases) => RoleMapper(
      paths: AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
      sources: AuthConfig.defaultRoleClaimsSource,
      aliases: aliases,
    );

    const String groupId = '6dbd7a4d-d61c-47f5-8f7d-db368e3f9dae';

    test('turns an object id into the name the application gates on', () {
      // Entra ID emits one of these per group unless every group is synced
      // from an on-premises directory, and they differ per tenant - so gating
      // code cannot name one without this.
      final roles = withAliases({groupId: 'stelaris.admin'}).rolesFrom(
        const TokenClaims(accessToken: {
          'groups': [groupId],
        }),
      );

      expect(roles, {'stelaris.admin'});
    });

    test('leaves a value nobody mapped alone', () {
      // A token carrying real names and opaque ids at once stays legible in
      // both halves.
      final roles = withAliases({groupId: 'stelaris.admin'}).rolesFrom(
        const TokenClaims(accessToken: {
          'groups': [groupId, 'an-unmapped-group'],
          'roles': ['stelaris.editor'],
        }),
      );

      expect(roles, {'stelaris.admin', 'an-unmapped-group', 'stelaris.editor'});
    });

    test('matches an object id whatever its case', () {
      // These get copied out of portals by hand; a table that misses on case
      // is worse than no table, because it looks configured.
      final roles = withAliases({groupId.toUpperCase(): 'stelaris.admin'})
          .rolesFrom(const TokenClaims(accessToken: {
        'groups': [groupId],
      }));

      expect(roles, {'stelaris.admin'});
    });

    test('prefers an exact match over one that only differs in case', () {
      final roles = withAliases({
        'Admins': 'from-exact',
        'admins': 'from-lowercase',
      }).rolesFrom(const TokenClaims(accessToken: {
        'groups': ['Admins'],
      }));

      expect(roles, {'from-exact'});
    });

    test('collapses two ids mapped to the same name', () {
      final roles = withAliases({
        groupId: 'stelaris.admin',
        'another-group-id': 'stelaris.admin',
      }).rolesFrom(const TokenClaims(accessToken: {
        'groups': [groupId, 'another-group-id'],
      }));

      expect(roles, {'stelaris.admin'});
    });

    test('changes nothing when no table is configured', () {
      final roles = defaultsFor('stelaris-ui').rolesFrom(
        const TokenClaims(accessToken: {
          'groups': [groupId],
        }),
      );

      expect(roles, {groupId});
    });
  });

  group('RoleMapper - claims it cannot use', () {
    test('returns an empty set for a token carrying no roles', () {
      final roles = defaultsFor('stelaris-ui').rolesFrom(const TokenClaims(accessToken: {'sub': 'abc'}));

      expect(roles, isEmpty);
    });

    test('returns an empty set for empty claims', () {
      expect(defaultsFor('stelaris-ui').rolesFrom(TokenClaims.empty), isEmpty);
    });

    test('skips a path holding something that is not a role name', () {
      final roles = defaultsFor('stelaris-ui').rolesFrom(const TokenClaims(accessToken: {
        'roles': 42,
        'groups': ['viewer'],
      }));

      // The unusable path contributes nothing; the others are still read.
      expect(roles, {'viewer'});
    });

    test('skips a path holding an object', () {
      final roles = defaultsFor('stelaris-ui').rolesFrom(const TokenClaims(accessToken: {
        'roles': {'admin': true},
        'groups': ['viewer'],
      }));

      expect(roles, {'viewer'});
    });

    test('keeps the usable entries of a mixed list', () {
      final roles = defaultsFor('stelaris-ui').rolesFrom(const TokenClaims(accessToken: {
        'roles': ['admin', 7, null, '  editor  ', '   '],
      }));

      expect(roles, {'admin', 'editor'});
    });

    test('walking through a non-object stops instead of throwing', () {
      final roles = defaultsFor('stelaris-ui').rolesFrom(const TokenClaims(accessToken: {
        'realm_access': 'not an object',
      }));

      expect(roles, isEmpty);
    });

    test('a path into a missing branch contributes nothing', () {
      final roles = defaultsFor('stelaris-ui').rolesFrom(const TokenClaims(accessToken: {
        'resource_access': {
          'another-client': {
            'roles': ['nope'],
          },
        },
      }));

      expect(roles, isEmpty);
    });

    test('the returned set cannot be modified by a caller', () {
      final roles = defaultsFor('stelaris-ui').rolesFrom(const TokenClaims(accessToken: {
        'roles': ['admin'],
      }));

      expect(() => roles.add('smuggled'), throwsUnsupportedError);
    });
  });
}
