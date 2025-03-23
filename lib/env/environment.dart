/// This file contains the environment variables for the app
/// The pipeline should replace this constant with the right data
class Environment {
  static const String backendURl =
      String.fromEnvironment('BACKEND_URL', defaultValue: '');
  static const String generatorUrl =
      String.fromEnvironment('GENERATOR_URL', defaultValue: '');
}
