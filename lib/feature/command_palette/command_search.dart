import 'dart:typed_data';

/// Scores how well [query] matches [candidate], or returns null when it does
/// not match at all.
///
/// A candidate matches when every character of the query appears in it in
/// order, ignoring case and spaces in the query, so `gtit` finds "Go to Items".
/// Among matches, higher is better: a hit on the first character, a hit at the
/// start of a word and a hit right after the previous one each add to the
/// score, so "Items" ranks above a title that merely contains those letters
/// scattered about.
///
/// Every placement of the query is considered, not just the first one found:
/// `so` in "Lessons" should score the adjacent "so", not the first "s". It
/// runs for every loaded entity on every keystroke, so it is linear per query
/// character, and a greedy pass rejects non-matches first.
int? scoreMatch(String query, String candidate) {
  final String q = query.toLowerCase().replaceAll(' ', '');
  if (q.isEmpty) {
    return 0;
  }
  final String c = candidate.toLowerCase();

  // Most candidates don't contain the query at all: a greedy pass rejects
  // them in one sweep before the DP below runs.
  int from = 0;
  for (int i = 0; i < q.length; i++) {
    final int found = c.indexOf(q[i], from);
    if (found < 0) {
      return null;
    }
    from = found + 1;
  }

  // best[j]: the highest score for the query characters matched so far with
  // the last one placed at candidate index j, or [_none] if impossible. Two
  // rows, reused across calls: this runs for every loaded entity on every
  // keystroke, and fresh lists per character dominated its cost.
  final int length = c.length;
  if (_rowA.length < length) {
    _rowA = Int32List(length * 2);
    _rowB = Int32List(length * 2);
  }
  Int32List best = _rowA;
  Int32List next = _rowB;
  for (int j = 0; j < length; j++) {
    best[j] = c[j] == q[0] ? _hit(c, j, adjacent: false) : _none;
  }
  for (int i = 1; i < q.length; i++) {
    final String char = q[i];
    next[0] = _none;
    // The best placement of the previous character anywhere before j - 1,
    // i.e. not adjacent to j. Carried along instead of rescanned, which
    // keeps each row linear in the title's length.
    int bestApart = _none;
    for (int j = 1; j < length; j++) {
      if (j >= 2 && best[j - 2] > bestApart) {
        bestApart = best[j - 2];
      }
      if (c[j] != char) {
        next[j] = _none;
        continue;
      }
      int score = _none;
      final int adjacent = best[j - 1];
      if (adjacent != _none) {
        score = adjacent + _hit(c, j, adjacent: true);
      }
      if (bestApart != _none) {
        final int apart = bestApart + _hit(c, j, adjacent: false);
        if (apart > score) {
          score = apart;
        }
      }
      next[j] = score;
    }
    final Int32List swap = best;
    best = next;
    next = swap;
  }

  int result = _none;
  for (int j = 0; j < length; j++) {
    if (best[j] > result) {
      result = best[j];
    }
  }
  return result == _none ? null : result;
}

/// "No placement": below any real score, which is never negative.
const int _none = -1;

Int32List _rowA = Int32List(64);
Int32List _rowB = Int32List(64);

int _hit(String text, int index, {required bool adjacent}) {
  int score = 1;
  if (index == 0) {
    score += 8;
  } else if (_isWordStart(text, index)) {
    score += 5;
  }
  // Higher than a word start: "bla" means "Blade" before "Big long armor".
  if (adjacent) {
    score += 6;
  }
  return score;
}

bool _isWordStart(String text, int index) {
  final String before = text[index - 1];
  return before == ' ' || before == '-' || before == '_' || before == '/';
}
