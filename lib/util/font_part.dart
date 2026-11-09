/// The characters of a font line.
///
/// A font line may only hold characters of the Unicode Private Use Area, so a
/// custom glyph never replaces a regular character. The backend enforces the
/// same rule. Flutter has no glyph for these characters, so the app shows and
/// takes them as hex code points like `E000 E001`.
library;

/// The maximum length of a font line in UTF-16 code units, the length of its
/// database column. A code point of plane 15 or 16 takes two units.
const int maxFontLineLength = 255;

final RegExp _hexCodePoint = RegExp(r'^[0-9A-Fa-f]{4,6}$');

/// Whether [codePoint] lies in one of the three Private Use Areas:
/// `E000–F8FF`, `F0000–FFFFD` (plane 15) and `100000–10FFFD` (plane 16).
bool isFontPart(int codePoint) =>
    (codePoint >= 0xE000 && codePoint <= 0xF8FF) ||
    (codePoint >= 0xF0000 && codePoint <= 0xFFFFD) ||
    (codePoint >= 0x100000 && codePoint <= 0x10FFFD);

/// Parses hex code points separated by whitespace, like `E000 e001 F0000`.
///
/// Returns `null` when [input] is blank or a part is not 4 to 6 hex digits.
/// It does not check the Private Use Area, see [isFontPart].
List<int>? parseCodePoints(String input) {
  final parts = input.trim().split(RegExp(r'\s+'));
  if (parts.length == 1 && parts.first.isEmpty) return null;
  final codePoints = <int>[];
  for (final part in parts) {
    if (!_hexCodePoint.hasMatch(part)) return null;
    codePoints.add(int.parse(part, radix: 16));
  }
  return codePoints;
}

/// Formats the characters of [line] as uppercase hex code points separated by
/// a space, like `E000 E001 F0000`.
String formatCodePoints(String line) => line.runes
    .map((rune) => rune.toRadixString(16).toUpperCase().padLeft(4, '0'))
    .join(' ');

/// The distinct lengths of [lines] in characters, ascending.
///
/// A bitmap provider cuts its texture into cells by the length of its rows,
/// so Minecraft rejects a font whose rows differ in length. More than one
/// length means the font is broken.
List<int> rowLengths(Iterable<String> lines) =>
    (lines.map((line) => line.runes.length).toSet().toList()..sort());

/// The length the lines of a font should have: the most common length of
/// [lines], on a tie the one that comes first. `null` for no lines.
///
/// A line of another length is the one to fix when [rowLengths] finds more
/// than one length.
int? expectedRowLength(List<String> lines) {
  final counts = <int, int>{};
  for (final line in lines) {
    final length = line.runes.length;
    counts[length] = (counts[length] ?? 0) + 1;
  }
  int? expected;
  for (final line in lines) {
    final length = line.runes.length;
    if (expected == null || counts[length]! > counts[expected]!) {
      expected = length;
    }
  }
  return expected;
}
