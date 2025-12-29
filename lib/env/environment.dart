/// Centralized environment configuration for build-time variables.
///
/// This class provides access to configuration values that are injected
/// at build time via `--dart-define`. It is primarily intended for
/// Flutter Web, where runtime environment variables are not available.
///
/// The configuration follows a *fail-fast* approach:
/// required variables are validated on access and will cause the
/// application to abort early if they are missing or empty.
///
/// Usage:
///   flutter build web \
///     --dart-define=CONCEPT_URL=https://example.com/docs \
///     --dart-define=GIT_URL=https://github.com/example/repo
///
/// Notes:
/// - All values are embedded at compile time and are therefore public.
/// - This mechanism must not be used for secrets or private credentials.
/// - Validation is performed via assertions to ensure early failure
///   during development and CI builds.
/// Do NOT store secrets here. All values are public.
class Environment {
  static const String _backendUrl = String.fromEnvironment('BACKEND_URL');

  static const String _generatorUrl = String.fromEnvironment('GENERATOR_URL');

  static const String _conceptUrl = String.fromEnvironment('CONCEPT_URL');

  static const String _gitBugUrl = String.fromEnvironment('GIT_BUG_URL');

  static const String _gitSuggestionUrl = String.fromEnvironment('GITHUB_SUGGESTION_URL');

  /// Base URL of the backend API
  static String get backendUrl => _require(_backendUrl, 'BACKEND_URL');

  /// URL of the generator / worker service
  static String get generatorUrl => _require(_generatorUrl, 'GENERATOR_URL');

  /// Documentation / concept page URL
  static String get conceptUrl => _require(_conceptUrl, 'CONCEPT_URL');

  /// Issue tracker or repository URL
  static String get gitBugUrl => _require(_gitBugUrl, 'GIT_BUG_URL');

  /// Suggestion URL
  static String get gitSuggestionUrl => _require(_gitSuggestionUrl, 'GITHUB_SUGGESTION_URL');

  /// Ensures that a required build-time variable is present.
  ///
  /// [value] The resolved environment value.
  /// [name]  The name of the dart-define variable (for error reporting).
  ///
  /// An assertion error is raised if the value is empty, causing the
  /// application to fail early and visibly.
  static String _require(String value, String name) {
    assert(value.isNotEmpty, 'Missing required dart-define: $name');
    return value;
  }
}
