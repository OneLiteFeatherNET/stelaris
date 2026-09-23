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
/// `so` in "Lessons" should score the adjacent "so", not the first "s". The
/// strings are command titles, so the quadratic cost is irrelevant.
int? scoreMatch(String query, String candidate) {
  final String q = query.toLowerCase().replaceAll(' ', '');
  if (q.isEmpty) {
    return 0;
  }
  final String c = candidate.toLowerCase();

  // best[j]: the highest score for the query characters matched so far with
  // the last one placed at candidate index j, or null if impossible.
  List<int?> best = List<int?>.filled(c.length, null);
  for (int j = 0; j < c.length; j++) {
    if (c[j] == q[0]) {
      best[j] = _hit(c, j, adjacent: false);
    }
  }
  for (int i = 1; i < q.length; i++) {
    final List<int?> next = List<int?>.filled(c.length, null);
    for (int j = i; j < c.length; j++) {
      if (c[j] != q[i]) {
        continue;
      }
      for (int k = 0; k < j; k++) {
        final int? previous = best[k];
        if (previous == null) {
          continue;
        }
        final int score = previous + _hit(c, j, adjacent: k == j - 1);
        if (next[j] == null || score > next[j]!) {
          next[j] = score;
        }
      }
    }
    best = next;
  }

  int? result;
  for (final int? score in best) {
    if (score != null && (result == null || score > result)) {
      result = score;
    }
  }
  return result;
}

int _hit(String text, int index, {required bool adjacent}) {
  int score = 1;
  if (index == 0) {
    score += 8;
  } else if (_isWordStart(text, index)) {
    score += 5;
  }
  if (adjacent) {
    score += 3;
  }
  return score;
}

bool _isWordStart(String text, int index) {
  final String before = text[index - 1];
  return before == ' ' || before == '-' || before == '_' || before == '/';
}
