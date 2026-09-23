import 'package:material_ui/material_ui.dart';
import 'package:stelaris/l10n/app_localizations.dart';

/// What the palette is searching.
enum PaletteMode { commands, navigation, entities, projects, settings, help }

/// The kinds of entity the entity mode can search, in display order.
enum EntityKind { item, font, sound, notification, attribute }

/// One row of the syntax table: how a mode is typed and how it is described.
///
/// The parser, the chip and the `?` help all read from [modeSpecs], so the
/// help can never list a prefix the parser does not accept, or miss one.
@immutable
class ModeSpec {
  const ModeSpec({
    required this.mode,
    required this.sigil,
    required this.aliases,
    required this.label,
    required this.describe,
  });

  final PaletteMode mode;
  final String sigil;

  /// Words that select this mode when followed by a space. Entity kinds add
  /// their own aliases on top, see [kindAliases].
  final List<String> aliases;

  final String Function(AppLocalizations l10n) label;
  final String Function(AppLocalizations l10n) describe;
}

final List<ModeSpec> modeSpecs = [
  ModeSpec(
    mode: PaletteMode.commands,
    sigil: '>',
    aliases: const [],
    label: (l10n) => l10n.command_palette_mode_commands,
    describe: (l10n) => l10n.command_palette_mode_commands_help,
  ),
  ModeSpec(
    mode: PaletteMode.navigation,
    sigil: ':',
    // Every "Go to" title starts with "go " - safe, because navigation mode
    // lists exactly those commands. See the alias collision test.
    aliases: const ['go'],
    label: (l10n) => l10n.command_palette_mode_navigation,
    describe: (l10n) => l10n.command_palette_mode_navigation_help,
  ),
  ModeSpec(
    mode: PaletteMode.entities,
    sigil: '#',
    aliases: const [],
    label: (l10n) => l10n.command_palette_mode_entities,
    describe: (l10n) => l10n.command_palette_mode_entities_help,
  ),
  ModeSpec(
    mode: PaletteMode.projects,
    sigil: '@',
    aliases: const ['project', 'projects'],
    label: (l10n) => l10n.command_palette_mode_projects,
    describe: (l10n) => l10n.command_palette_mode_projects_help,
  ),
  ModeSpec(
    mode: PaletteMode.settings,
    sigil: '/',
    aliases: const ['setting', 'settings'],
    label: (l10n) => l10n.command_palette_mode_settings,
    describe: (l10n) => l10n.command_palette_mode_settings_help,
  ),
  ModeSpec(
    mode: PaletteMode.help,
    sigil: '?',
    aliases: const [],
    label: (l10n) => l10n.command_palette_mode_help,
    describe: (l10n) => l10n.command_palette_mode_help,
  ),
];

ModeSpec specFor(PaletteMode mode) =>
    modeSpecs.firstWhere((spec) => spec.mode == mode);

/// Words that select entity mode restricted to one kind.
const Map<EntityKind, List<String>> kindAliases = {
  EntityKind.item: ['item', 'items'],
  EntityKind.font: ['font', 'fonts'],
  EntityKind.sound: ['sound', 'sounds'],
  EntityKind.notification: ['notification', 'notifications'],
  EntityKind.attribute: ['attribute', 'attributes'],
};

String kindLabel(EntityKind kind, AppLocalizations l10n) {
  return switch (kind) {
    EntityKind.item => l10n.command_palette_kind_items,
    EntityKind.font => l10n.command_palette_kind_fonts,
    EntityKind.sound => l10n.command_palette_kind_sounds,
    EntityKind.notification => l10n.command_palette_kind_notifications,
    EntityKind.attribute => l10n.command_palette_kind_attributes,
  };
}

/// Every alias that switches mode, for the collision check against titles.
Iterable<String> get allAliases => [
  for (final spec in modeSpecs) ...spec.aliases,
  for (final aliases in kindAliases.values) ...aliases,
];

/// A query split into what it asks for and what it searches with.
@immutable
class ParsedQuery {
  const ParsedQuery({this.mode, this.kind, this.text = ''});

  /// Null is the default mode: commands, with fallbacks to other modes.
  final PaletteMode? mode;

  /// Only ever set together with [PaletteMode.entities].
  final EntityKind? kind;

  final String text;

  @override
  bool operator ==(Object other) =>
      other is ParsedQuery &&
      other.mode == mode &&
      other.kind == kind &&
      other.text == text;

  @override
  int get hashCode => Object.hash(mode, kind, text);

  @override
  String toString() => 'ParsedQuery($mode, $kind, "$text")';
}

/// Reads a mode, and in entity mode a kind, off the front of [raw].
///
/// [mode] and [kind] are what the palette already holds as its chip; only
/// what is still missing is looked for, so text typed after a chip is never
/// read as a second prefix. In order:
///
/// 1. A leading sigil sets the mode.
/// 2. Otherwise a leading alias followed by a space sets the mode, and for an
///    entity alias the kind as well. Without the space it is ordinary text,
///    so "items" still finds "Go to Items".
/// 3. In entity mode without a kind, a leading kind alias followed by a space
///    sets the kind: `#item sword`.
ParsedQuery parseQuery(String raw, {PaletteMode? mode, EntityKind? kind}) {
  String rest = raw;

  if (mode == null) {
    for (final ModeSpec spec in modeSpecs) {
      if (rest.startsWith(spec.sigil)) {
        mode = spec.mode;
        rest = rest.substring(spec.sigil.length);
        break;
      }
    }
  }

  if (mode == null) {
    final (String, String)? word = _leadingWord(rest);
    if (word != null) {
      final (String alias, String after) = word;
      final EntityKind? aliasedKind = _kindFor(alias);
      if (aliasedKind != null) {
        return ParsedQuery(
          mode: PaletteMode.entities,
          kind: aliasedKind,
          text: after,
        );
      }
      for (final ModeSpec spec in modeSpecs) {
        if (spec.aliases.contains(alias)) {
          return ParsedQuery(mode: spec.mode, text: after);
        }
      }
    }
  }

  if (mode == PaletteMode.entities && kind == null) {
    final (String, String)? word = _leadingWord(rest);
    final EntityKind? aliasedKind = word == null ? null : _kindFor(word.$1);
    if (aliasedKind != null) {
      return ParsedQuery(mode: mode, kind: aliasedKind, text: word!.$2);
    }
  }

  return ParsedQuery(mode: mode, kind: kind, text: rest);
}

/// The first word of [text], lowercased, and what follows its space - but
/// only once the space has been typed.
(String, String)? _leadingWord(String text) {
  final int space = text.indexOf(' ');
  if (space <= 0) {
    return null;
  }
  return (text.substring(0, space).toLowerCase(), text.substring(space + 1));
}

EntityKind? _kindFor(String alias) {
  for (final MapEntry<EntityKind, List<String>> entry in kindAliases.entries) {
    if (entry.value.contains(alias)) {
      return entry.key;
    }
  }
  return null;
}
