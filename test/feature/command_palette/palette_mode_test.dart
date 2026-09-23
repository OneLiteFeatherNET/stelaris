import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/command_palette/commands.dart';
import 'package:stelaris/feature/command_palette/palette_mode.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('parseQuery sigils', () {
    test('each sigil selects its mode', () {
      expect(
        parseQuery('>dark'),
        const ParsedQuery(mode: PaletteMode.commands, text: 'dark'),
      );
      expect(
        parseQuery('#sword'),
        const ParsedQuery(mode: PaletteMode.entities, text: 'sword'),
      );
      expect(
        parseQuery('@demo'),
        const ParsedQuery(mode: PaletteMode.projects, text: 'demo'),
      );
      expect(
        parseQuery('/theme'),
        const ParsedQuery(mode: PaletteMode.settings, text: 'theme'),
      );
      expect(parseQuery('?'), const ParsedQuery(mode: PaletteMode.help));
    });

    test('a bare sigil selects its mode with empty text', () {
      expect(parseQuery('#'), const ParsedQuery(mode: PaletteMode.entities));
    });

    test('no prefix is the default mode', () {
      expect(parseQuery('dark'), const ParsedQuery(text: 'dark'));
      expect(parseQuery(''), const ParsedQuery());
    });
  });

  group('parseQuery entity kinds', () {
    test('#item sword sets kind and text', () {
      expect(
        parseQuery('#item sword'),
        const ParsedQuery(
          mode: PaletteMode.entities,
          kind: EntityKind.item,
          text: 'sword',
        ),
      );
    });

    test('#sword searches every kind', () {
      expect(parseQuery('#sword').kind, isNull);
    });

    test('a kind word without its space is still text', () {
      expect(
        parseQuery('#item'),
        const ParsedQuery(mode: PaletteMode.entities, text: 'item'),
      );
    });

    test('a held mode is not parsed again', () {
      // The chip already says "entities"; a typed '#' is text now.
      expect(
        parseQuery('#x', mode: PaletteMode.entities, kind: EntityKind.font),
        const ParsedQuery(
          mode: PaletteMode.entities,
          kind: EntityKind.font,
          text: '#x',
        ),
      );
    });

    test('a held entity mode still picks up a kind', () {
      expect(
        parseQuery('sound stone', mode: PaletteMode.entities),
        const ParsedQuery(
          mode: PaletteMode.entities,
          kind: EntityKind.sound,
          text: 'stone',
        ),
      );
    });
  });

  group('parseQuery aliases', () {
    test('each kind alias with a space selects entity mode and kind', () {
      for (final MapEntry(key: kind, value: aliases) in kindAliases.entries) {
        for (final alias in aliases) {
          expect(
            parseQuery('$alias x'),
            ParsedQuery(mode: PaletteMode.entities, kind: kind, text: 'x'),
            reason: alias,
          );
        }
      }
    });

    test('mode aliases with a space select their mode', () {
      expect(
        parseQuery('project demo'),
        const ParsedQuery(mode: PaletteMode.projects, text: 'demo'),
      );
      expect(
        parseQuery('projects '),
        const ParsedQuery(mode: PaletteMode.projects),
      );
      expect(
        parseQuery('settings theme'),
        const ParsedQuery(mode: PaletteMode.settings, text: 'theme'),
      );
    });

    test('aliases ignore case', () {
      expect(
        parseQuery('Item Sword'),
        const ParsedQuery(
          mode: PaletteMode.entities,
          kind: EntityKind.item,
          text: 'Sword',
        ),
      );
    });

    test('an alias without a space stays in the default mode', () {
      expect(parseQuery('items'), const ParsedQuery(text: 'items'));
      expect(parseQuery('project'), const ParsedQuery(text: 'project'));
    });

    test('a word that is no alias stays text', () {
      expect(
        parseQuery('open settings'),
        const ParsedQuery(text: 'open settings'),
      );
    });
  });

  test('an alias only prefixes titles of commands its own mode lists', () {
    final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));
    for (final command in pocCommands()) {
      final String title = command.title(l10n).toLowerCase();
      for (final alias in allAliases) {
        if (!title.startsWith('$alias ')) {
          continue;
        }
        // Typing the title selects the alias's mode; the command has to be
        // listed there, or the alias would hide it.
        final PaletteMode mode = parseQuery('$alias x').mode!;
        expect(
          command.modes,
          contains(mode),
          reason: '"$title" would be hidden by the alias "$alias"',
        );
      }
    }
  });

  test('go selects the navigation mode', () {
    expect(
      parseQuery('go to fonts'),
      const ParsedQuery(mode: PaletteMode.navigation, text: 'to fonts'),
    );
    expect(
      parseQuery(':items'),
      const ParsedQuery(mode: PaletteMode.navigation, text: 'items'),
    );
  });
}
