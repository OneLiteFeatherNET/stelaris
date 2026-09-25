import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/command.dart';
import 'package:stelaris/feature/command_palette/command_registry.dart';
import 'package:stelaris/feature/command_palette/commands.dart';
import 'package:stelaris/feature/command_palette/palette_mode.dart';
import 'package:stelaris/feature/command_palette/palette_providers.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

PaginatedResult<T> page<T>(List<T> items) => PaginatedResult<T>(
  items: items,
  totalItems: items.length,
  totalPages: 1,
  currentPage: 1,
  pageSize: 10,
);

const Project eldoria = Project(
  id: 'p1',
  key: 'eldoria_rpg',
  displayName: 'Eldoria RPG',
);
const Project skyblock = Project(
  id: 'p2',
  key: 'skyblock_lab',
  displayName: 'Skyblock Lab',
);
const Project demo = Project(id: 'p3', key: 'demo', displayName: 'Demo');

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));
  final search = PaletteSearch(CommandRegistry(pocCommands()));

  final AppState loaded = const AppState().copyWith(
    selectedProject: eldoria,
    projects: const [eldoria, skyblock, demo],
    items: page(const [
      ItemModel(uiName: 'Diamond Sword', id: 'i1'),
      ItemModel(uiName: 'Stone Pickaxe', id: 'i2'),
    ]),
    soundEvents: page([SoundEventModel(uiName: 'Stone Break', id: 's1')]),
    attributes: page(const [AttributeModel(uiName: 'Max Mana', id: 'a1')]),
  );

  PaletteResults resolve(
    String raw, {
    AppState? state,
    String location = '/attributes',
  }) {
    return search.resolve(
      parseQuery(raw),
      CommandContext(state: state ?? loaded, location: location),
      l10n,
    );
  }

  List<String> ids(PaletteResults results) =>
      results.entries.map((entry) => entry.id).toList();

  List<String> titles(PaletteResults results) =>
      results.entries.map((entry) => entry.title(l10n)).toList();

  group('settings mode', () {
    test('lists exactly the three settings commands', () {
      expect(ids(resolve('/')), [
        'ui.toggle-dark-mode',
        'ui.toggle-system-theme',
        'ui.open-settings',
      ]);
    });

    test('the same commands are still in the commands mode', () {
      expect(
        ids(resolve('>')),
        containsAll(['ui.toggle-dark-mode', 'ui.open-settings']),
      );
    });
  });

  group('command mode', () {
    test('lists only commands', () {
      final results = resolve('>dark');
      expect(titles(results), contains('Toggle dark mode'));
      expect(ids(results).every((id) => !id.startsWith('entity.')), isTrue);
    });

    test('the default mode lists the same commands as before', () {
      expect(ids(resolve('dark')), ids(resolve('>dark')));
    });
  });

  group('entity mode', () {
    test('#sword finds the item across kinds', () {
      expect(titles(resolve('#sword')).first, 'Diamond Sword');
    });

    test('#stone matches both an item and a sound', () {
      expect(
        titles(resolve('#stone')),
        containsAll(['Stone Pickaxe', 'Stone Break']),
      );
    });

    test('#sound stone restricts to sounds', () {
      final results = resolve('#sound stone');
      expect(titles(results), contains('Stone Break'));
      expect(titles(results), isNot(contains('Stone Pickaxe')));
    });

    test('a bare # lists every loaded entity with its kind', () {
      final results = resolve('#');
      expect(
        titles(results),
        containsAll([
          'Diamond Sword',
          'Stone Pickaxe',
          'Stone Break',
          'Max Mana',
        ]),
      );
      final sword = results.entries.firstWhere(
        (entry) => entry.title(l10n) == 'Diamond Sword',
      );
      expect(sword.section!(l10n), 'Items');
    });

    test('always says that only loaded entries are searched', () {
      expect(resolve('#').notice, l10n.command_palette_loaded_only);
    });

    test('an empty kind offers its "Go to" command instead', () {
      final results = resolve('#font ');
      expect(ids(results), ['nav.font']);
      expect(results.notice, l10n.command_palette_loaded_only);
    });

    test('"Go to" is not offered for the page the user is on', () {
      expect(ids(resolve('#font ', location: '/fonts')), isEmpty);
    });
  });

  group('project mode', () {
    test('lists the other projects, not the current one', () {
      final results = resolve('@');
      expect(titles(results), containsAll(['Skyblock Lab', 'Demo']));
      expect(titles(results), isNot(contains('Eldoria RPG')));
    });

    test('matches by display name', () {
      expect(titles(resolve('@demo')), ['Demo']);
    });

    test('offers the project list when no other project is known', () {
      final lonely = loaded.copyWith(projects: const [eldoria]);
      expect(ids(resolve('@', state: lonely)), ['nav.projects']);
    });
  });

  group('navigation mode', () {
    test('lists every page and the project list, nothing else', () {
      expect(ids(resolve(':', location: '/fonts')), [
        'nav.attributes',
        'nav.items',
        'nav.notifications',
        'nav.font',
        'nav.sound',
        'nav.projects',
      ]);
    });

    test('go to fonts lists Go to Fonts first', () {
      expect(titles(resolve('go to fonts')).first, 'Go to Fonts');
    });
  });

  group('help mode', () {
    List<String?> sections(PaletteResults results) =>
        results.entries.map((entry) => entry.section?.call(l10n)).toList();

    test('lists the syntax, navigation and keyboard sections in order', () {
      final results = resolve('?', location: '/fonts');
      expect(sections(results).toSet().toList(), [
        'Syntax',
        'Navigation',
        'Keyboard',
      ]);
    });

    test('the syntax section has the five modes with sigils and aliases', () {
      final results = resolve('?');
      final syntax = results.entries
          .where((entry) => entry.section!(l10n) == 'Syntax')
          .toList();
      expect(syntax.map((entry) => entry.title(l10n)), [
        '>  Commands',
        ':  Navigation',
        '#  Entities',
        '@  Projects',
        '/  Settings',
      ]);
      expect(syntax[1].subtitle!(l10n), contains('go'));
      expect(syntax[2].subtitle!(l10n), contains('item'));
      expect(syntax.map((entry) => entry.switchTo?.mode), [
        PaletteMode.commands,
        PaletteMode.navigation,
        PaletteMode.entities,
        PaletteMode.projects,
        PaletteMode.settings,
      ]);
    });

    test('the navigation section holds the Go to commands themselves', () {
      final results = resolve('?', location: '/fonts');
      final navigation = results.entries
          .where((entry) => entry.section!(l10n) == 'Navigation')
          .map((entry) => entry.id)
          .toList();
      expect(navigation, [
        'nav.attributes',
        'nav.items',
        'nav.notifications',
        'nav.font',
        'nav.sound',
        'nav.projects',
      ]);
      final font = results.entries.firstWhere((e) => e.id == 'nav.font');
      expect(
        font.isCurrent!(CommandContext(state: loaded, location: '/fonts')),
        isTrue,
      );
      final items = results.entries.firstWhere((e) => e.id == 'nav.items');
      expect(items.switchTo, isNull);
      expect(items.inert, isFalse);
    });

    test('keyboard entries are inert', () {
      final keyboard = resolve('?').entries
          .where((entry) => entry.section!(l10n) == 'Keyboard')
          .toList();
      expect(keyboard.map((entry) => entry.title(l10n)), [
        '\u2191 / \u2193',
        'Enter',
        '\u2192',
        '\u2190',
        'Esc',
        'Backspace',
        'Ctrl+K / \u2318K',
      ]);
      expect(keyboard.every((entry) => entry.inert), isTrue);
    });

    test('typed text filters across sections', () {
      final results = resolve('?leave');
      expect(titles(results), ['Backspace']);
    });

    test('a custom section appears without changing anything else', () {
      final custom = HelpSection(
        id: 'custom',
        title: (_) => 'Custom',
        entries: (_, _) => [
          StelarisCommand(
            id: 'custom.entry',
            title: (_) => 'Custom entry',
            group: CommandGroup.help,
            icon: const IconData(0),
            run: StelarisCommand.noRun,
            inert: true,
          ),
        ],
      );
      final withCustom = PaletteSearch(
        CommandRegistry(pocCommands()),
        help: [...defaultHelpSections, custom],
      );
      final results = withCustom.resolve(
        parseQuery('?'),
        CommandContext(state: loaded, location: '/fonts'),
        l10n,
      );
      expect(results.entries.last.id, 'custom.entry');
      expect(results.entries.last.section!(l10n), 'Custom');
      expect(
        results.entries.map((entry) => entry.id),
        containsAll(['help.commands', 'nav.items', 'help.key.esc']),
      );
    });
  });

  group('default-mode fallback', () {
    test('an unmatched query offers entity and project search', () {
      final results = resolve('zzqx');
      expect(results.notice, l10n.command_palette_no_results);
      expect(ids(results), ['fallback.entities', 'fallback.projects']);
      expect(results.entries[0].switchTo!.mode, PaletteMode.entities);
      expect(results.entries[0].switchTo!.text, 'zzqx');
      expect(results.entries[1].switchTo!.mode, PaletteMode.projects);
      expect(results.entries[1].switchTo!.text, 'zzqx');
    });

    test('no fallback while a command matches', () {
      expect(ids(resolve('dark')), isNot(contains('fallback.entities')));
    });

    test('no fallback for an empty query', () {
      expect(resolve('').notice, isNull);
    });
  });

  group('entity children', () {
    final AppState everyKind = loaded.copyWith(
      fonts: page(const [FontModel(uiName: 'Rune Script', id: 'f1')]),
      notifications: page(const [
        NotificationModel(uiName: 'Quest Done', id: 'n1'),
      ]),
    );

    List<String>? childrenOf(String title, AppState state) {
      final entry = search
          .resolve(
            parseQuery('#'),
            CommandContext(state: state, location: '/attributes'),
            l10n,
          )
          .entries
          .firstWhere((entry) => entry.title(l10n) == title);
      return entry.children?.call().map((c) => c.title(l10n)).toList();
    }

    test('tabs come first, then Delete, for items, fonts and sounds', () {
      expect(childrenOf('Diamond Sword', everyKind), [
        'General',
        'Meta',
        'Enchantments',
        'Lore',
        'Delete\u2026',
      ]);
      expect(childrenOf('Rune Script', everyKind), [
        'General',
        'FontFace',
        'Chars',
        'Delete\u2026',
      ]);
      expect(childrenOf('Stone Break', everyKind), [
        'General',
        'Entries',
        'Delete\u2026',
      ]);
    });

    test('attributes and notifications step into Delete alone', () {
      expect(childrenOf('Max Mana', everyKind), ['Delete\u2026']);
      expect(childrenOf('Quest Done', everyKind), ['Delete\u2026']);
    });
  });

  group('create and delete commands', () {
    List<String> availableIds(String location, {AppState? state}) =>
        CommandRegistry(pocCommands())
            .available(
              CommandContext(state: state ?? loaded, location: location),
            )
            .map((command) => command.id)
            .toList();

    test('create commands are offered from anywhere', () {
      const creates = [
        'create.items',
        'create.font',
        'create.sound',
        'create.notifications',
        'create.attributes',
      ];
      expect(availableIds('/fonts'), containsAll(creates));
    });

    test('Delete this item needs its detail page and a selection', () {
      final selected = loaded.copyWith(
        selectedItem: const ItemModel(uiName: 'Diamond Sword', id: 'i1'),
      );
      expect(
        availableIds('/items/detail', state: selected),
        contains('delete.items.current'),
      );
      expect(
        availableIds('/items', state: selected),
        isNot(contains('delete.items.current')),
      );
      expect(
        availableIds('/items/detail'),
        isNot(contains('delete.items.current')),
      );
    });

    test('the create section follows navigation', () {
      final groups = CommandRegistry(pocCommands()).all
          .map((command) => command.group)
          .toSet()
          .toList();
      expect(groups.indexOf(CommandGroup.create), 1);
    });
  });

  group('entity cap', () {
    AppState withItems(int count) => loaded.copyWith(
      items: page([
        for (int i = 0; i < count; i++)
          ItemModel(uiName: 'Sword $i', id: 'item-$i'),
      ]),
    );

    List<StelarisCommand> entitiesOf(PaletteResults results) => results.entries
        .where((entry) => entry.id.startsWith('entity.'))
        .toList();

    test('200 matching items list 15 and say so', () {
      final results = resolve('#item sword', state: withItems(200));
      expect(entitiesOf(results), hasLength(15));
      expect(results.notice, contains('15 of 200 shown'));
    });

    test('few matches list all without a count', () {
      final results = resolve('#item sword', state: withItems(3));
      expect(entitiesOf(results), hasLength(3));
      expect(results.notice, isNot(contains('shown')));
    });

    test('an empty query lists at most 15 too', () {
      expect(entitiesOf(resolve('#', state: withItems(40))), hasLength(15));
    });

    test('Go-to entries for unloaded kinds do not count', () {
      final results = resolve('#', state: withItems(40));
      expect(entitiesOf(results), hasLength(15));
      expect(
        results.entries.where((entry) => entry.id.startsWith('nav.')),
        isNotEmpty,
      );
    });

    test('the best match makes the cut among many weaker ones', () {
      final state = loaded.copyWith(
        items: page([
          // 30 scattered matches for "bla", loaded before the strong one.
          for (int i = 0; i < 30; i++)
            ItemModel(uiName: 'Big long armor $i', id: 'item-$i'),
        ]),
        attributes: page(const [
          AttributeModel(uiName: 'Blade', id: 'a-blade'),
        ]),
      );
      final results = resolve('#bla', state: state);
      expect(entitiesOf(results), hasLength(15));
      expect(entitiesOf(results).first.title(l10n), 'Blade');
    });
  });
}
