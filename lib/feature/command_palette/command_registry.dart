import 'package:stelaris/feature/command_palette/command.dart';
import 'package:stelaris/feature/command_palette/command_search.dart';
import 'package:stelaris/feature/command_palette/palette_mode.dart';
import 'package:stelaris/l10n/app_localizations.dart';

/// The commands the palette can offer, and the two questions it asks of them:
/// which may run here, and which match what was typed.
class CommandRegistry {
  CommandRegistry(List<StelarisCommand> commands)
    : all = List<StelarisCommand>.unmodifiable(
        // Group order first, so an empty query already reads as grouped;
        // within a group the order the commands were declared in.
        _byGroup(commands),
      );

  final List<StelarisCommand> all;

  /// The commands [context] allows: the command's own availability check
  /// passes.
  List<StelarisCommand> available(CommandContext context) {
    return all.where((command) => command.isAvailable(context)).toList();
  }

  /// The available commands of [mode] matching [query], best match first.
  ///
  /// An empty query returns every available command in group order. A match
  /// on the title always outranks a match found only in the keywords; equal
  /// scores keep registry order.
  List<StelarisCommand> search(
    String query,
    CommandContext context,
    AppLocalizations l10n, {
    PaletteMode mode = PaletteMode.commands,
  }) {
    final List<StelarisCommand> candidates = available(context)
        .where((command) => command.modes.contains(mode))
        .toList();
    if (query.trim().isEmpty) {
      return candidates;
    }

    final List<(int, int, StelarisCommand)> scored = [];
    for (int i = 0; i < candidates.length; i++) {
      final StelarisCommand command = candidates[i];
      final int? score = _score(query, command, l10n);
      if (score != null) {
        scored.add((score, i, command));
      }
    }
    // Dart's sort is not stable, hence the index as the tie-breaker.
    scored.sort((a, b) {
      final int byScore = b.$1.compareTo(a.$1);
      return byScore != 0 ? byScore : a.$2.compareTo(b.$2);
    });
    return scored.map((entry) => entry.$3).toList();
  }

  static const int _titleBonus = 1000;

  static int? _score(
    String query,
    StelarisCommand command,
    AppLocalizations l10n,
  ) {
    final int? title = scoreMatch(query, command.title(l10n));
    if (title != null) {
      return title + _titleBonus;
    }
    int? best;
    for (final String keyword in command.keywords(l10n)) {
      final int? score = scoreMatch(query, keyword);
      if (score != null && (best == null || score > best)) {
        best = score;
      }
    }
    return best;
  }

  static List<StelarisCommand> _byGroup(List<StelarisCommand> commands) {
    return [
      for (final CommandGroup group in CommandGroup.values)
        ...commands.where((command) => command.group == group),
    ];
  }
}
