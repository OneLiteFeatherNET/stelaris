import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Explains the generator page: what it is for and what each tab does, and,
/// in demo mode, that nothing reaches the real generator. Read-only, laid out
/// like the model info dialog.
class GeneratorInfoDialog extends StatelessWidget {
  const GeneratorInfoDialog({required this.demo, super.key});

  /// Whether the page simulates the generator.
  final bool demo;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

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
                      l10n.generator_info_title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.button_close,
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
                      Text(
                        l10n.generator_info_intro,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      _Topic(
                        icon: Icons.download_outlined,
                        title: l10n.generator_tab_local,
                        text: l10n.generator_info_local,
                      ),
                      _Topic(
                        icon: Icons.publish_outlined,
                        title: l10n.generator_tab_publish,
                        text: l10n.generator_info_publish,
                      ),
                      _Topic(
                        icon: Icons.history,
                        title: l10n.generator_tab_versions,
                        text: l10n.generator_info_versions,
                      ),
                      if (demo) ...[
                        const SizedBox(height: 8),
                        NoticeBox(
                          icon: Icons.science_outlined,
                          color: theme.colorScheme.tertiary,
                          content: Text(l10n.generator_info_demo),
                        ),
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
                    child: Text(l10n.button_close),
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

/// One tab of the page: its icon and name, and what it does.
class _Topic extends StatelessWidget {
  const _Topic({required this.icon, required this.title, required this.text});

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
