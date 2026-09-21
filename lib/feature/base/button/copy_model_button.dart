import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/dialogs/copy_model_dialog.dart';
import 'package:stelaris/feature/dialogs/model_info_dialog.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/typedefs.dart';

/// The 3-dot action menu on a model card: "Copy…" and "Info". Further
/// actions can be added as more [PopupMenuItem]s without changing callers.
class CopyModelButton<E extends DataModel> extends StatelessWidget {
  const CopyModelButton({
    required this.value,
    required this.copyDialogTitle,
    required this.nameSelector,
    required this.keySelector,
    required this.projects,
    required this.currentProject,
    required this.mapToCopySuccessfully,
    this.hasRelationshipData,
    super.key,
  });

  final E value;
  final String copyDialogTitle;
  final ModelNameSelector<E> nameSelector;
  final ModelKeySelector<E> keySelector;
  final List<Project> projects;
  final Project currentProject;
  final MapToCopySuccessfully<E> mapToCopySuccessfully;
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
          onTap: () => _openCopyDialog(context),
          child: _MenuItemContent(
            icon: Icons.copy_outlined,
            label: context.l10n.menu_item_copy,
          ),
        ),
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

    // See the note in _openCopyDialog: the menu route is still closing when
    // onTap fires, so opening the dialog synchronously would show and
    // immediately dismiss it.
    Future.microtask(() {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return ModelInfoDialog(
            name: name,
            namespacedKey: '${currentProject.key}:$key',
            id: value.id,
            creationDate: value.creationDate,
            modificationDate: value.modificationDate,
            hasRelationshipData: hasRelationships,
          );
        },
      );
    });
  }

  void _openCopyDialog(BuildContext context) {
    final name = nameSelector(value);
    final key = keySelector(value);
    final hasRelationships = hasRelationshipData?.call(value) ?? false;

    // PopupMenuItem.onTap fires before its route is popped, so the dialog
    // must wait a beat or it would be shown (and immediately dismissed by)
    // the still-closing menu route.
    Future.microtask(() {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return CopyModelDialog(
            title: copyDialogTitle,
            projects: projects,
            currentProject: currentProject,
            initialName: '$name ${context.l10n.dialog_model_copy_name_suffix}',
            initialKey: '$key${context.l10n.dialog_model_copy_key_suffix}',
            hasRelationshipData: hasRelationships,
            onSubmit: (result) {
              if (mapToCopySuccessfully(value, result)) {
                Navigator.of(context).pop(true);
              }
            },
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
