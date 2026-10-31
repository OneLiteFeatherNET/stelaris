import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/actions/asset_actions.dart';
import 'package:stelaris/feature/asset/models/model_revisions_dialog.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/dialogs/model_info_dialog.dart';
import 'package:stelaris/feature/dialogs/notes_edit_dialog.dart';
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
    super.key,
  });

  final AssetModel model;
  final Future<PickedAssetFile?> Function() pickFile;

  /// Saves downloaded [bytes] as [fileName].
  final void Function(List<int> bytes, String fileName) saveFile;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          onPressed: () => _editNotes(context),
        ),
        const SizedBox(width: 8),
        PageHeaderAction(
          key: const Key('model_info'),
          icon: const Icon(Icons.info_outline),
          label: l10n.menu_item_info,
          onPressed: () => _openInfo(context),
        ),
        const SizedBox(width: 8),
        PageHeaderAction(
          key: const Key('model_revisions'),
          icon: const Icon(Icons.history),
          label: l10n.asset_model_revisions,
          onPressed: () => _openRevisions(context),
        ),
        const SizedBox(width: 8),
        PageHeaderAction(
          key: const Key('model_update'),
          icon: const Icon(Icons.upload_outlined),
          label: l10n.asset_model_update,
          onPressed: () => _update(context),
        ),
        const SizedBox(width: 8),
        PageHeaderAction(
          key: const Key('model_download'),
          icon: const Icon(Icons.download_outlined),
          label: l10n.button_download,
          primary: true,
          onPressed: () => _download(context),
        ),
      ],
    );
  }

  Future<void> _editNotes(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => NotesEditDialog(
        name: model.displayName,
        notes: model.comment,
        saveAction: (notes) => AssetNotesUpdateAction(model, notes),
      ),
    );
    if (!context.mounted) return;
    await onChanged();
  }

  void _openInfo(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => ModelInfoDialog(
      name: model.displayName,
      namespacedKey: model.key,
      id: model.id,
      creationDate: model.creationDate,
      modificationDate: model.modificationDate,
    ),
  );

  /// Lists the versions; after a restore, shows the outcome and loads again.
  Future<void> _openRevisions(BuildContext context) async {
    final result = await showDialog<RevisionsResult>(
      context: context,
      builder: (_) => ModelRevisionsDialog(asset: model, saveFile: saveFile),
    );
    if (result == null || !context.mounted) return;
    final l10n = context.l10n;
    switch (result) {
      case RevisionRestored(:final revision, :final asset):
        context.showSuccessSnackBar(
          l10n.asset_model_revision_restored(
            revision.number,
            asset.displayName,
          ),
        );
      case RevisionConflict():
        _showConflict(
          context,
          l10n.asset_model_revision_conflict(model.displayName),
        );
    }
    await onChanged();
  }

  /// Uploads a new file in place of the stored one.
  Future<void> _update(BuildContext context) async {
    final file = await pickFile();
    if (file == null || !context.mounted) return;
    final AssetModel updated;
    try {
      updated = await ApiService().assetApi.replaceContent(
        model,
        fileName: file.name,
        bytes: file.bytes,
      );
    } on DioException catch (error) {
      if (!context.mounted) return;
      // Someone else stored a new file since the page loaded the model.
      if (error.response?.statusCode == 412) {
        _showConflict(
          context,
          context.l10n.asset_model_update_conflict(model.displayName),
        );
        await onChanged();
        return;
      }
      context.showErrorSnackBar(error);
      return;
    }
    if (!context.mounted) return;
    context.showSuccessSnackBar(
      context.l10n.asset_model_updated(updated.displayName),
    );
    await onChanged();
  }

  /// Downloads the stored file under its file name.
  Future<void> _download(BuildContext context) async {
    final List<int> bytes;
    try {
      bytes = await ApiService().assetApi.content(model.projectId, model.id);
    } on DioException catch (error) {
      if (!context.mounted) return;
      context.showErrorSnackBar(error);
      return;
    }
    saveFile(bytes, model.fileName);
  }

  void _showConflict(BuildContext context, String detail) =>
      context.showErrorSnackBar(
        ProblemDetail(
          title: context.l10n.error_title,
          status: 412,
          detail: detail,
        ),
      );
}
