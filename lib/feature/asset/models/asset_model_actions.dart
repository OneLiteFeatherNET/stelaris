import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/asset_actions.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/notes.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The Notes / Info / Versions / Update / Download actions in the header of
/// an opened model, like [ModelDetailActions] on the other detail pages.
///
/// Download is the main action here, as saving is on the other pages.
/// [onChanged] loads the page again after something changed the model.
class AssetModelActions extends StatelessWidget {
  const AssetModelActions({
    required this.model,
    required this.pickFile,
    required this.saveFile,
    required this.onChanged,
    this.readOnly = false,
    super.key,
  });

  /// True for an asset whose file belongs to another one, e.g. a texture
  /// extracted from a Blockbench model: no Update, and versions can't be
  /// restored.
  final bool readOnly;

  final AssetModel model;
  final Future<PickedAssetFile?> Function() pickFile;

  /// Saves downloaded [bytes] as [fileName].
  final void Function(List<int> bytes, String fileName) saveFile;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actions = AssetActions(
      model: model,
      pickFile: pickFile,
      saveFile: saveFile,
      onChanged: onChanged,
      readOnly: readOnly,
    );
    final hasNotes = notesSummary(model.comment) != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Editable here, unlike the other detail pages which only show them:
        // a model card has no menu to edit them.
        PageHeaderAction(
          key: const Key('model_notes'),
          icon: Badge(
            isLabelVisible: hasNotes,
            smallSize: 8,
            child: Icon(
              hasNotes ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined,
              semanticLabel: hasNotes ? l10n.tooltip_notes_present : null,
            ),
          ),
          label: l10n.action_notes,
          onPressed: () => actions.editNotes(context),
        ),
        const SizedBox(width: 8),
        PageHeaderAction(
          key: const Key('model_info'),
          icon: const Icon(Icons.info_outline),
          label: l10n.menu_item_info,
          onPressed: () => actions.openInfo(context),
        ),
        const SizedBox(width: 8),
        PageHeaderAction(
          key: const Key('model_revisions'),
          icon: const Icon(Icons.history),
          label: l10n.asset_model_revisions,
          onPressed: () => actions.openRevisions(context),
        ),
        if (!readOnly) ...[
          const SizedBox(width: 8),
          PageHeaderAction(
            key: const Key('model_update'),
            icon: const Icon(Icons.upload_outlined),
            label: l10n.asset_model_update,
            onPressed: () => actions.update(context),
          ),
        ],
        const SizedBox(width: 8),
        PageHeaderAction(
          key: const Key('model_download'),
          icon: const Icon(Icons.download_outlined),
          label: l10n.button_download,
          primary: true,
          onPressed: () => actions.download(context),
        ),
      ],
    );
  }
}
