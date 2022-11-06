class Checks {

  static void argCondition(bool check, String message) {
    if (check) {
      throw FormatException(message);
    }
  }
}