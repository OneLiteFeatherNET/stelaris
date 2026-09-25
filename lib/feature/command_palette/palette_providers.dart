import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/attributes/attribute_edit_dialog.dart';
import 'package:stelaris/feature/command_palette/command.dart';
import 'package:stelaris/feature/command_palette/command_registry.dart';
import 'package:stelaris/feature/command_palette/delete_specs.dart';
import 'package:stelaris/feature/command_palette/entity_search_source.dart';
import 'package:stelaris/feature/command_palette/command_search.dart';
import 'package:stelaris/feature/command_palette/palette_mode.dart';
import 'package:stelaris/feature/font/font_detail_page.dart';
import 'package:stelaris/feature/item/item_detail_page.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/project/dialog/switch_project_dialog.dart';
import 'package:stelaris/feature/sound/sound_detail_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Turns a parsed query into the entries one palette mode offers.
abstract interface class PaletteProvider {
  List<StelarisCommand> resolve(
    ParsedQuery query,
    CommandContext context,
    AppLocalizations l10n,
  );
}

/// What the palette shows for a query: the entries, and optionally a line of
/// text above them.
@immutable
class PaletteResults {
  const PaletteResults(this.entries, {this.notice});

  final List<StelarisCommand> entries;
  final String? notice;
}

/// Routes a [ParsedQuery] to the provider for its mode.
class PaletteSearch {
  PaletteSearch(this.registry, {List<HelpSection>? help})
    : _entities = EntityProvider(registry),
      _projects = ProjectProvider(registry),
      _help = HelpProvider(registry, help ?? defaultHelpSections);

  final CommandRegistry registry;
  final EntityProvider _entities;
  final ProjectProvider _projects;
  final HelpProvider _help;

  /// [hits] and [status] are the entity search source's side of entity
  /// mode: what it found for this query, and where its answer stands.
  PaletteResults resolve(
    ParsedQuery query,
    CommandContext context,
    AppLocalizations l10n, {
    List<EntityHit> hits = const [],
    EntitySearchStatus status = EntitySearchStatus.none,
  }) {
    final PaletteResults results = switch (query.mode) {
      null => _defaultMode(query, context, l10n),
      PaletteMode.commands => PaletteResults(
        registry.search(query.text, context, l10n),
      ),
      PaletteMode.navigation => PaletteResults(
        registry.search(
          query.text,
          context,
          l10n,
          mode: PaletteMode.navigation,
        ),
      ),
      PaletteMode.settings => PaletteResults(
        registry.search(query.text, context, l10n, mode: PaletteMode.settings),
      ),
      PaletteMode.entities => _entityResults(
        query,
        context,
        l10n,
        hits,
        status,
      ),
      PaletteMode.projects => PaletteResults(
        _projects.resolve(query, context, l10n),
      ),
      PaletteMode.help => PaletteResults(_help.resolve(query, context, l10n)),
    };
    if (results.entries.isEmpty && results.notice == null) {
      return PaletteResults(const [], notice: l10n.command_palette_no_results);
    }
    return results;
  }

  PaletteResults _entityResults(
    ParsedQuery query,
    CommandContext context,
    AppLocalizations l10n,
    List<EntityHit> hits,
    EntitySearchStatus status,
  ) {
    final EntityResults found = _entities.resolveEntities(
      query,
      context,
      hits: hits,
    );
    final String? coverage = switch (status) {
      EntitySearchStatus.none => l10n.command_palette_loaded_only,
      EntitySearchStatus.pending => l10n.command_palette_searching,
      EntitySearchStatus.failed => l10n.command_palette_search_failed,
      EntitySearchStatus.done => null,
    };
    final String? capped = found.capped
        ? l10n.command_palette_capped(found.shown, found.matched)
        : null;
    final String notice = [?coverage, ?capped].join(' \u00b7 ');
    return PaletteResults(
      found.entries,
      notice: notice.isEmpty ? null : notice,
    );
  }

