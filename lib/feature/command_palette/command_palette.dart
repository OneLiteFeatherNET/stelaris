import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/command.dart';
import 'package:stelaris/feature/command_palette/command_registry.dart';
import 'package:stelaris/feature/command_palette/command_search.dart';
import 'package:stelaris/feature/command_palette/commands.dart';
import 'package:stelaris/feature/command_palette/palette_mode.dart';
import 'package:stelaris/feature/command_palette/palette_providers.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Asks for the command palette to open.
class OpenCommandPaletteIntent extends Intent {
  const OpenCommandPaletteIntent();
}

/// `Ctrl+K` everywhere, and `Cmd+K` for macOS.
const List<SingleActivator> commandPaletteActivators = [
  SingleActivator(LogicalKeyboardKey.keyK, control: true),
  SingleActivator(LogicalKeyboardKey.keyK, meta: true),
];

final CommandRegistry _defaultRegistry = CommandRegistry(pocCommands());

/// Makes `Ctrl+K` / `Cmd+K` open the command palette anywhere below it.
///
/// Placed in the shell page, so the shortcut exists only once a project is
/// open. Dialogs are pushed onto the root navigator, outside this subtree, so
/// the shortcut is also inert while one is showing - including the palette.
class CommandPaletteShortcuts extends StatelessWidget {
  const CommandPaletteShortcuts({
    required this.child,
    this.registry,
    super.key,
  });

  final Widget child;

  /// The commands on offer; the POC set unless a test supplies its own.
  final CommandRegistry? registry;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        for (final activator in commandPaletteActivators)
          activator: const OpenCommandPaletteIntent(),
      },
      child: Actions(
        actions: {
          OpenCommandPaletteIntent: CallbackAction<OpenCommandPaletteIntent>(
            onInvoke: (_) {
              showCommandPalette(context, registry: registry);
              return null;
            },
          ),
        },
        // Key events only reach the Shortcuts above through a focused node
        // below them. Before anything on the page has been clicked, focus
        // sits on the route's scope, above this widget - this takes it.
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}

/// Opens the palette and runs whatever command is picked.
///
/// The palette closes before the command runs, and the command runs with
/// [context] - the page's - so a dialog or a navigation it starts lands on the
/// page instead of behind a closing palette.
Future<void> showCommandPalette(
  BuildContext context, {
  CommandRegistry? registry,
}) async {
  final commandContext = CommandContext(
    state: StoreProvider.backdoorInheritedWidget<AppState>(context).state,
    location: GoRouter.of(context).state.matchedLocation,
  );
  final StelarisCommand? command = await showDialog<StelarisCommand>(
    context: context,
    builder: (_) => CommandPalette(
      registry: registry ?? _defaultRegistry,
      commandContext: commandContext,
    ),
  );
  if (command != null && context.mounted) {
    await command.run(context);
  }
}

/// The palette itself: a search field over the commands [commandContext]
/// allows. Pops with the chosen command, or with nothing when dismissed.
///
/// A recognized prefix or alias leaves the text and becomes a chip in front
/// of it; Backspace in an empty field takes the chip away again.
class CommandPalette extends StatefulWidget {
  const CommandPalette({
    required this.registry,
    required this.commandContext,
    super.key,
  });

  final CommandRegistry registry;
  final CommandContext commandContext;

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  static const double _width = 600;
  static const double _maxHeight = 480;

  final TextEditingController _query = TextEditingController();
  late final FocusNode _field = FocusNode(onKeyEvent: _onKey);
  final ScrollController _scroll = ScrollController();
  late final PaletteSearch _palette = PaletteSearch(widget.registry);

  PaletteMode? _mode;
  EntityKind? _kind;

  /// Set while the user has stepped into an entry's children.
  _DrillFrame? _drill;

  PaletteResults _results = const PaletteResults([]);
  List<GlobalKey> _rowKeys = const [];
  int _highlight = 0;

