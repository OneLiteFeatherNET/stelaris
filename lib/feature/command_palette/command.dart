import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/palette_mode.dart';
import 'package:stelaris/l10n/app_localizations.dart';

/// The headings the palette sorts its commands under, in display order.
enum CommandGroup {
  navigation,
  create,
  interface,
  backend,
  entities,
  projects,
  help,
}

/// Where an entry takes the palette instead of running: a mode, optionally a
/// kind, and the text to start with.
@immutable
class PaletteSwitch {
  const PaletteSwitch(this.mode, {this.kind, this.text = ''});

  final PaletteMode mode;
  final EntityKind? kind;
  final String text;
}

/// What a command may look at to decide whether it can run right now.
///
/// Captured once, when the palette opens: nothing a command depends on can
/// change while the modal palette is on screen.
@immutable
class CommandContext {
  const CommandContext({required this.state, required this.location});

  final AppState state;

  /// The matched route, e.g. `/items` or `/items/detail`.
  final String location;
}

/// One entry in the command palette.
///
/// Plain data plus two callbacks, with no widget of its own, so which commands
/// are offered and how they rank can be tested without pumping a UI.
@immutable
class StelarisCommand {
  const StelarisCommand({
    required this.id,
    required this.title,
    required this.group,
    required this.icon,
    required this.run,
    this.keywords = _noKeywords,
    this.isAvailable = _always,
    this.modes = const {PaletteMode.commands},
    this.subtitle,
    this.section,
    this.switchTo,
    this.inert = false,
    this.children,
    this.isCurrent,
    this.currentIcon,
  });

  /// Stable identifier, e.g. `nav.items` or `backend.reload-branches`.
  final String id;

  final String Function(AppLocalizations l10n) title;

  /// Extra search terms that do not appear in [title].
  final List<String> Function(AppLocalizations l10n) keywords;

  final CommandGroup group;
  final IconData icon;

  /// Whether the command makes sense in [CommandContext].
  final bool Function(CommandContext context) isAvailable;

  /// Runs the command with the context of the page the palette was opened
  /// from - the palette itself is already gone by then.
  final Future<void> Function(BuildContext context) run;

  /// The palette modes that list this command.
  final Set<PaletteMode> modes;

  /// A second line under the title.
  final String Function(AppLocalizations l10n)? subtitle;

  /// Overrides the [group] heading, e.g. an entity's kind.
  final String Function(AppLocalizations l10n)? section;

  /// Set on entries that change the palette itself - help and fallbacks. The
  /// palette switches mode and stays open instead of calling [run].
  final PaletteSwitch? switchTo;

  /// Entries that are only there to be read, like the keys listed in help:
  /// choosing one does nothing and leaves the palette open.
  final bool inert;

  /// What Arrow Right steps into, e.g. an item's tabs. Null for entries
  /// without sub-entries.
  final List<StelarisCommand> Function()? children;

  /// Whether this entry is where the user already is, e.g. "Go to Fonts" on
  /// the Fonts page. The palette marks it rather than hiding it.
  final bool Function(CommandContext context)? isCurrent;

  /// The icon to show while [isCurrent] holds, like the side navigation's
  /// filled one.
  final IconData? currentIcon;

  static List<String> _noKeywords(AppLocalizations _) => const <String>[];

  static bool _always(CommandContext _) => true;

  /// A [run] for entries that only carry a [switchTo].
  static Future<void> noRun(BuildContext _) async {}
}
