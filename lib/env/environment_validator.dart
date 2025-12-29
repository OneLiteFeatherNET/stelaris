class EnvironmentValidator {

  /// Ensures that a required build-time variable is present.
  ///
  /// [value] The resolved environment value.
  /// [name]  The name of the dart-define variable (for error reporting).
  ///
  /// An assertion error is raised if the value is empty, causing the
  /// application to fail early and visibly.
  static String require(String value, String name) {
    assert(value.isNotEmpty, 'Missing required dart-define: $name');
    return value;
  }
}