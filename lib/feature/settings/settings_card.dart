import 'package:material_ui/material_ui.dart';

/// An outlined card of the settings dialog, in the shape and padding of an
/// edit card.
///
/// It has a leading [icon], a [title] and an optional [subtitle]. The control
/// is operated in place: a small one is the [trailing] widget, a wide one the
/// [child] below the header. Giving [onTap] makes the whole card a button, e.g.
/// for a link.
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: muted),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing],
            ],
          ),
          if (child != null) ...[const SizedBox(height: 12), child],
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