  /// Commands, exactly as before the syntax existed - plus, when nothing
  /// matches, a way to look for the same text as an entity or a project.
  PaletteResults _defaultMode(
    ParsedQuery query,
    CommandContext context,
    AppLocalizations l10n,
  ) {
    final List<StelarisCommand> commands = registry.search(
      query.text,
      context,
      l10n,
    );
    final String text = query.text.trim();
    if (commands.isNotEmpty || text.isEmpty) {
      return PaletteResults(commands);
    }
    return PaletteResults(
      fallbacksFor(text),
      notice: l10n.command_palette_no_results,
    );
  }
}

/// The two default-mode fallbacks: the same text in entity and project mode.
List<StelarisCommand> fallbacksFor(String text) => [
  StelarisCommand(
    id: 'fallback.entities',
    title: (l10n) => l10n.command_palette_fallback_entities(text),
    group: CommandGroup.help,
    section: (l10n) => l10n.command_palette_mode_entities,
    icon: Icons.manage_search,
    run: StelarisCommand.noRun,
    switchTo: PaletteSwitch(PaletteMode.entities, text: text),
  ),
  StelarisCommand(
    id: 'fallback.projects',
    title: (l10n) => l10n.command_palette_fallback_projects(text),
    group: CommandGroup.help,
    section: (l10n) => l10n.command_palette_mode_projects,
    icon: Icons.folder_open,
    run: StelarisCommand.noRun,
    switchTo: PaletteSwitch(PaletteMode.projects, text: text),
  ),
];

/// Ranks [items] by [name] against [text]; an empty text keeps them all in
/// their order. Ties keep their order too, since Dart's sort is not stable.
List<T> _rank<T>(List<T> items, String text, String Function(T) name) {
  if (text.trim().isEmpty) {
    return items;
  }
  final List<(int, int, T)> scored = [];
  for (int i = 0; i < items.length; i++) {
    final int? score = scoreMatch(text, name(items[i]));
    if (score != null) {
      scored.add((score, i, items[i]));
    }
  }
  scored.sort((a, b) {
    final int byScore = b.$1.compareTo(a.$1);
    return byScore != 0 ? byScore : a.$2.compareTo(b.$2);
  });
  return scored.map((entry) => entry.$3).toList();
}

/// The list page each entity kind lives on.
NavigationEntry entryFor(EntityKind kind) {
  return switch (kind) {
    EntityKind.item => NavigationEntry.items,
    EntityKind.font => NavigationEntry.font,
    EntityKind.sound => NavigationEntry.sound,
    EntityKind.notification => NavigationEntry.notifications,
    EntityKind.attribute => NavigationEntry.attributes,
  };
}

/// Loaded items, fonts, sounds, notifications and attributes of the current
/// project, each one an entry that opens it the way clicking its card does.
/// Entity mode's answer: the entries, and how many entities matched before
/// the cap cut the list to [maxEntityResults].
@immutable
class EntityResults {
  const EntityResults(
    this.entries, {
    required this.matched,
    required this.shown,
  });

  final List<StelarisCommand> entries;
  final int matched;
  final int shown;

  bool get capped => matched > shown;
}

/// One entity before it becomes a command: cheap to rank, so commands are
/// only built for the ones that make the list.
class _Candidate {
  _Candidate(this.kind, this.model, this.name, this.score, this.order);

  final EntityKind kind;
  final DataModel model;
  final String name;

  /// Null for a search-service hit the palette's own matching doesn't see.
  final int? score;
  final int order;

  String get key => '${kind.name}:${model.id ?? name}';
}

/// Loaded items, fonts, sounds, notifications and attributes of the current
/// project - and whatever an [EntitySearchSource] found - each one an entry
/// that opens it the way clicking its card does. At most [maxEntityResults].
class EntityProvider implements PaletteProvider {
  EntityProvider(this.registry);

