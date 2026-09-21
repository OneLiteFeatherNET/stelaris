import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/dialogs/model_info_dialog.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/typedefs.dart';

/// The 3-dot action menu on a model card. Only "Info" today; further
/// actions (e.g. a future "Copy…") can be added as more [PopupMenuItem]s
/// without changing callers.
class ModelActionsMenu<E extends DataModel> extends StatelessWidget {
  const ModelActionsMenu({
    required this.value,
    required this.nameSelector,
    required this.keySelector,
    required this.projectKey,
    this.hasRelationshipData,
    super.key,
  });

  final E value;
  final ModelNameSelector<E> nameSelector;
  final ModelKeySelector<E> keySelector;

  /// The current project's key, used to build the namespaced key shown in
  /// the info dialog (just the key — the dialog has no use for the rest of
  /// the [Project], e.g. its display name or labor flag).
  final String projectKey;
  final HasRelationshipData<E>? hasRelationshipData;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      icon: const Icon(Icons.more_vert),
      // PopupMenuButton doesn't read the ambient IconButtonTheme the way a
      // plain IconButton does (e.g. DeleteModelButton) — without this it
      // falls back to the Material default (24), visibly larger than the
      // 18 the surrounding IconButtonTheme sets for the rest of the header.
      iconSize: 18,
      padding: EdgeInsets.zero,
      tooltip: context.l10n.tooltip_more_actions,
      itemBuilder: (context) => [
        PopupMenuItem<void>(
          onTap: () => _openInfoDialog(context),
          child: _MenuItemContent(
            icon: Icons.info_outline,
            label: context.l10n.menu_item_info,
          ),
        ),
      ],
    );
  }

  void _openInfoDialog(BuildContext context) {
    final name = nameSelector(value);
    final key = keySelector(value);
    final hasRelationships = hasRelationshipData?.call(value);

    // PopupMenuItem.onTap fires before its route is popped, so the dialog
    // must wait a beat or it would be shown (and immediately dismissed by)
    // the still-closing menu route.
    Future.microtask(() {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return ModelInfoDialog(
            name: name,
            namespacedKey: '$projectKey:$key',
            id: value.id,
            creationDate: value.creationDate,
            modificationDate: value.modificationDate,
            hasRelationshipData: hasRelationships,
          );
        },
      );
    });
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
        Text(label),
      ],
    );
  }
}
