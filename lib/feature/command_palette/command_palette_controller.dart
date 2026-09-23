import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/command_palette/command.dart';
import 'package:stelaris/feature/command_palette/command_registry.dart';
import 'package:stelaris/feature/command_palette/command_search.dart';
import 'package:stelaris/feature/command_palette/entity_search_source.dart';
import 'package:stelaris/feature/command_palette/entity_search_state.dart';
import 'package:stelaris/feature/command_palette/palette_mode.dart';
import 'package:stelaris/feature/command_palette/palette_providers.dart';
import 'package:stelaris/l10n/app_localizations.dart';

/// Everything the command palette knows and does, without a widget of its
/// own: the mode and chip, the results, the highlight, the drill-down and the
/// keys. The field that types into it and the [CommandPanel] that lists its
/// results belong to whoever hosts it - the app bar search.
///
/// Listeners are told when the results, the mode or the drill-down change -
/// not when the highlight moves: that has its own [highlight] notifier, which
/// only the rows listen to.
class CommandPaletteController extends ChangeNotifier {
  CommandPaletteController({
    required CommandRegistry registry,
    required this.query,
    required this.onRun,
  }) : _search = PaletteSearch(registry);

  /// The host's text field.
  final TextEditingController query;

  /// Runs [command] for real: the host closes its dropdown first, then runs
  /// it with its own context.
  final void Function(StelarisCommand command) onRun;

  final PaletteSearch _search;

  /// Entries the host puts in front of the results for plain text, e.g.
  /// "Filter Items by …".
  List<StelarisCommand> Function(String text)? topEntries;

  /// Whether an entity search source is set up. Without one, entity mode
  /// only searches what is loaded and says so.
  bool hasEntitySearch = false;

  /// Told the entity question whenever it changes - a request, or null for
  /// none. The host turns it into Redux actions; the answer comes back
  /// through [applyEntitySearch].
  void Function(EntitySearchRequest? request)? onEntityQuery;

  /// The question last reported through [onEntityQuery].
  EntitySearchRequest? _asked;

  /// The store's side: the question it holds, its hits and its status.
  EntitySearchState _entitySearch = const EntitySearchState();

  CommandContext? _context;
  AppLocalizations? _l10n;

  PaletteMode? _mode;
  EntityKind? _kind;
  DrillFrame? _drill;

  PaletteResults _results = const PaletteResults([]);
  List<PaletteRow> _rows = const [];
  List<String> _rowIds = const [];
  final Map<String, GlobalKey> _rowKeys = {};

  /// Only the rows listen to this, so moving the highlight rebuilds the two
  /// rows whose state changed - not the field, the list or the footer.
  final ValueNotifier<int> highlight = ValueNotifier<int>(0);

  final ScrollController scroll = ScrollController();

  /// What the host's field shows around the text - the chip and the
  /// placeholder - changes only with the mode, the kind and the drill-down.
  /// The field listens to this, not to the controller, so a plain keystroke
  /// doesn't rebuild it.
  final ValueNotifier<(PaletteMode?, EntityKind?, DrillFrame?)> fieldState =
      ValueNotifier((null, null, null));

  PaletteMode? get mode => _mode;
  EntityKind? get kind => _kind;
  DrillFrame? get drill => _drill;
  PaletteResults get results => _results;
  List<StelarisCommand> get entries => _results.entries;
  List<PaletteRow> get rows => _rows;
  CommandContext? get commandContext => _context;

  /// Plain text: no mode, no kind, not stepped into anything. Only plain
  /// text filters the list below.
  bool get isPlain => _mode == null && _kind == null && _drill == null;

  @override
  void dispose() {
    fieldState.dispose();
    highlight.dispose();
    scroll.dispose();
    super.dispose();
  }

  /// What the palette may look at, and the language to rank titles in.
  /// Called when the dropdown opens and when the host's dependencies change.
  void configure(CommandContext context, AppLocalizations l10n) {
    _context = context;
    _l10n = l10n;
    _refresh();
  }