  final CommandRegistry registry;

  @override
  List<StelarisCommand> resolve(
    ParsedQuery query,
    CommandContext context,
    AppLocalizations l10n,
  ) => resolveEntities(query, context).entries;

  EntityResults resolveEntities(
    ParsedQuery query,
    CommandContext context, {
    List<EntityHit> hits = const [],
  }) {
    final List<EntityKind> kinds = query.kind == null
        ? EntityKind.values
        : [query.kind!];
    final String text = query.text;
    final bool filtering = text.trim().isNotEmpty;

    final List<_Candidate> candidates = [];
    final Set<String> seen = {};
    final List<EntityKind> empty = [];
    int order = 0;
    for (final EntityKind kind in kinds) {
      final List<(DataModel, String)> loaded = _loaded(kind, context.state);
      if (loaded.isEmpty) {
        empty.add(kind);
      }
      for (final (DataModel model, String name) in loaded) {
        final int? score = filtering ? scoreMatch(text, name) : 0;
        if (score == null) continue;
        final candidate = _Candidate(kind, model, name, score, order++);
        if (seen.add(candidate.key)) candidates.add(candidate);
      }
    }
    // A source's hits join the same ranking; ones the palette's matching
    // doesn't see follow the ones it does, in the source's own order.
    for (final EntityHit hit in hits) {
      if (!kinds.contains(hit.kind)) continue;
      final String? name = _nameOf(hit.kind, hit.model);
      if (name == null) continue;
      final candidate = _Candidate(
        hit.kind,
        hit.model,
        name,
        filtering ? scoreMatch(text, name) : 0,
        order++,
      );
      if (seen.add(candidate.key)) candidates.add(candidate);
    }

    if (filtering) {
      // Dart's sort is not stable, hence the order as the tie-breaker.
      candidates.sort((a, b) {
        final int byScore = (b.score ?? -1).compareTo(a.score ?? -1);
        return byScore != 0 ? byScore : a.order.compareTo(b.order);
      });
    }
    final List<_Candidate> shown = candidates.take(maxEntityResults).toList();
    final List<StelarisCommand> entries = [
      for (final _Candidate candidate in shown)
        ?_commandFor(candidate, context.state),
    ];

    // Nothing loaded for a kind: offer its list, which loads it.
    final List<StelarisCommand> available = registry.available(context);
    final List<StelarisCommand> goTo = [
      for (final EntityKind kind in empty)
        ...available.where(
          (command) =>
              command.id == 'nav.${entryFor(kind).name}' &&
              // Already on that list: it is loading, nothing to offer.
              !(command.isCurrent?.call(context) ?? false),
        ),
    ];
    return EntityResults(
      [...entries, ...goTo],
      matched: candidates.length,
      shown: entries.length,
    );
  }

  static List<(DataModel, String)> _loaded(EntityKind kind, AppState state) {
    return switch (kind) {
      EntityKind.item => [
        for (final ItemModel m in state.items.items) (m, m.uiName),
      ],
      EntityKind.font => [
        for (final FontModel m in state.fonts.items) (m, m.uiName),
      ],
      EntityKind.sound => [
        for (final SoundEventModel m in state.soundEvents.items) (m, m.uiName),
      ],
      EntityKind.notification => [
        for (final NotificationModel m in state.notifications.items)
          (m, m.uiName),
      ],
      EntityKind.attribute => [
        for (final AttributeModel m in state.attributes.items) (m, m.uiName),
      ],
    };
  }

  /// The name of [model] if its type fits [kind], else null - a hit whose
  /// model is of the wrong type is dropped.
  static String? _nameOf(EntityKind kind, DataModel model) {
    return switch ((kind, model)) {
      (EntityKind.item, final ItemModel m) => m.uiName,
      (EntityKind.font, final FontModel m) => m.uiName,
      (EntityKind.sound, final SoundEventModel m) => m.uiName,
      (EntityKind.notification, final NotificationModel m) => m.uiName,
      (EntityKind.attribute, final AttributeModel m) => m.uiName,
      _ => null,
    };
  }

