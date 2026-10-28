/// A starting identifier for a function named [uiName]: its letters, digits
/// and underscores, with any other character read as an underscore. The
/// identifier must start with a letter or underscore, so a leading digit gets
/// one in front, and an empty name becomes `function`.
String functionIdentifierFor(String uiName) {
  final cleaned = uiName.trim().replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
  if (cleaned.isEmpty) return 'function';
  return RegExp(r'^[0-9]').hasMatch(cleaned) ? '_$cleaned' : cleaned;
}
