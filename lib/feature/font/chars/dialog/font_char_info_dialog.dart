import 'package:material_ui/material_ui.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Explains the characters of a font: why they come from the Unicode Private
/// Use Area, which areas there are and how to type them. Read-only, laid out
/// like the generator info dialog.
class FontCharInfoDialog extends StatelessWidget {
  const FontCharInfoDialog({super.key});

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
                      l10n.font_char_info_title,
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
                        l10n.font_char_info_intro,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      _Topic(
                        icon: Icons.grid_view_outlined,
                        title: l10n.font_char_info_areas_title,
                        text: l10n.font_char_info_areas,
                      ),
                      _Topic(
                        icon: Icons.keyboard_outlined,
                        title: l10n.font_char_info_input_title,
                        text: l10n.font_char_info_input,
                      ),
                      _Topic(
                        icon: Icons.view_module_outlined,
                        title: l10n.font_char_info_rows_title,
                        text: l10n.font_char_info_rows,
                      ),
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

/// One point of the explanation: its icon, title and text.
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
