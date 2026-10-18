import 'package:material_ui/material_ui.dart';

/// An outlined card of the settings dialog, in the shape and padding of an
/// edit card.
///
/// It has an [icon] in the line of the [title] and an optional [subtitle]
/// below the title. The control is operated in place: a small one is the
/// [trailing] widget, centered at the right end, a wide one the [child] below
/// the subtitle, on the line of the title. Giving [onTap] makes the whole
/// card a button, e.g. for a link.
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.child,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    final child = this.child;
    final onTap = this.onTap;

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // The icon belongs to the title line, so it stays beside the
                // title however tall the subtitle and the control below are.
                Row(
                  children: [
                    Icon(icon, size: _iconSize, color: muted),
                    const SizedBox(width: _iconGap),
                    Expanded(
                      child: Text(title, style: theme.textTheme.titleMedium),
                    ),
                  ],
                ),
                // The subtitle and the control start on the line of the
                // title.
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: _indent),
                    child: Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ),
                if (child != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: _indent),
                    child: child,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );

    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      // Only a card that is a button gets an ink well, so the controls in
      // the others don't sit inside an inactive one.
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

const double _iconSize = 18;
const double _iconGap = 8;

/// Where the text after the icon starts.
const double _indent = _iconSize + _iconGap;