  List<StelarisCommand> get _entries => _results.entries;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _search();
  }

  @override
  void dispose() {
    _query.dispose();
    _field.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _search() {
    final _DrillFrame? drill = _drill;
    _results = drill == null
        ? _palette.resolve(
            ParsedQuery(mode: _mode, kind: _kind, text: _query.text),
            widget.commandContext,
            context.l10n,
          )
        : _drillResults(drill);
    _rowKeys = List.generate(_entries.length, (_) => GlobalKey());
    _highlight = 0;
  }

  /// The children of the entry stepped into, filtered by the text.
  PaletteResults _drillResults(_DrillFrame drill) {
    final AppLocalizations l10n = context.l10n;
    final List<StelarisCommand> children = drill.parent.children!()
        .where((child) => scoreMatch(_query.text, child.title(l10n)) != null)
        .toList();
    return children.isEmpty
        ? PaletteResults(const [], notice: l10n.command_palette_no_results)
        : PaletteResults(children);
  }

  /// Arrow Right: list the highlighted entry's children in its place.
  void _stepIn() {
    final StelarisCommand parent = _entries[_highlight];
    setState(() {
      _drill = _DrillFrame(
        parent: parent,
        mode: _mode,
        kind: _kind,
        text: _query.text,
        highlight: _highlight,
      );
      _setText('');
      _search();
    });
  }

  /// Arrow Left or Backspace: back to the list the user stepped in from,
  /// as they left it.
  void _stepOut() {
    final _DrillFrame drill = _drill!;
    setState(() {
      _drill = null;
      _mode = drill.mode;
      _kind = drill.kind;
      _setText(drill.text);
      _search();
      _highlight = drill.highlight.clamp(0, _entries.length - 1);
    });
  }

  bool get _cursorAtEnd {
    final TextSelection selection = _query.selection;
    return selection.isCollapsed && selection.baseOffset == _query.text.length;
  }

  bool get _cursorAtStart {
    final TextSelection selection = _query.selection;
    return selection.isCollapsed && selection.baseOffset <= 0;
  }

  void _onQueryChanged(String value) {
    if (_drill != null) {
      // Inside an entry the text only filters its children.
      setState(_search);
      return;
    }
    final ParsedQuery parsed = parseQuery(value, mode: _mode, kind: _kind);
    setState(() {
      if (parsed.mode != _mode || parsed.kind != _kind) {
        // The prefix moves out of the text into the chip.
        _mode = parsed.mode;
        _kind = parsed.kind;
        _setText(parsed.text);
      }
      _search();
    });
  }

  void _setText(String text) {
    _query.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// Backspace on an empty field, or the chip's delete action: the kind goes
  /// first, then the mode.
  void _leaveMode() {
    if (_drill != null) {
      _stepOut();
      return;
    }
    setState(() {
      if (_kind != null) {
        _kind = null;
      } else {
        _mode = null;
      }
      _search();
    });
  }

  void _run(StelarisCommand command) {
    if (command.inert) {
      return;
    }
    final PaletteSwitch? target = command.switchTo;
    if (target == null) {
      Navigator.of(context).pop(command);
      return;
    }
    // Help and fallback entries change the palette, not the app.
    setState(() {
      _mode = target.mode;
      _kind = target.kind;
      _setText(target.text);
      _search();
    });
    _field.requestFocus();
  }

  void _moveHighlight(int by) {
    if (_entries.isEmpty) {
      return;
    }
    final int previous = _highlight;
    setState(() {
      _highlight = (_highlight + by) % _entries.length;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) {
        return;
      }
      // A wrap-around lands on a row the list may not have built yet, far
      // outside the viewport, so ensureVisible would find nothing to scroll
      // to. The ends of the list are the ends of the scroll range instead -
      // the first row's group heading comes into view with it.
      if (_highlight == 0) {
        _scroll.jumpTo(0);
        return;
      }
      if (_highlight == _entries.length - 1) {
        // The lazily built list only estimates its extent until the last
        // rows exist; once the jump has built them, pull the row fully in.
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final BuildContext? row = _rowKeys.length > _highlight
              ? _rowKeys[_highlight].currentContext
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
      final BuildContext? row = _rowKeys[_highlight].currentContext;
      if (row != null) {
        Scrollable.ensureVisible(
          row,
          alignmentPolicy: _highlight > previous
              ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
              : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        );
      }
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
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
      if (_entries.isNotEmpty) {
        _run(_entries[_highlight]);
      }
      return KeyEventResult.handled;
    }
    // The arrows only step in and out at the edges of the text; anywhere
    // else they stay the field's, for moving the cursor.
    if (key == LogicalKeyboardKey.arrowRight &&
        _drill == null &&
        _entries.isNotEmpty &&
        _entries[_highlight].children != null &&
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
        _query.text.isEmpty &&
        (_drill != null || _mode != null)) {
      _leaveMode();
      return KeyEventResult.handled;
    }
    // The shortcut that opened the palette closes it again.
    if (event is KeyDownEvent &&
        key == LogicalKeyboardKey.keyK &&
        (HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed)) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// What the field searches right now - and, in the default mode, that
  /// there is more than commands.
  String _hint(AppLocalizations l10n) {
    final _DrillFrame? drill = _drill;
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
      null => l10n.command_palette_hint_default,
      PaletteMode.commands => l10n.command_palette_hint_commands,
      PaletteMode.navigation => l10n.command_palette_hint_navigation,
      PaletteMode.entities => l10n.command_palette_hint_entities,
      PaletteMode.projects => l10n.command_palette_hint_projects,
      PaletteMode.settings => l10n.command_palette_hint_settings,
      PaletteMode.help => l10n.command_palette_hint_help,
    };
  }

  String? _chipLabel(AppLocalizations l10n) {
    final _DrillFrame? drill = _drill;
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String? chip = _chipLabel(l10n);
    final String? notice = _results.notice;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _width,
          maxHeight: _maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // One row, not a prefixIcon: InputDecoration centres its icon in
            // a 48px box on its own line while the text follows the field's
            // content padding, so the two never sat on the same centre. The
            // columns match the ListTiles below - icon at 16, text at 56.
            Padding(
              key: const Key('command-palette-search-row'),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  if (chip == null)
                    const Icon(
                      Icons.search,
                      key: Key('command-palette-search-icon'),
                    )
                  else
                    InputChip(
                      key: const Key('command-palette-mode-chip'),
                      label: Text(chip),
                      onDeleted: _leaveMode,
                      deleteButtonTooltipMessage:
                          l10n.command_palette_remove_mode,
                      // Clicking the chip must not take focus from the
                      // field the keyboard is typing into.
                      onPressed: () => _field.requestFocus(),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _query,
                      focusNode: _field,
                      autofocus: true,
                      onChanged: _onQueryChanged,
                      decoration: InputDecoration.collapsed(
                        hintText: _hint(l10n),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (notice != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  _entries.isEmpty ? 24 : 12,
                  16,
                  _entries.isEmpty ? 24 : 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    notice,
                    style: _entries.isEmpty
                        ? null
                        : Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            if (_entries.isNotEmpty) Flexible(child: _buildList(l10n)),
            const Divider(height: 1),
            _KeyHints(
              stepIn:
                  _drill == null &&
                  _entries.any((entry) => entry.children != null),
              stepOut: _drill != null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    final bool grouped = _query.text.trim().isEmpty;
    final List<Widget> children = [];
    String? previousSection;
    for (int i = 0; i < _entries.length; i++) {
      final StelarisCommand command = _entries[i];
      final String section = _sectionOf(command, l10n);
      if (grouped && section != previousSection) {
        children.add(_GroupHeading(label: section));
        previousSection = section;
      }
      final String Function(AppLocalizations)? subtitle = command.subtitle;
      final bool current =
          command.isCurrent?.call(widget.commandContext) ?? false;
      children.add(
        // The mouse moves the one highlight rather than painting a second,
        // look-alike hover background: there is only ever one row that
        // Enter would run. onHover, not onEnter: only a mouse that actually
        // moves takes the highlight, not rows scrolling under a resting one
        // while the keyboard pages through the list.
        MouseRegion(
          onHover: (_) {
            if (_highlight != i) {
              setState(() => _highlight = i);
            }
          },
          child: ListTile(
            key: _rowKeys[i],
            dense: true,
            selected: i == _highlight,
            selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
            leading: Icon(
              current ? command.currentIcon ?? command.icon : command.icon,
              color: current ? Theme.of(context).colorScheme.primary : null,
            ),
            title: Text(
              command.title(l10n),
              style: current
                  ? TextStyle(color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
            subtitle: subtitle == null ? null : Text(subtitle(l10n)),
            trailing: _trailing(
              command,
              grouped ? null : section,
              current: current,
            ),
            hoverColor: Colors.transparent,
            onTap: () => _run(command),
          ),
        ),
      );
    }
    return ListView(
      controller: _scroll,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: children,
    );
  }

  /// The current-page mark, the section label when the list is flat, and a
  /// `›` on entries that Arrow Right can step into.
  Widget? _trailing(
    StelarisCommand command,
    String? section, {
    required bool current,
  }) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = theme.textTheme.labelSmall;
    final bool steps = command.children != null;
    if (section == null && !steps && !current) {
      return null;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (current)
          Padding(
            key: const Key('command-palette-current-page'),
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              context.l10n.command_palette_current_page,
              style: style?.copyWith(color: theme.colorScheme.primary),
            ),
          ),
        if (section != null) Text(section, style: style),
        if (steps) ...[
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, key: Key('command-palette-steps-in')),
        ],
      ],
    );
  }

  static String _sectionOf(StelarisCommand command, AppLocalizations l10n) {
    final String Function(AppLocalizations)? section = command.section;
    if (section != null) {
      return section(l10n);
    }
    return switch (command.group) {
      CommandGroup.navigation => l10n.command_palette_group_navigation,
      CommandGroup.interface => l10n.command_palette_group_interface,
      CommandGroup.backend => l10n.command_palette_group_backend,
      CommandGroup.entities => l10n.command_palette_group_entities,
      CommandGroup.projects => l10n.command_palette_group_projects,
      CommandGroup.help => l10n.command_palette_group_help,
    };
  }
}

/// Where the palette was when the user stepped into [parent]'s children -
/// everything needed to put it back.
@immutable
class _DrillFrame {
  const _DrillFrame({
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

/// The keys that operate the palette, always in view under the list.
class _KeyHints extends StatelessWidget {
  const _KeyHints({required this.stepIn, required this.stepOut});

  /// Whether a listed entry can be stepped into with Arrow Right.
  final bool stepIn;

  /// Whether the palette is inside an entry, so Arrow Left leads back.
  final bool stepOut;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Padding(
      key: const Key('command-palette-key-hints'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: [
          _KeyHint(
            keys: '\u2191\u2193',
            label: l10n.command_palette_footer_move,
          ),
          _KeyHint(keys: 'Enter', label: l10n.command_palette_footer_run),
          if (stepIn)
            _KeyHint(
              keys: '\u2192',
              label: l10n.command_palette_footer_step_in,
            ),
          if (stepOut)
            _KeyHint(
              keys: '\u2190',
              label: l10n.command_palette_footer_step_out,
            ),
          _KeyHint(keys: 'Esc', label: l10n.command_palette_footer_close),
          _KeyHint(keys: '?', label: l10n.command_palette_footer_help),
        ],
      ),
    );
  }
}

class _KeyHint extends StatelessWidget {
  const _KeyHint({required this.keys, required this.label});

  final String keys;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            child: Text(keys, style: style),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: style),
      ],
    );
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
