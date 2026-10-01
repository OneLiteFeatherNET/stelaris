import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Shows a model's internal notes read-only, e.g. on its detail page.
///
/// Notes are only edited from the overview (card menu → "Edit notes"),
/// where they are saved right away — so they never mix with the detail
/// page's unsaved edits. The dialog points there.
class NotesViewDialog extends StatelessWidget {
  const NotesViewDialog({required this.name, required this.notes, super.key});

  final String name;
  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormDialog(
      title: context.l10n.dialog_notes_title(name),
      actionLabel: context.l10n.button_ok,
      onSubmit: null,
      showActions: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText(notes, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.l10n.notes_edit_in_overview,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
