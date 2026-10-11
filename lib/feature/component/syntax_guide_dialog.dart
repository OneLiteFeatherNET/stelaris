import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// One kind of tag in the guide.
typedef _Entry = ({
  String tags,
  String Function(AppLocalizations l10n) description,
  String example,
});

/// Explains the MiniMessage tags with an example each, written out and the
/// way it looks in [componentContext].
class SyntaxGuideDialog extends StatelessWidget {
  const SyntaxGuideDialog({required this.componentContext, super.key});

  final ComponentContext componentContext;

  static Future<void> show(
    BuildContext context, {
    required ComponentContext componentContext,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => SyntaxGuideDialog(componentContext: componentContext),
    );
  }

  static final List<_Entry> _entries = [
    (
      tags: '<red>, <gold>, <#ff00aa>',
      description: (l10n) => l10n.minimessage_guide_color,
      example: '<gold>Epic <#55ccff>Sword',
    ),
    (
      tags: '<b>, <i>, <u>, <st>',
      description: (l10n) => l10n.minimessage_guide_decoration,
      example: '<b>Bold</b>, <i>italic</i> and <u>underlined</u>',
    ),
    (
      tags: '<gradient:red:blue>',
      description: (l10n) => l10n.minimessage_guide_gradient,
      example: '<gradient:gold:red:light_purple>Burning Blade</gradient>',
    ),
    (
      tags: '<rainbow>',
      description: (l10n) => l10n.minimessage_guide_rainbow,
      example: '<rainbow>Party Hat</rainbow>',
    ),
    (
      tags: '<reset>, <r>',
      description: (l10n) => l10n.minimessage_guide_reset,
      example: '<red><b>Danger <reset>is over',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return FormDialog(
      title: l10n.minimessage_guide_title,
      actionLabel: l10n.button_close,
      onSubmit: null,
      showActions: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, entry) in _entries.indexed) ...[
            if (index > 0) const Divider(height: 24),
            Text(entry.tags, style: theme.textTheme.titleSmall),
            const SizedBox(height: 2),
            Text(entry.description(l10n), style: muted),
            const SizedBox(height: 8),
            SelectableText(entry.example, style: muted),
            const SizedBox(height: 4),
            ComponentPreview(
              text: entry.example,
              componentContext: componentContext,
            ),
          ],
        ],
      ),
    );
  }
}
