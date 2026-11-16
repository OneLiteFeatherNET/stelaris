import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/dialogs/model_info_dialog.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/feature/base/button/card_actions_menu.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The [CardActionsMenu] of a model card: "Info", plus "Copy" when
/// [onCopy] is given and "Edit notes" when [onEditNotes] is given.
class ModelActionsMenu<E extends DataModel> extends StatelessWidget {
  const ModelActionsMenu({
    required this.value,
    required this.nameSelector,
    required this.keySelector,
    required this.projectKey,
    this.onEditNotes,
    this.onCopy,
    super.key,
  });

  final E value;
  final ModelNameSelector<E> nameSelector;
  final ModelKeySelector<E> keySelector;

  /// The current project's key, used to build the namespaced key shown in
  /// the info dialog (just the key — the dialog has no use for the rest of
  /// the [Project], e.g. its display name or labor flag).
  final String projectKey;

  /// Opens the notes dialog; the menu entry is hidden while this is null.
  final VoidCallback? onEditNotes;

  /// Opens the copy dialog; the menu entry is hidden while this is null.
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CardActionsMenu(
      entries: [
        (
          icon: Icons.info_outline,
          label: l10n.menu_item_info,
          onTap: () => _openInfoDialog(context),
        ),
        if (onCopy case final onCopy?)
          (
            icon: Icons.copy_outlined,
            label: l10n.menu_item_copy,
            onTap: onCopy,
          ),
        if (onEditNotes case final onEditNotes?)
          (
            icon: Icons.sticky_note_2_outlined,
            label: l10n.menu_item_edit_notes,
            onTap: onEditNotes,
          ),
      ],
    );
  }

  void _openInfoDialog(BuildContext context) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return ModelInfoDialog(
          name: nameSelector(value),
          namespacedKey: '$projectKey:${keySelector(value)}',
          id: value.id,
          creationDate: value.creationDate,
          modificationDate: value.modificationDate,
        );
      },
    );
  }
}
