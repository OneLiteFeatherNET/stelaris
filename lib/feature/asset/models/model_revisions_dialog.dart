import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_form.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/relative_time.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// How the versions dialog closed, when a restore was tried.
sealed class RevisionsResult {
  const RevisionsResult();
}

/// The [revision] is the asset's file again, stored as the new [asset].
final class RevisionRestored extends RevisionsResult {
  const RevisionRestored(this.revision, this.asset);

  final AssetRevisionModel revision;
  final AssetModel asset;
}

/// The file changed since the page loaded it, so nothing was restored.
final class RevisionConflict extends RevisionsResult {
  const RevisionConflict();
}

/// Lists the stored versions of [asset], the newest first, each to download
/// or to restore. Only the first page is shown; it reaches far enough back
/// for now.
///
/// Pops a [RevisionsResult] after a restore was tried, null otherwise.
class ModelRevisionsDialog extends StatefulWidget {
  const ModelRevisionsDialog({
    required this.asset,
    required this.saveFile,
    super.key,
  });

  final AssetModel asset;

  /// Saves the downloaded [bytes] of a version as [fileName].
  final void Function(List<int> bytes, String fileName) saveFile;

  @override
  State<ModelRevisionsDialog> createState() => _ModelRevisionsDialogState();
}

class _ModelRevisionsDialogState extends State<ModelRevisionsDialog> {
  late final Future<List<AssetRevisionModel>> _revisions = ApiService().assetApi
      .revisions(widget.asset)
      .then((page) => page.items);
  bool _busy = false;

  /// The file name of [revision]: the asset's, with the version number
  /// before the extension, e.g. `ruby.v2.json`.
  String _fileNameOf(AssetRevisionModel revision) {
    final name = widget.asset.fileName;
    final dot = name.lastIndexOf('.');
    if (dot <= 0) return '$name.v${revision.number}';
    return '${name.substring(0, dot)}.v${revision.number}${name.substring(dot)}';
  }

  Future<void> _download(AssetRevisionModel revision) async {
    final List<int> bytes;
    try {
      bytes = await ApiService().assetApi.revisionContent(
        widget.asset,
        revision.id,
      );
    } on DioException catch (error) {
      if (!mounted) return;
      context.showErrorSnackBar(error);
      return;
    }
    widget.saveFile(bytes, _fileNameOf(revision));
  }

  Future<void> _restore(AssetRevisionModel revision) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => FormDialog(
        title: l10n.asset_model_revision_restore_title(revision.number),
        actionIcon: Icons.restore,
        actionLabel: l10n.asset_model_revision_restore_action,
        maxWidth: 420,
        onSubmit: () => Navigator.of(context).pop(true),
        content: Text(
          l10n.asset_model_revision_restore_body(
            revision.number,
            widget.asset.displayName,
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final asset = await ApiService().assetApi.restoreRevision(
        widget.asset,
        revision.id,
      );
      if (!mounted) return;
      Navigator.of(context).pop(RevisionRestored(revision, asset));
    } on DioException catch (error) {
      if (!mounted) return;
      if (error.response?.statusCode == 412) {
        Navigator.of(context).pop(const RevisionConflict());
        return;
      }
      setState(() => _busy = false);
      context.showErrorSnackBar(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FormDialog(
      title: l10n.asset_model_revisions_title(widget.asset.displayName),
      actionLabel: '',
      onSubmit: null,
      showActions: false,
      busy: _busy,
      content: FutureBuilder<List<AssetRevisionModel>>(
        future: _revisions,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(l10n.asset_model_revisions_failed);
          }
          final revisions = snapshot.data;
          if (revisions == null) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final revision in revisions)
                _RevisionTile(
                  key: ValueKey('model_revision_${revision.number}'),
                  revision: revision,
                  enabled: !_busy,
                  onDownload: () => _download(revision),
                  onRestore: () => _restore(revision),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// One version: its number, when it was stored, its size and comment, with
/// download and, unless it is the current one, restore.
class _RevisionTile extends StatelessWidget {
  const _RevisionTile({
    required this.revision,
    required this.enabled,
    required this.onDownload,
    required this.onRestore,
    super.key,
  });

  final AssetRevisionModel revision;
  final bool enabled;
  final VoidCallback onDownload;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final date = revision.creationDate;
    final details = [
      if (date != null) relativeTime(context, date),
      formatFileSize(revision.size),
    ].join(' · ');
    final comment = revision.comment;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Text(l10n.asset_model_revision(revision.number)),
          if (revision.current) ...[
            const SizedBox(width: 8),
            Chip(
              label: Text(l10n.asset_model_revision_current),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              labelStyle: theme.textTheme.labelSmall,
            ),
          ],
        ],
      ),
      subtitle: Text(
        comment == null || comment.isEmpty ? details : '$details\n$comment',
      ),
      isThreeLine: comment != null && comment.isNotEmpty,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.asset_model_revision_download,
            icon: const Icon(Icons.download_outlined),
            onPressed: enabled ? onDownload : null,
          ),
          if (!revision.current)
            IconButton(
              tooltip: l10n.asset_model_revision_restore,
              icon: const Icon(Icons.restore),
              onPressed: enabled ? onRestore : null,
            ),
        ],
      ),
    );
  }
}