  /// The host's field changed: a typed prefix moves into the chip, and the
  /// results follow the rest.
  ParsedQuery onTextChanged(String value) {
    if (_drill == null) {
      final ParsedQuery parsed = parseQuery(value, mode: _mode, kind: _kind);
      if (parsed.mode != _mode || parsed.kind != _kind) {
        _mode = parsed.mode;
        _kind = parsed.kind;
        _setText(parsed.text);
      }
    }
    _refresh();
    return ParsedQuery(mode: _mode, kind: _kind, text: query.text);
  }

  /// Back to plain text, as after clearing the field.
  void reset() {
    _mode = null;
    _kind = null;
    _drill = null;
    _refresh();
  }

  /// Backspace on an empty field, or the chip's delete action: out of the
  /// drill-down first, then the kind, then the mode.
  void leaveMode() {
    if (_drill != null) {
      _stepOut();
      return;
    }
    if (_kind != null) {
      _kind = null;
    } else {
      _mode = null;
    }
    _refresh();
  }

  /// Re-resolves the results. With [keepHighlight] - when a source's hits
  /// arrive while the user looks at the list - a highlight the user moved
  /// stays on its entry instead of jumping back to the first.
  void _refresh({bool keepHighlight = false}) {
    final CommandContext? context = _context;
    final AppLocalizations? l10n = _l10n;
    if (context == null || l10n == null) {
      return;
    }
    // Only a highlight the user moved stays on its entry; one still on the
    // first row follows the best match, so a hit that just arrived and ranks
    // first is what Enter runs.
    final String? highlightedId =
        keepHighlight && highlight.value > 0 && highlight.value < entries.length
        ? entries[highlight.value].id
        : null;
    final DrillFrame? drill = _drill;
    if (drill != null) {
      _results = _drillResults(drill, l10n);
    } else {
      final EntitySearchRequest? asked = _askSource(context);
      // Hits and status count only while they answer the current question.
      final bool answered = asked != null && _entitySearch.request == asked;
      final PaletteResults found = _search.resolve(
        ParsedQuery(mode: _mode, kind: _kind, text: query.text),
        context,
        l10n,
        hits: answered ? _entitySearch.hits : const [],
        status: !hasEntitySearch
            ? EntitySearchStatus.none
            : asked == null
            ? EntitySearchStatus.done
            : answered
            ? _entitySearch.status
            : EntitySearchStatus.pending,
      );
      final String text = query.text.trim();
      final List<StelarisCommand> top = isPlain && text.isNotEmpty
          ? topEntries?.call(text) ?? const []
          : const [];
      _results = top.isEmpty
          ? found
          : PaletteResults([...top, ...found.entries], notice: found.notice);
    }
    _layout(l10n);
    fieldState.value = (_mode, _kind, _drill);
    final int kept = highlightedId == null
        ? -1
        : entries.indexWhere((entry) => entry.id == highlightedId);
    highlight.value = kept < 0 ? 0 : kept;
    notifyListeners();
  }

  /// The entity question for the current input - a request in entity mode
  /// with text and a source, null otherwise - reported once whenever it
  /// changes.
  EntitySearchRequest? _askSource(CommandContext context) {
    final String text = query.text.trim();
    final EntitySearchRequest? request =
        !hasEntitySearch ||
            _mode != PaletteMode.entities ||
            _drill != null ||
            text.isEmpty
        ? null
        : EntitySearchRequest(
            query: text,
            kind: _kind,
            projectId: context.state.selectedProject?.id,
            limit: maxEntityResults,
          );
    if (request != _asked) {
      _asked = request;
      onEntityQuery?.call(request);
    }
    return request;
  }

  /// The store's entity search changed. Re-resolves only when it answers the
  /// current question - and keeps a highlight the user moved.
  void applyEntitySearch(EntitySearchState state) {
    if (state == _entitySearch) return;
    _entitySearch = state;
    if (_asked != null && state.request == _asked) {
      _refresh(keepHighlight: true);
    }
  }

