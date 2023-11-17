@Deprecated('Will be deleted in the next time')
class Checks {

  static void argCondition(bool check, String message) {
    if (check) {
      throw FormatException(message);
    }
  }
}