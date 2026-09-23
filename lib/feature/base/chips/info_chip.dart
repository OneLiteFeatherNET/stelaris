import 'package:material_ui/material_ui.dart';

/// A small, rounded chip that pairs an [icon] with a single line of
/// monospaced [text].
///
/// Used on model grid cards to surface a secondary piece of information
/// (e.g. a namespaced key, a provider, a material) beneath the primary
/// title without competing with it visually.
class InfoChip extends StatelessWidget {
  const InfoChip({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
