import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/command_palette/command_registry.dart';
import 'package:stelaris/feature/command_palette/commands.dart';
import 'package:stelaris/feature/command_palette/entity_search_source.dart';

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

/// Where the palette lives below [CommandPaletteShortcuts]: which commands
/// it offers, and a signal the shortcut raises to open or close it. The app
/// bar search listens to the signal and is the palette.
class CommandPaletteHost extends InheritedWidget {
  const CommandPaletteHost({
    required this.registry,
    required this.requests,
    required super.child,
    this.entitySearch,
    super.key,
  });

  final CommandRegistry registry;

  /// Finds entities beyond the loaded ones, if a search service is set up.
  final EntitySearchSource? entitySearch;

  /// Fires on every `Ctrl+K` / `Cmd+K`.
  final Listenable requests;

  static CommandPaletteHost? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CommandPaletteHost>();

  @override
  bool updateShouldNotify(CommandPaletteHost oldWidget) =>
      registry != oldWidget.registry ||
      requests != oldWidget.requests ||
      entitySearch != oldWidget.entitySearch;
}

/// A [ChangeNotifier] that only ever notifies: one `Ctrl+K`.
class _Requests extends ChangeNotifier {
  void raise() => notifyListeners();
}

/// Makes `Ctrl+K` / `Cmd+K` open or close the command palette anywhere
/// below it - the app bar search field and its dropdown.
///
/// Placed in the shell page, so the shortcut exists only once a project is
/// open. Dialogs are pushed onto the root navigator, outside this subtree, so
/// the shortcut is inert while one is showing.
class CommandPaletteShortcuts extends StatefulWidget {
  const CommandPaletteShortcuts({
    required this.child,
    this.registry,
    this.entitySearch,
    super.key,
  });

  final Widget child;

  /// The commands on offer; the POC set unless a test supplies its own.
  final CommandRegistry? registry;

  /// A search service for entities that aren't loaded; none by default.
  final EntitySearchSource? entitySearch;

  @override
  State<CommandPaletteShortcuts> createState() =>
      _CommandPaletteShortcutsState();
}

class _CommandPaletteShortcutsState extends State<CommandPaletteShortcuts> {
  static final Map<ShortcutActivator, Intent> _shortcuts = {
    for (final activator in commandPaletteActivators)
      activator: const OpenCommandPaletteIntent(),
  };

  final _Requests _requests = _Requests();

  // Built once: a fresh map on every build of the page around it would make
  // Actions notify everything below that looks actions up.
  late final Map<Type, Action<Intent>> _actions = {
    OpenCommandPaletteIntent: CallbackAction<OpenCommandPaletteIntent>(
      onInvoke: (_) {
        _requests.raise();
        return null;
      },
    ),
  };

  @override
  void dispose() {
    _requests.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommandPaletteHost(
      registry: widget.registry ?? _defaultRegistry,
      requests: _requests,
      entitySearch: widget.entitySearch,
      child: Shortcuts(
        shortcuts: _shortcuts,
        child: Actions(
          actions: _actions,
          // Key events only reach the Shortcuts above through a focused node
          // below them. A scope, not a plain Focus: unfocusing anything on
          // the page - the search field after a command, a click into empty
          // space - hands focus to the nearest scope, which is then this one
          // instead of the route's above the shortcut. Autofocus covers the
          // first load, before anything has been clicked.
          child: FocusScope(autofocus: true, child: widget.child),
        ),
      ),
    );
  }
}