  PaletteResults _drillResults(DrillFrame drill, AppLocalizations l10n) {
    final List<StelarisCommand> children = drill.parent.children!()
        .where((child) => scoreMatch(query.text, child.title(l10n)) != null)
        .toList();
    return children.isEmpty
        ? PaletteResults(const [], notice: l10n.command_palette_no_results)
        : PaletteResults(children);
  }

  /// Headings while the query is empty, a flat ranked list otherwise.
  void _layout(AppLocalizations l10n) {
    final bool grouped = query.text.trim().isEmpty;
    final Map<String, int> seen = {};
    final List<String> ids = [];
    final List<PaletteRow> rows = [];
    String? previousSection;
    for (int i = 0; i < entries.length; i++) {
      final StelarisCommand command = entries[i];
      // An id listed twice would give two rows the same GlobalKey.
      final int count = seen.update(
        command.id,
        (n) => n + 1,
        ifAbsent: () => 0,
      );
      ids.add(count == 0 ? command.id : '${command.id}#$count');
      final String section = sectionOf(command, l10n);
      if (grouped && section != previousSection) {
        rows.add(HeadingRow(section));
        previousSection = section;
      }
      rows.add(EntryRow(i, grouped ? null : section));
    }
    _rowIds = ids;
    _rows = rows;
  }

  /// One key per entry id, kept across searches: a row that still matches
  /// after a keystroke keeps its element instead of being built from scratch.
  GlobalKey keyFor(int index) =>
      _rowKeys.putIfAbsent(_rowIds[index], GlobalKey.new);