  StelarisCommand? _commandFor(_Candidate candidate, AppState state) {
    final EntityKind kind = candidate.kind;
    List<StelarisCommand> actionsFor<E extends DataModel>(
      E model,
      DeleteSpec<E> spec,
    ) => [_deleteChild(kind, model, candidate.name, spec)];

    return switch (candidate.model) {
      final ItemModel model when kind == EntityKind.item => _withTabs(
        kind,
        model.id,
        model.uiName,
        ItemDetailPage.tabs,
        (context) => context.dispatch(SelectedItemAction(model)),
        actionsFor(model, itemDelete),
      ),
      final FontModel model when kind == EntityKind.font => _withTabs(
        kind,
        model.id,
        model.uiName,
        FontDetailPage.tabs,
        (context) => context.dispatch(SelectFontAction(model)),
        actionsFor(model, fontDelete),
      ),
      final SoundEventModel model when kind == EntityKind.sound => _withTabs(
        kind,
        model.id,
        model.uiName,
        SoundDetailPage.tabs,
        (context) => context.dispatch(SelectSoundAction(model)),
        actionsFor(model, soundDelete),
      ),
      final NotificationModel model when kind == EntityKind.notification =>
        _entity(kind, model.id, model.uiName, (context) async {
          context.dispatch(SelectedNotificationAction(model));
          context.go(detailLocation(NavigationEntry.notifications.route));
        }, children: _childrenOf(actionsFor(model, notificationDelete))),
      // Attributes have no detail page; their card opens this dialog.
      final AttributeModel model when kind == EntityKind.attribute => _entity(
        kind,
        model.id,
        model.uiName,
        (context) => showDialog<void>(
          context: context,
          builder: (_) => AttributeEditDialog(
            model: model,
            // As the attribute page passes it; inside a project the
            // selection is always set.
            projectKey: state.selectedProject?.key ?? '',
          ),
        ),
        children: _childrenOf(actionsFor(model, attributeDelete)),
      ),
      _ => null,
    };
  }

  /// Children for an entity without tabs: its actions, or none at all, so
  /// an entity with nothing to step into doesn't show the `›`.
  static List<StelarisCommand> Function()? _childrenOf(
    List<StelarisCommand> actions,
  ) => actions.isEmpty ? null : () => actions;

  /// "Delete…": the shared delete flow, with its typed-name confirmation.
  /// Always the last child, never the first, so stepping in and pressing
  /// Enter opens a tab rather than a deletion.
  StelarisCommand _deleteChild<E extends DataModel>(
    EntityKind kind,
    E model,
    String name,
    DeleteSpec<E> spec,
  ) {
    return StelarisCommand(
      id: 'entity.${kind.name}.${model.id ?? name}.delete',
      title: (l10n) => l10n.command_delete_entry,
      keywords: (l10n) => l10n.command_delete_keywords.split(' '),
      section: (_) => name,
      group: CommandGroup.entities,
      icon: Icons.delete_outline,
      modes: const {PaletteMode.entities},
      run: (context) async {
        await spec.delete(context, model);
      },
    );
  }

  /// An entity whose detail page has [tabs]: choosing it opens the first
  /// tab, as clicking its card does; Arrow Right lists the tabs to open it
  /// on, followed by [actions].
  StelarisCommand _withTabs(
    EntityKind kind,
    String? id,
    String name,
    List<String> tabs,
    void Function(BuildContext context) select,
    List<StelarisCommand> actions,
  ) {
    final String route = entryFor(kind).route;
    return _entity(
      kind,
      id,
      name,
      (context) async {
        select(context);
        context.go(detailLocation(route));
      },
      children: () => [
        for (final String tab in tabs)
          StelarisCommand(
            id: 'entity.${kind.name}.${id ?? name}.tab.${tab.toLowerCase()}',
            title: (_) => tab,
            section: (_) => name,
            group: CommandGroup.entities,
            icon: Icons.tab_outlined,
            modes: const {PaletteMode.entities},
            run: (context) async {
              select(context);
              context.go(detailLocation(route, tab));
            },
          ),
        ...actions,
      ],
    );
  }

