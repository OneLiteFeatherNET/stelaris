import 'package:flutter/foundation.dart';

/// Where the session stands.
enum AuthStatus {
  /// No identity provider is configured. The app runs as it did before
  /// authentication existed, and nothing in the interface mentions signing in.
  disabled,

  /// Working out whether a session can be restored, before the first frame
  /// that depends on the answer.
  initialising,

  /// A provider is configured but could not be reached - its discovery document
  /// did not load, or does not describe a provider this app can use. Deliberately
  /// distinct from [signedOut]: there is nothing to sign in to yet, and falling
  /// back to running unauthenticated would quietly drop the requirement.
  unavailable,

  /// Nobody is signed in.
  signedOut,

  /// Somebody is.
  signedIn,

  /// A session ended because it could not be renewed. Distinct from
  /// [signedOut] only so the interface can say why, rather than presenting an
  /// expiry as though the person had signed out on purpose.
  expired,
}

/// What the interface is allowed to know about the session.
///
/// Facts, never credentials. Access, refresh and ID tokens live in the session
/// store and are reachable only through the client that attaches them to a
/// request: [AppState] is serialised into browser storage in full, and the
/// Content-Security-Policy a Flutter bundle forces - inline and evaluated
/// script both permitted - means injected script can read whatever is there.
///
/// This is a plain immutable class rather than a generated one on purpose.
/// There is no `toJson` to call, so no future change can persist it by
/// accident; the guarantee is structural instead of a convention to remember.
@immutable
class AuthState {
  const AuthState({
    required this.status,
    this.displayName,
    this.roles = const <String>{},
  });

  /// The state of a deployment that configured no identity provider.
  const AuthState.disabled()
    : status = AuthStatus.disabled,
      displayName = null,
      roles = const <String>{};

  final AuthStatus status;

  /// What to call the signed-in person, when the provider said. Absent is
  /// ordinary: a provider need not release a name, and nothing depends on one.
  final String? displayName;

  /// The roles the token grants, normalised across providers.
  final Set<String> roles;

  /// Whether a session is usable right now.
  bool get isSignedIn => status == AuthStatus.signedIn;

  /// Whether the interface should offer signing in at all.
  bool get isEnabled => status != AuthStatus.disabled;

  /// Whether the signed-in person holds [role].
  ///
  /// False whenever nobody is signed in, so a caller never has to check both.
  /// A deployment without a provider is the exception: with no provider there
  /// are no roles to withhold, so everything the backend allows stays offered.
  bool hasRole(String role) {
    if (status == AuthStatus.disabled) {
      return true;
    }
    return isSignedIn && roles.contains(role);
  }

  AuthState copyWith({
    AuthStatus? status,
    String? displayName,
    Set<String>? roles,
  }) => AuthState(
    status: status ?? this.status,
    displayName: displayName ?? this.displayName,
    roles: roles ?? this.roles,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          other.status == status &&
          other.displayName == displayName &&
          setEquals(other.roles, roles);

  @override
  int get hashCode => Object.hash(status, displayName, Object.hashAll(roles));

  @override
  String toString() =>
      'AuthState(${status.name}, displayName: $displayName, '
      'roles: ${roles.length})';
}
