import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/auth/auth_state.dart';

/// A session as it looks once somebody has signed in, with values distinctive
/// enough that finding any of them in a persisted document is unambiguous.
const AuthState signedIn = AuthState(
  status: AuthStatus.signedIn,
  displayName: 'Ada Lovelace',
  roles: {'stelaris.admin'},
);

/// The exact round trip [AppPersistor] performs: encode what `toJson` returns,
/// then read it back. Encoding is the step that flattens nested models, so a
/// test that skipped it would not be testing what reaches storage.
String persist(AppState state) => jsonEncode(state.toJson());

AppState restore(String document) =>
    AppState.fromJson(jsonDecode(document) as Map<String, dynamic>);

void main() {
  group('AuthState is never persisted', () {
    test('a signed-in state contributes nothing to the document', () {
      const AppState state = AppState(auth: signedIn);

      final String document = persist(state);

      // Not the status, not the name, not the roles - and no key for the
      // session at all. Tokens are not in AuthState to begin with; this is the
      // test that stops the next field added there from reaching storage.
      expect(document, isNot(contains('signedIn')));
      expect(document, isNot(contains('Ada Lovelace')));
      expect(document, isNot(contains('stelaris.admin')));
      expect(document, isNot(contains('auth')));
    });

    test('the document is identical with and without a session', () {
      const AppState anonymous = AppState();
      const AppState authenticated = AppState(auth: signedIn);

      expect(persist(authenticated), persist(anonymous));
    });

    test('a restored state comes back signed out, not signed in', () {
      const AppState state = AppState(auth: signedIn);

      final AppState restored = restore(persist(state));

      // Whether a session exists is the session store's answer, never a
      // document's: a persisted "signed in" would outlive the session itself.
      expect(restored.auth, const AuthState.disabled());
      expect(restored.auth.isSignedIn, isFalse);
    });

    test('settings still survive the round trip', () {
      // The exclusion is scoped to the session; everything else persists as
      // before.
      const AppState state = AppState(auth: signedIn, openNavigation: false);

      expect(restore(persist(state)).openNavigation, isFalse);
    });
  });

  group('AuthState', () {
    test('holds no role while nobody is signed in', () {
      const AuthState expired = AuthState(
        status: AuthStatus.expired,
        roles: {'stelaris.admin'},
      );

      // The roles are stale the moment the session ends.
      expect(expired.hasRole('stelaris.admin'), isFalse);
    });

    test('withholds nothing when no provider is configured', () {
      // With no provider there are no roles to grant, so gating on one would
      // hide every restricted action in a deployment that never opted in.
      expect(const AuthState.disabled().hasRole('stelaris.admin'), isTrue);
      expect(const AuthState.disabled().isEnabled, isFalse);
    });

    test('grants only the roles the token carried', () {
      expect(signedIn.hasRole('stelaris.admin'), isTrue);
      expect(signedIn.hasRole('stelaris.editor'), isFalse);
    });
  });
}