  StelarisCommand _entity(
    EntityKind kind,
    String? id,
    String name,
    Future<void> Function(BuildContext context) run, {
    List<StelarisCommand> Function()? children,
  }) {
    return StelarisCommand(
      id: 'entity.${kind.name}.${id ?? name}',
      title: (_) => name,
      group: CommandGroup.entities,
      section: (l10n) => kindLabel(kind, l10n),
      icon: entryFor(kind).data,
      modes: const {PaletteMode.entities},
      run: run,
      children: children,
    );
  }
}

/// The known projects other than the current one; choosing one asks first,
/// with the same dialog as the settings project switcher.
class ProjectProvider implements PaletteProvider {
  ProjectProvider(this.registry);

  final CommandRegistry registry;

  @override
  List<StelarisCommand> resolve(
    ParsedQuery query,
    CommandContext context,
    AppLocalizations l10n,
  ) {
    final Project? current = context.state.selectedProject;
    final List<Project> others = context.state.projects
        .where((project) => project.id != current?.id)
        .toList();
    if (others.isEmpty) {
      return registry
          .available(context)
          .where((command) => command.id == 'nav.projects')
          .toList();
    }
    return [
      for (final Project project in _rank(
        others,
        query.text,
        (project) => project.displayName,
      ))
        StelarisCommand(
          id: 'project.${project.id}',
          title: (_) => project.displayName,
          subtitle: (_) => project.key,
          group: CommandGroup.projects,
          icon: Icons.folder_outlined,
          modes: const {PaletteMode.projects},
          run: (context) => _switchTo(context, current, project),
        ),
    ];
  }

  static Future<void> _switchTo(
    BuildContext context,
    Project? current,
    Project target,
  ) async {
    if (current != null) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (_) =>
            SwitchProjectDialog(currentProject: current, targetProject: target),
      );
      if (confirmed != true || !context.mounted) {
        return;
      }
    }
    context.dispatch(SelectProjectAction(target));
  }
}

/// One block of the `?` help, under its own heading.
///
/// Help is a list of these rather than one provider that knows everything,
/// so a feature brings its own help by adding a section to the list handed
/// to [PaletteSearch] - without touching [HelpProvider] or the other sections.
@immutable
class HelpSection {
  const HelpSection({
    required this.id,
    required this.title,
    required this.entries,
  });

  final String id;
  final String Function(AppLocalizations l10n) title;
  final List<StelarisCommand> Function(
    CommandContext context,
    CommandRegistry registry,
  )
  entries;
}

/// The help the palette ships with: its syntax, where it can take you, and
/// the keys that operate it.
final List<HelpSection> defaultHelpSections = [
  syntaxHelp,
  navigationHelp,
  keyboardHelp,
];

/// Every mode with its prefix and aliases, from the same table the parser
/// reads. Choosing one switches the palette into that mode.
final HelpSection syntaxHelp = HelpSection(
  id: 'syntax',
  title: (l10n) => l10n.command_palette_group_help,
  entries: (_, _) => [
    for (final ModeSpec spec in modeSpecs)
      if (spec.mode != PaletteMode.help)
        StelarisCommand(
          id: 'help.${spec.mode.name}',
          title: (l10n) => '${spec.sigil}  ${spec.label(l10n)}',
          subtitle: (l10n) {
            final List<String> aliases = _aliasesOf(spec);
            return aliases.isEmpty
                ? spec.describe(l10n)
                : '${spec.describe(l10n)} · '
                      '${l10n.command_palette_aliases(aliases.join(', '))}';
          },
          group: CommandGroup.help,
          icon: Icons.keyboard_command_key,
          modes: const {PaletteMode.help},
          run: StelarisCommand.noRun,
          switchTo: PaletteSwitch(spec.mode),
        ),
  ],
);

