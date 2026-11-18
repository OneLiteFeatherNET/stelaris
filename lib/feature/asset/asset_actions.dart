import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/actions/asset_actions.dart';
import 'package:stelaris/feature/asset/models/model_revisions_dialog.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/dialogs/model_info_dialog.dart';
import 'package:stelaris/feature/dialogs/notes_edit_dialog.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// What can be done with one stored asset: edit its notes, show its info and
/// versions, store a new file, download it. Each opens at most one dialog.
///
/// Shared by the header buttons of an opened model ([AssetModelActions]) and
/// the card menu of the textures page. [onChanged] loads the page again
/// after something changed the asset. With [readOnly] (e.g. a texture
/// extracted from a Blockbench model) versions can't be restored and
/// [update] should not be offered.
class AssetActions {
  const AssetActions({
    required this.model,
    required this.pickFile,
    required this.saveFile,
    required this.onChanged,
    this.readOnly = false,
  });

  final AssetModel model;
  final Future<PickedAssetFile?> Function() pickFile;

  /// Saves downloaded [bytes] as [fileName].
  final void Function(List<int> bytes, String fileName) saveFile;
  final Future<void> Function() onChanged;
  final bool readOnly;

  Future<void> editNotes(BuildContext context) async {
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

  void openInfo(BuildContext context) => showDialog<void>(
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
  Future<void> openRevisions(BuildContext context) async {
    final result = await showDialog<RevisionsResult>(
      context: context,
      builder: (_) => ModelRevisionsDialog(
        asset: model,
        saveFile: saveFile,
        canRestore: !readOnly,
      ),
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
  Future<void> update(BuildContext context) async {
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
  Future<void> download(BuildContext context) async {
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
