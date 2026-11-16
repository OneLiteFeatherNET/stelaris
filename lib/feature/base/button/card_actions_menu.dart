import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// An entry of a [CardActionsMenu].
typedef CardMenuEntry = ({IconData icon, String label, VoidCallback onTap});

/// The 3-dot action menu on a card, with one item per entry of [entries].
class CardActionsMenu extends StatelessWidget {
  const CardActionsMenu({required this.entries, super.key});

  final List<CardMenuEntry> entries;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      icon: const Icon(Icons.more_vert),
      // PopupMenuButton doesn't read the ambient IconButtonTheme the way a
      // plain IconButton does (e.g. DeleteIconButton) — without this it
      // falls back to the Material default (24), visibly larger than the
      // 18 the surrounding IconButtonTheme sets for the rest of the header.
      iconSize: 18,
      padding: EdgeInsets.zero,
      tooltip: context.l10n.tooltip_more_actions,
      itemBuilder: (context) => [
        for (final entry in entries)
          PopupMenuItem<void>(
            // PopupMenuItem.onTap fires before its route is popped, so a
            // dialog it opens must wait a beat or the still-closing menu
            // route would dismiss it right away.
            onTap: () => Future.microtask(entry.onTap),
            child: _MenuItemContent(icon: entry.icon, label: entry.label),
          ),
      ],
    );
  }
}

class _MenuItemContent extends StatelessWidget {
  const _MenuItemContent({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        horizontalSpacing10,
        Flexible(child: Text(label)),
      ],
    );
  }
}