List<String> _aliasesOf(ModeSpec spec) {
  if (spec.mode == PaletteMode.entities) {
    return [for (final aliases in kindAliases.values) aliases.first];
  }
  return spec.aliases;
}

/// The pages reachable from here - the "Go to" commands themselves, so
/// choosing one navigates exactly as they do.
final HelpSection navigationHelp = HelpSection(
  id: 'navigation',
  title: (l10n) => l10n.command_palette_mode_navigation,
  entries: (context, registry) => registry
      .available(context)
      .where((command) => command.modes.contains(PaletteMode.navigation))
      .toList(),
);

/// How to operate the palette. Only to be read: choosing an entry does
/// nothing.
final HelpSection keyboardHelp = HelpSection(
  id: 'keyboard',
  title: (l10n) => l10n.command_palette_help_keyboard,
  entries: (_, _) => [
    _key('up-down', '↑ / ↓', (l10n) => l10n.command_palette_key_move),
    _key('enter', 'Enter', (l10n) => l10n.command_palette_key_run),
    _key('right', '\u2192', (l10n) => l10n.command_palette_key_step_in),
    _key('left', '\u2190', (l10n) => l10n.command_palette_key_step_out),
    _key('esc', 'Esc', (l10n) => l10n.command_palette_key_close),
    _key('backspace', 'Backspace', (l10n) => l10n.command_palette_key_leave),
    _key('ctrl-k', 'Ctrl+K / ⌘K', (l10n) => l10n.command_palette_key_toggle),
  ],
);

StelarisCommand _key(
  String id,
  String keys,
  String Function(AppLocalizations l10n) does,
) {
  return StelarisCommand(
    id: 'help.key.$id',
    title: (_) => keys,
    subtitle: does,
    keywords: (l10n) => [does(l10n)],
    group: CommandGroup.help,
    icon: Icons.keyboard_outlined,
    modes: const {PaletteMode.help},
    run: StelarisCommand.noRun,
    inert: true,
  );
}

/// The `?` mode: every section's entries under the section's heading,
/// filtered by what was typed.
class HelpProvider implements PaletteProvider {
  HelpProvider(this.registry, this.sections);

  final CommandRegistry registry;
  final List<HelpSection> sections;

  @override
  List<StelarisCommand> resolve(
    ParsedQuery query,
    CommandContext context,
    AppLocalizations l10n,
  ) {
    final List<StelarisCommand> entries = [
      for (final HelpSection section in sections)
        for (final StelarisCommand entry in section.entries(context, registry))
          _under(entry, section),
    ];
    // Filtered, not ranked: help keeps its sections in order.
    if (query.text.trim().isEmpty) {
      return entries;
    }
    return entries.where((entry) {
      return scoreMatch(query.text, entry.title(l10n)) != null ||
          entry
              .keywords(l10n)
              .any((keyword) => scoreMatch(query.text, keyword) != null);
    }).toList();
  }

  /// [entry], filed under [section]'s heading.
  static StelarisCommand _under(StelarisCommand entry, HelpSection section) {
    return StelarisCommand(
      id: entry.id,
      title: entry.title,
      keywords: entry.keywords,
      group: entry.group,
      icon: entry.icon,
      run: entry.run,
      isAvailable: entry.isAvailable,
      modes: entry.modes,
      subtitle: entry.subtitle,
      section: section.title,
      switchTo: entry.switchTo,
      inert: entry.inert,
      children: entry.children,
      isCurrent: entry.isCurrent,
      currentIcon: entry.currentIcon,
    );
  }
}
