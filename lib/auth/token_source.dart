/// What an API client needs from a session, and nothing more.
///
/// Narrow on purpose. The client should not be able to sign anybody in or out,
/// and a test should not have to build a session to exercise a retry.
abstract interface class TokenSource {
  /// The bearer credential for the next request, or null when there is none.
  ///
  /// The access token. Never the ID token: that identifies the person to this
  /// application, not this application to the backend.
  String? get accessToken;

  /// Renews the session, answering whether a usable token came back.
  ///
  /// Callers must not run two of these at once: a provider that rotates
  /// refresh tokens ends the session when one is presented twice.
  Future<bool> refresh();
}
