/// Returns the summary of [notes]: their first non-blank line, trimmed.
///
/// Notes follow the commit-message convention — the first line is a short
/// summary shown in the overview, everything after it is the long form only
/// shown on the detail page. Returns `null` when [notes] holds no text.
String? notesSummary(String? notes) {
  if (notes == null) return null;
  for (final line in notes.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return null;
}
