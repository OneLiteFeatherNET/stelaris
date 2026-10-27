import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/feature/asset/asset_kind_label.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_controller.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_form.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The kinds the picker lists: the models an item can refer to.
const _pickableKinds = [AssetKind.MODEL, AssetKind.BBMODEL];

const _pageSize = 50;

/// Lets the user choose a model of [projectId] or upload a new one.
///
/// Resolves to the chosen model, or null when the dialog is closed. [namespace]
/// prefills the key of an upload, [selectedKey] preselects a listed model.
/// [previewBuilder] shows the selected model. [pickFile] opens the file dialog.
Future<AssetModel?> showAssetPickerDialog(
  BuildContext context, {
  required String projectId,
  String? namespace,
  String? selectedKey,
  Widget Function(AssetModel asset)? previewBuilder,
  Future<PickedAssetFile?> Function() pickFile = pickAssetFile,
}) {
  return showDialog<AssetModel>(
    context: context,
    builder: (_) => _AssetPickerDialog(
      projectId: projectId,
      namespace: namespace,
      selectedKey: selectedKey,
      previewBuilder: previewBuilder,
      pickFile: pickFile,
    ),
  );
}

List<AssetModel> _sortedByKey(Iterable<AssetModel> assets) =>
    [...assets]..sort((a, b) => a.key.compareTo(b.key));

class _AssetPickerDialog extends StatefulWidget {
  const _AssetPickerDialog({
    required this.projectId,
    required this.namespace,
    required this.selectedKey,
    required this.previewBuilder,
    required this.pickFile,
  });

  final String projectId;
  final String? namespace;
  final String? selectedKey;
  final Widget Function(AssetModel asset)? previewBuilder;
  final Future<PickedAssetFile?> Function() pickFile;

  @override
  State<_AssetPickerDialog> createState() => _AssetPickerDialogState();
}

class _AssetPickerDialogState extends State<_AssetPickerDialog> {
  late final AssetUploadController _upload = AssetUploadController(
    projectId: widget.projectId,
    namespace: widget.namespace,
    pickFile: widget.pickFile,
  );

  List<AssetModel> _assets = const [];
  AssetModel? _selected;
  bool _loading = true;
  ProblemDetail? _loadError;

  /// The key of the last texture uploaded. Textures are stored but not listed.
  String? _uploadedTextureKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _upload.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final lists = await Future.wait([
        for (final kind in _pickableKinds) _fetchAll(kind),
      ]);
      if (!mounted) return;
      final assets = _sortedByKey(lists.expand((list) => list));
      final preselected = widget.selectedKey;
      setState(() {
        _assets = assets;
        _selected = _firstWithKey(assets, preselected);
        _loading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = ProblemDetail.fromDioException(error);
        _loading = false;
      });
    }
  }

  Future<List<AssetModel>> _fetchAll(AssetKind kind) async {
    final assets = <AssetModel>[];
    var page = 0;
    while (true) {
      final result = await ApiService().assetApi.getPage(
        widget.projectId,
        kind: kind,
        page: page,
        size: _pageSize,
      );
      assets.addAll(result.items);
      page++;
      if (page >= result.totalPages) return assets;
    }
  }

  static AssetModel? _firstWithKey(List<AssetModel> assets, String? key) {
    if (key == null) return null;
    for (final asset in assets) {
      if (asset.key == key) return asset;
    }
    return null;
  }

  Future<void> _submitUpload() async {
    final asset = await _upload.upload();
    if (asset == null || !mounted) return;
    _upload.clear();
    setState(() {
      if (_pickableKinds.contains(asset.kind)) {
        _assets = _sortedByKey([
          ..._assets.where((listed) => listed.id != asset.id),
          asset,
        ]);
        _selected = asset;
        _uploadedTextureKey = null;
      } else {
        _uploadedTextureKey = asset.key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selected;
    final previewBuilder = widget.previewBuilder;
    return ListenableBuilder(
      listenable: _upload,
      builder: (context, _) => FormDialog(
        title: l10n.asset_picker_title,
        actionLabel: l10n.asset_picker_choose,
        maxWidth: 560,
        busy: _upload.uploading,
        onSubmit: selected == null || _upload.uploading
            ? null
            : () => Navigator.of(context).pop(selected),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildList(context),
            const SizedBox(height: 16),
            AssetUploadForm(controller: _upload, onSubmitted: _submitUpload),
            if (_upload.file != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _upload.uploading ? null : _upload.clear,
                    child: Text(l10n.button_cancel),
                  ),
                  const SizedBox(width: 8),
                  // Tonal, the dialog's own action is to choose a model.
                  FilledButton.tonal(
                    onPressed: _upload.canUpload ? _submitUpload : null,
                    child: Text(l10n.asset_picker_upload_action),
                  ),
                ],
              ),
            ],
            if (_uploadedTextureKey case final key?) ...[
              const SizedBox(height: 12),
              Text(l10n.asset_picker_texture_uploaded(key)),
            ],
            if (selected != null && previewBuilder != null) ...[
              const SizedBox(height: 16),
              KeyedSubtree(
                key: ValueKey(selected.id),
                child: previewBuilder(selected),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError case final problem?) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.asset_picker_load_failed),
          Text(problem.displayMessage, style: _errorStyle(context)),
          TextButton(onPressed: _load, child: Text(l10n.asset_picker_retry)),
        ],
      );
    }
    if (_assets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(l10n.asset_picker_empty),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final asset in _assets)
          ListTile(
            dense: true,
            selected: asset.id == _selected?.id,
            leading: Icon(assetKindIcon(asset.kind)),
            title: Text(asset.key),
            subtitle: Text(
              '${assetKindLabel(l10n, asset.kind)} · ${asset.fileName}',
            ),
            trailing: asset.id == _selected?.id
                ? const Icon(Icons.check)
                : null,
            onTap: () => setState(() => _selected = asset),
          ),
      ],
    );
  }

  TextStyle? _errorStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.error);
}
