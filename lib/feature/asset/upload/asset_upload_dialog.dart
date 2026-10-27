import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_controller.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_form.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Uploads a file of one of [kinds], dropped on the page or chosen in the
/// file dialog, and pops with the stored asset. A rejected upload keeps the
/// dialog open and shows the reasons under the field they name.
class AssetUploadDialog extends StatefulWidget {
  const AssetUploadDialog({
    required this.projectId,
    required this.namespace,
    required this.title,
    required this.pickFile,
    this.kinds = const {...AssetKind.values},
    super.key,
  });

  final String projectId;

  /// The project key, which the suggested keys start with.
  final String? namespace;
  final String title;
  final Future<PickedAssetFile?> Function() pickFile;
  final Set<AssetKind> kinds;

  @override
  State<AssetUploadDialog> createState() => _AssetUploadDialogState();
}

class _AssetUploadDialogState extends State<AssetUploadDialog> {
  late final AssetUploadController _upload = AssetUploadController(
    projectId: widget.projectId,
    namespace: widget.namespace,
    pickFile: widget.pickFile,
    kinds: widget.kinds,
  );

  @override
  void dispose() {
    _upload.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final asset = await _upload.upload();
    if (asset == null || !mounted) return;
    Navigator.of(context).pop(asset);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _upload,
      builder: (context, _) => FormDialog(
        title: widget.title,
        actionLabel: context.l10n.asset_picker_upload_action,
        actionIcon: Icons.upload,
        maxWidth: 560,
        busy: _upload.uploading,
        onSubmit: _upload.canUpload ? _submit : null,
        content: AssetUploadForm(controller: _upload, onSubmitted: _submit),
      ),
    );
  }
}
