final _anyOtherCharacters = RegExp(r'[^a-z0-9._-]+');
final _repeatedUnderscores = RegExp(r'_{2,}');
final _repeatedDots = RegExp(r'\.{2,}');
final _edgeUnderscores = RegExp(r'^_+|_+$');

const _spelledOut = {'ä': 'ae', 'ö': 'oe', 'ü': 'ue', 'ß': 'ss'};

/// A starting key part for a model named [name], e.g. `my_sword` for
/// `My Sword`: lower-cased, umlauts spelled out, and every run of characters
/// a key part can't hold read as one underscore. A name with nothing usable
/// in it gives an empty key.
String keyFromName(String name) {
  var key = name.trim().toLowerCase();
  _spelledOut.forEach((from, to) => key = key.replaceAll(from, to));
  return key
      .replaceAll(_anyOtherCharacters, '_')
      .replaceAll(_repeatedUnderscores, '_')
      .replaceAll(_repeatedDots, '.')
      .replaceAll(_edgeUnderscores, '');
}
