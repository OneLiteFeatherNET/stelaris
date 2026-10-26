import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/asset_model.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/feature/asset/picker/asset_key.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

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
  final TextEditingController _keyController = TextEditingController();

  List<AssetModel> _assets = const [];
  AssetModel? _selected;
  bool _loading = true;
  ProblemDetail? _loadError;

  /// The file chosen for upload, waiting for its key to be confirmed.
  PickedAssetFile? _pending;
  bool _uploading = false;
  String? _keyError;
  String? _fileError;
  String? _uploadError;

  /// The key of the last texture uploaded. Textures are stored but not listed.
  String? _uploadedTextureKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _keyController.dispose();
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

  Future<void> _chooseFile() async {
    final picked = await widget.pickFile();
    if (picked == null || !mounted) return;
    setState(() {
      _pending = picked;
      _keyController.text = suggestAssetKey(
        picked.name,
        namespace: widget.namespace,
      );
      _keyError = null;
      _fileError = null;
      _uploadError = null;
      _uploadedTextureKey = null;
    });
  }

  void _cancelUpload() {
    setState(() {
      _pending = null;
      _keyError = null;
      _fileError = null;
      _uploadError = null;
    });
  }

  Future<void> _upload() async {
    final picked = _pending;
    if (picked == null) return;
    setState(() {
      _uploading = true;
      _keyError = null;
      _fileError = null;
      _uploadError = null;
    });
    try {
      final asset = await ApiService().assetApi.upload(
        widget.projectId,
        key: _keyController.text.trim(),
        fileName: picked.name,
        bytes: picked.bytes,
      );
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _pending = null;
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
    } on DioException catch (error) {
      if (!mounted) return;
      final problem = ProblemDetail.fromDioException(error);
      setState(() {
        _uploading = false;
        _showUploadProblem(problem);
      });
    }
  }

  /// Puts the backend's reasons under the field they name. The upload form
  /// stays open so the key can be corrected.
  void _showUploadProblem(ProblemDetail problem) {
    final errors = problem.errors;
    final keyMessages = [
      for (final error in errors)
        if (error.field == 'key') error.message,
    ];
    final fileMessages = [
      for (final error in errors)
        if (error.field == 'file') error.message,
    ];
    final otherMessages = [
      for (final error in errors)
        if (error.field != 'key' && error.field != 'file') error.message,
    ];

    // A conflict is about the key even when the backend names no field.
    _keyError = keyMessages.isNotEmpty
        ? keyMessages.join('\n')
        : (problem.status == 409 ? problem.displayMessage : null);
    _fileError = fileMessages.isEmpty ? null : fileMessages.join('\n');
    if (_keyError == null && _fileError == null) {
      _uploadError = problem.displayMessage;
    } else {
      _uploadError = otherMessages.isEmpty ? null : otherMessages.join('\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selected;
    final previewBuilder = widget.previewBuilder;
    return FormDialog(
      title: l10n.asset_picker_title,
      actionLabel: l10n.asset_picker_choose,
      maxWidth: 560,
      busy: _uploading,
      onSubmit: selected == null || _uploading
          ? null
          : () => Navigator.of(context).pop(selected),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildList(context),
          const SizedBox(height: 12),
          if (_pending case final pending?)
            _buildUploadForm(context, pending)
          else
            OutlinedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: Text(l10n.asset_picker_upload),
              onPressed: _uploading ? null : _chooseFile,
            ),
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
            leading: Icon(
              asset.kind == AssetKind.BBMODEL
                  ? Icons.view_in_ar
                  : Icons.category_outlined,
            ),
            title: Text(asset.key),
            subtitle: Text(
              '${_kindLabel(l10n, asset.kind)} · ${asset.fileName}',
            ),
            trailing: asset.id == _selected?.id
                ? const Icon(Icons.check)
                : null,
            onTap: () => setState(() => _selected = asset),
          ),
      ],
    );
  }

  Widget _buildUploadForm(BuildContext context, PickedAssetFile pending) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.asset_picker_file(pending.name)),
        if (_fileError case final error?)
          Text(error, style: _errorStyle(context)),
        const SizedBox(height: 8),
        TextField(
          controller: _keyController,
          enabled: !_uploading,
          decoration: InputDecoration(
            labelText: l10n.asset_picker_key,
            errorText: _keyError,
            errorMaxLines: 3,
          ),
          onChanged: (_) {
            if (_keyError != null) setState(() => _keyError = null);
          },
        ),
        if (_uploadError case final error?) ...[
          const SizedBox(height: 4),
          Text(error, style: _errorStyle(context)),
        ],
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _uploading ? null : _cancelUpload,
              child: Text(l10n.button_cancel),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _uploading ? null : _upload,
              child: Text(l10n.asset_picker_upload_action),
            ),
          ],
        ),
      ],
    );
  }

  TextStyle? _errorStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.error);

  String _kindLabel(AppLocalizations l10n, AssetKind kind) => switch (kind) {
    AssetKind.BBMODEL => l10n.asset_picker_kind_bbmodel,
    _ => l10n.asset_picker_kind_model,
  };
}