  void _setText(String text) {
    query.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// Enter or a click on [command].
  void run(StelarisCommand command) {
    if (command.inert) {
      return;
    }
    final PaletteSwitch? target = command.switchTo;
    if (target == null) {
      onRun(command);
      return;
    }
    // Help and fallback entries change the palette, not the app.
    _drill = null;
    _mode = target.mode;
    _kind = target.kind;
    _setText(target.text);
    _refresh();
  }

  void _stepIn() {
    _drill = DrillFrame(
      parent: entries[highlight.value],
      mode: _mode,
      kind: _kind,
      text: query.text,
      highlight: highlight.value,
    );
    _setText('');
    _refresh();
  }

  void _stepOut() {
    final DrillFrame drill = _drill!;
    _drill = null;
    _mode = drill.mode;
    _kind = drill.kind;
    _setText(drill.text);
    _refresh();
    highlight.value = drill.highlight.clamp(0, entries.length - 1);
  }

  bool get _cursorAtEnd {
    final TextSelection selection = query.selection;
    return selection.isCollapsed && selection.baseOffset == query.text.length;
  }

  bool get _cursorAtStart {
    final TextSelection selection = query.selection;
    return selection.isCollapsed && selection.baseOffset <= 0;
  }

  void _moveHighlight(int by) {
    if (entries.isEmpty) {
      return;
    }
    final int previous = highlight.value;
    final int next = (previous + by) % entries.length;
    highlight.value = next;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scroll.hasClients) {
        return;
      }
      // A wrap-around lands on a row the list may not have built yet, far
      // outside the viewport, so ensureVisible would find nothing to scroll
      // to. The ends of the list are the ends of the scroll range instead -
      // the first row's group heading comes into view with it.
      if (next == 0) {
        scroll.jumpTo(0);
        return;
      }
      if (next == entries.length - 1) {
        // The lazily built list only estimates its extent until the last
        // rows exist; once the jump has built them, pull the row fully in.
        scroll.jumpTo(scroll.position.maxScrollExtent);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final BuildContext? row = next < _rowIds.length
              ? keyFor(next).currentContext
              : null;
          if (row != null) {
            Scrollable.ensureVisible(
              row,
              alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
            );
          }
        });
        return;
      }
      final BuildContext? row = keyFor(next).currentContext;
      if (row != null) {
        Scrollable.ensureVisible(
          row,
          alignmentPolicy: next > previous
              ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
              : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        );
      }
    });
  }

  /// The palette's keys, for the host's field to delegate to. Everything it
  /// does not handle stays the field's.
  KeyEventResult handleKey(KeyEvent event) {
    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveHighlight(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (entries.isNotEmpty) {
        run(entries[highlight.value]);
      }
      return KeyEventResult.handled;
    }
    // The arrows only step in and out at the edges of the text; anywhere
    // else they stay the field's, for moving the cursor.
    if (key == LogicalKeyboardKey.arrowRight &&
        _drill == null &&
        entries.isNotEmpty &&
        entries[highlight.value].children != null &&
        _cursorAtEnd) {
      _stepIn();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft &&
        _drill != null &&
        _cursorAtStart) {
      _stepOut();
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent &&
        key == LogicalKeyboardKey.backspace &&
        query.text.isEmpty &&
        !isPlain) {
      leaveMode();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// What the field searches right now, or null for the host's own default.
  String? hint(AppLocalizations l10n) {
    final DrillFrame? drill = _drill;
    if (drill != null) {
      return l10n.command_palette_hint_drill(drill.parent.title(l10n));
    }
    final EntityKind? kind = _kind;
    if (kind != null) {
      return l10n.command_palette_hint_kind(
        kindLabel(kind, l10n).toLowerCase(),
      );
    }
    return switch (_mode) {
      null => null,
      PaletteMode.commands => l10n.command_palette_hint_commands,
      PaletteMode.navigation => l10n.command_palette_hint_navigation,
      PaletteMode.entities => l10n.command_palette_hint_entities,
      PaletteMode.projects => l10n.command_palette_hint_projects,
      PaletteMode.settings => l10n.command_palette_hint_settings,
      PaletteMode.help => l10n.command_palette_hint_help,
    };
  }

  /// The chip's text, or null while the text is plain.
  String? chipLabel(AppLocalizations l10n) {
    final DrillFrame? drill = _drill;
    if (drill != null) {
      return drill.parent.title(l10n);
    }
    final EntityKind? kind = _kind;
    if (kind != null) {
      return kindLabel(kind, l10n);
    }
    final PaletteMode? mode = _mode;
    return mode == null ? null : specFor(mode).label(l10n);
  }

  static String sectionOf(StelarisCommand command, AppLocalizations l10n) {
    final String Function(AppLocalizations)? section = command.section;
    if (section != null) {
      return section(l10n);
    }
    return switch (command.group) {
      CommandGroup.navigation => l10n.command_palette_group_navigation,
      CommandGroup.create => l10n.command_palette_group_create,
      CommandGroup.interface => l10n.command_palette_group_interface,
      CommandGroup.backend => l10n.command_palette_group_backend,
      CommandGroup.entities => l10n.command_palette_group_entities,
      CommandGroup.projects => l10n.command_palette_group_projects,
      CommandGroup.help => l10n.command_palette_group_help,
    };
  }
}

/// One line of the palette's list.
sealed class PaletteRow {
  const PaletteRow();
}

class HeadingRow extends PaletteRow {
  const HeadingRow(this.label);

  final String label;
}

class EntryRow extends PaletteRow {
  const EntryRow(this.entry, this.section);

  /// Index into the controller's entries.
  final int entry;

  /// The section label shown at the end of the row in a flat list.
  final String? section;
}

/// Where the palette was when the user stepped into [parent]'s children -
/// everything needed to put it back.
@immutable
class DrillFrame {
  const DrillFrame({
    required this.parent,
    required this.mode,
    required this.kind,
    required this.text,
    required this.highlight,
  });

  final StelarisCommand parent;
  final PaletteMode? mode;
  final EntityKind? kind;
  final String text;
  final int highlight;
}
