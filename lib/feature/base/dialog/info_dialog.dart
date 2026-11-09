import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A read-only dialog that explains a page or a feature: a title with a close
/// icon, an intro, one [InfoTopic] per point and an optional [footer], e.g. a
/// notice. The content scrolls, a close button ends it.
class InfoDialog extends StatelessWidget {
  const InfoDialog({
    required this.title,
    required this.intro,
    required this.topics,
    this.footer,
    super.key,
  });

  final String title;
  final String intro;
  final List<InfoTopic> topics;

  /// Sits below the topics, inside the scrolling content.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String close = context.l10n.button_close;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: close,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(intro, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      ...topics,
                      if (footer case final footer?) ...[
                        const SizedBox(height: 8),
                        footer,
                      ],
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(close),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One point of an [InfoDialog]: its icon, title and text.
class InfoTopic extends StatelessWidget {
  const InfoTopic({
    required this.icon,
    required this.title,
    required this.text,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
