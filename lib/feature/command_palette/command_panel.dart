import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/command_palette/command.dart';
import 'package:stelaris/feature/command_palette/command_palette_controller.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The command palette's results for [controller]: the notice, the list and
/// the key hints. The field that feeds it lives with the host.
class CommandPanel extends StatelessWidget {
  const CommandPanel({required this.controller, super.key});

  final CommandPaletteController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final AppLocalizations l10n = context.l10n;
        final List<StelarisCommand> entries = controller.entries;
        final String? notice = controller.results.notice;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (notice != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  entries.isEmpty ? 24 : 12,
                  16,
                  entries.isEmpty ? 24 : 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    notice,
                    style: entries.isEmpty
                        ? null
                        : Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            if (entries.isNotEmpty)
              Flexible(
                child: _PanelList(controller: controller, l10n: l10n),
              ),
            const Divider(height: 1),
            _KeyHints(
              stepIn:
                  controller.drill == null &&
                  entries.any((entry) => entry.children != null),
              stepOut: controller.drill != null,
            ),
          ],
        );
      },
    );
  }
}

/// Built lazily: only the rows on screen exist, however many entities are
/// loaded.
class _PanelList extends StatelessWidget {
  const _PanelList({required this.controller, required this.l10n});

  final CommandPaletteController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final List<PaletteRow> rows = controller.rows;
    // Its own clipping Material: a ListTile paints its selected colour as ink
    // on the nearest Material, which would otherwise be the whole dropdown -
    // and ink there is not cut off at the list's edge, so a highlighted last
    // row bled over the key hints.
    return Material(
      key: const Key('command-palette-list-surface'),
      type: MaterialType.transparency,
      clipBehavior: Clip.hardEdge,
      child: _list(rows),
    );
  }

  Widget _list(List<PaletteRow> rows) {
    return ListView.builder(
      controller: controller.scroll,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: rows.length,
      itemBuilder: (context, index) => switch (rows[index]) {
        HeadingRow(:final label) => _GroupHeading(label: label),
        EntryRow(:final entry, :final section) => _entryRow(
          context,
          entry,
          section,
        ),
      },
    );
  }

  Widget _entryRow(BuildContext context, int i, String? section) {
    final StelarisCommand command = controller.entries[i];
    final ThemeData theme = Theme.of(context);
    final String Function(AppLocalizations)? subtitle = command.subtitle;
    final CommandContext? commandContext = controller.commandContext;
    final bool current =
        commandContext != null &&
        (command.isCurrent?.call(commandContext) ?? false);
    // Everything but the selected state is built here, once per search; the
    // highlight listener below only swaps `selected`.
    final Widget leading = Icon(
      current ? command.currentIcon ?? command.icon : command.icon,
      color: current ? theme.colorScheme.primary : null,
    );
    final Widget title = Text(
      command.title(l10n),
      style: current ? TextStyle(color: theme.colorScheme.primary) : null,
    );
    final Widget? subtitleText = subtitle == null ? null : Text(subtitle(l10n));
    final Widget? trailing = _trailing(
      context,
      command,
      section,
      current: current,
    );
    // The mouse moves the one highlight rather than painting a second,
    // look-alike hover background: there is only ever one row that Enter
    // would run. onHover, not onEnter: only a mouse that actually moves takes
    // the highlight, not rows scrolling under a resting one while the
    // keyboard pages through the list.
    return MouseRegion(
      key: controller.keyFor(i),
      onHover: (_) {
        if (controller.highlight.value != i) {
          controller.highlight.value = i;
        }
      },
      child: _HighlightListener(
        index: i,
        highlight: controller.highlight,
        builder: (selected) => ListTile(
          dense: true,
          selected: selected,
          selectedTileColor: theme.colorScheme.secondaryContainer,
          leading: leading,
          title: title,
          subtitle: subtitleText,
          trailing: trailing,
          hoverColor: Colors.transparent,
          onTap: () => controller.run(command),
        ),
      ),
    );
  }

  /// The current-page mark, the section label when the list is flat, and a
  /// `›` on entries that Arrow Right can step into.
  Widget? _trailing(
    BuildContext context,
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
              l10n.command_palette_current_page,
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
}

/// Rebuilds [builder] only when [index] gains or loses the highlight, so
/// moving it by one row rebuilds two rows and nothing else.
class _HighlightListener extends StatefulWidget {
  const _HighlightListener({
    required this.index,
    required this.highlight,
    required this.builder,
  });

  final int index;
  final ValueListenable<int> highlight;
  final Widget Function(bool selected) builder;

  @override
  State<_HighlightListener> createState() => _HighlightListenerState();
}

class _HighlightListenerState extends State<_HighlightListener> {
  late bool _selected = widget.highlight.value == widget.index;

  @override
  void initState() {
    super.initState();
    widget.highlight.addListener(_changed);
  }

  @override
  void didUpdateWidget(_HighlightListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlight != widget.highlight) {
      oldWidget.highlight.removeListener(_changed);
      widget.highlight.addListener(_changed);
    }
    _selected = widget.highlight.value == widget.index;
  }

  @override
  void dispose() {
    widget.highlight.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    final bool selected = widget.highlight.value == widget.index;
    if (selected != _selected) {
      setState(() => _selected = selected);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(_selected);
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
          _KeyHint(keys: '↑↓', label: l10n.command_palette_footer_move),
          _KeyHint(keys: 'Enter', label: l10n.command_palette_footer_run),
          if (stepIn)
            _KeyHint(keys: '→', label: l10n.command_palette_footer_step_in),
          if (stepOut)
            _KeyHint(keys: '←', label: l10n.command_palette_footer_step_out),
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
