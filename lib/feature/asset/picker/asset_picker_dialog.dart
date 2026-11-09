import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/feature/asset/asset_kind_label.dart';
import 'package:stelaris/feature/asset/picker/asset_key.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_controller.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_form.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The kinds the picker lists by default: the models an item can refer to.
const Set<AssetKind> modelAssetKinds = {AssetKind.MODEL, AssetKind.BBMODEL};

/// The kinds a picker for a texture lists, e.g. the one of a font.
const Set<AssetKind> textureAssetKinds = {AssetKind.TEXTURE};

const _pageSize = 50;

/// Lets the user choose an asset of [projectId] or upload a new one.
///
/// Lists the assets of [kinds], the models by default, or [textureAssetKinds]
/// for a texture, or [soundAssetKinds] for a sound. An upload takes the files
/// of [uploadKinds], the textures and models by default.
///
/// With [hideExtracted] the textures extracted from a Blockbench model are not
/// listed, e.g. for a font, which can't use them. With [replaceable] a new
/// version of the selected asset can be uploaded in place of its file.
///
/// Resolves to the chosen asset, or null when the dialog is closed. [namespace]
/// prefills the key of an upload, whose path starts with [keyFolder].
/// [selectedKey] preselects a listed asset. [previewBuilder] shows the selected
/// asset. [pickFile] opens the file dialog.
Future<AssetModel?> showAssetPickerDialog(
  BuildContext context, {
  required String projectId,
  String? namespace,
  String? selectedKey,
  Widget Function(AssetModel asset)? previewBuilder,
  Set<AssetKind> kinds = modelAssetKinds,
  Set<AssetKind> uploadKinds = visualAssetKinds,
  String keyFolder = defaultAssetFolder,
  bool hideExtracted = false,
  bool replaceable = false,
  Future<PickedAssetFile?> Function() pickFile = pickAssetFile,
}) {
  return showDialog<AssetModel>(
    context: context,
    builder: (_) => _AssetPickerDialog(
      projectId: projectId,
      namespace: namespace,
      selectedKey: selectedKey,
      previewBuilder: previewBuilder,
      kinds: kinds,
      uploadKinds: uploadKinds,
      keyFolder: keyFolder,
      hideExtracted: hideExtracted,
      replaceable: replaceable,
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
    required this.kinds,
    required this.uploadKinds,
    required this.keyFolder,
    required this.hideExtracted,
    required this.replaceable,
    required this.pickFile,
  });

  final String projectId;
  final String? namespace;
  final String? selectedKey;
  final Widget Function(AssetModel asset)? previewBuilder;
  final Set<AssetKind> kinds;
  final Set<AssetKind> uploadKinds;
  final String keyFolder;
  final bool hideExtracted;
  final bool replaceable;
  final Future<PickedAssetFile?> Function() pickFile;

  @override
  State<_AssetPickerDialog> createState() => _AssetPickerDialogState();
}

class _AssetPickerDialogState extends State<_AssetPickerDialog> {
  late final AssetUploadController _upload = AssetUploadController(
    projectId: widget.projectId,
    namespace: widget.namespace,
    kinds: widget.uploadKinds,
    keyFolder: widget.keyFolder,
    pickFile: widget.pickFile,
  );

  List<AssetModel> _assets = const [];
  AssetModel? _selected;
  bool _loading = true;
  ProblemDetail? _loadError;

  /// The key of the last texture uploaded while only models are listed. Such
  /// a texture is stored but not listed.
  String? _uploadedTextureKey;

  /// Whether a new version of the selected asset is being uploaded.
  bool _replacing = false;

  /// What went wrong with the last new version, null after a success.
  String? _replaceError;

  /// The name of the asset whose new version was stored last.
  String? _replacedName;

  /// What the picker is for, which its texts name.
  _Picks get _picks => widget.kinds.contains(AssetKind.TEXTURE)
      ? _Picks.texture
      : widget.kinds.contains(AssetKind.SOUND)
      ? _Picks.sound
      : _Picks.model;

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
        for (final kind in widget.kinds) _fetchAll(kind),
      ]);
      if (!mounted) return;
      final assets = _sortedByKey(
        lists
            .expand((list) => list)
            .where(
              (asset) => !widget.hideExtracted || asset.sourceAssetId == null,
            ),
      );
      final preselected = widget.selectedKey;
      setState(() {
        _assets = assets;
        // A reload keeps the selection while its asset is still listed.
        _selected =
            _withId(assets, _selected?.id) ??
            _firstWithKey(assets, preselected);
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

  static AssetModel? _withId(List<AssetModel> assets, String? id) {
    if (id == null) return null;
    for (final asset in assets) {
      if (asset.id == id) return asset;
    }
    return null;
  }

  static AssetModel? _firstWithKey(List<AssetModel> assets, String? key) {
    if (key == null) return null;
    for (final asset in assets) {
      if (asset.key == key) return asset;
    }
    return null;
  }

  /// Uploads the chosen file and closes the dialog with it. A file of a kind
  /// the picker does not list, e.g. a texture for an item, is stored and
  /// reported, and the dialog stays open.
  Future<void> _submitUpload() async {
    if (!_upload.canUpload) return;
    final asset = await _upload.upload();
    if (asset == null || !mounted) return;
    if (widget.kinds.contains(asset.kind)) {
      Navigator.of(context).pop(asset);
      return;
    }
    _upload.clear();
    setState(() => _uploadedTextureKey = asset.key);
  }

  /// Uploads a new version of [asset] in place of its file. The backend
  /// answers 412 if the file changed meanwhile, then the list is loaded anew.
  Future<void> _replace(AssetModel asset) async {
    final file = await widget.pickFile();
    if (file == null || !mounted) return;
    setState(() {
      _replacing = true;
      _replaceError = null;
      _replacedName = null;
    });
    try {
      final updated = await ApiService().assetApi.replaceContent(
        asset,
        fileName: file.name,
        bytes: file.bytes,
      );
      if (!mounted) return;
      setState(() {
        _replacing = false;
        _replacedName = updated.displayName;
        _assets = _sortedByKey([
          ..._assets.where((listed) => listed.id != updated.id),
          updated,
        ]);
        _selected = updated;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      final conflict = error.response?.statusCode == 412;
      setState(() {
        _replacing = false;
        _replaceError = conflict
            ? context.l10n.asset_picker_replace_conflict(asset.displayName)
            : ProblemDetail.fromDioException(error).displayMessage;
      });
      if (conflict) await _load();
    }
  }

  /// The dialog's action: the upload while a file waits, else choosing the
  /// selected asset.
  VoidCallback? _submit(AssetModel? selected) {
    if (_upload.uploading || _replacing) return null;
    if (_upload.file != null) return _upload.canUpload ? _submitUpload : null;
    if (selected == null) return null;
    return () => Navigator.of(context).pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selected;
    final previewBuilder = widget.previewBuilder;
    return ListenableBuilder(
      listenable: _upload,
      builder: (context, _) => FormDialog(
        title: switch (_picks) {
          _Picks.texture => l10n.asset_picker_title_texture,
          _Picks.sound => l10n.asset_picker_title_sound,
          _Picks.model => l10n.asset_picker_title,
        },
        actionLabel: _upload.file != null
            ? l10n.asset_picker_upload_action
            : l10n.asset_picker_choose,
        maxWidth: 560,
        busy: _upload.uploading || _replacing,
        onSubmit: _submit(selected),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The hint to upload one is moot once a file is chosen.
            if (!_showsOnlyUpload) ...[
              _buildList(context),
              const SizedBox(height: 16),
            ],
            AssetUploadForm(controller: _upload, onSubmitted: _submitUpload),
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
            if (selected != null && widget.replaceable) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _replacing || _upload.uploading
                      ? null
                      : () => _replace(selected),
                  icon: const Icon(Icons.upload_file),
                  label: Text(l10n.asset_picker_replace),
                ),
              ),
              if (_replaceError case final error?)
                Text(error, style: _errorStyle(context))
              else if (_replacedName case final name?)
                Text(l10n.asset_picker_replaced(name)),
            ],
          ],
        ),
      ),
    );
  }

  /// Whether the list is left out: nothing is listed and a file waits for
  /// upload.
  bool get _showsOnlyUpload =>
      !_loading &&
      _loadError == null &&
      _assets.isEmpty &&
      _upload.file != null;

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
          Text(switch (_picks) {
            _Picks.texture => l10n.asset_picker_load_failed_texture,
            _Picks.sound => l10n.asset_picker_load_failed_sound,
            _Picks.model => l10n.asset_picker_load_failed,
          }),
          Text(problem.displayMessage, style: _errorStyle(context)),
          TextButton(onPressed: _load, child: Text(l10n.asset_picker_retry)),
        ],
      );
    }
    if (_assets.isEmpty) {
      // No padding of its own: the divider above and the gap to the upload
      // form below already set it apart.
      return Text(switch (_picks) {
        _Picks.texture => l10n.asset_picker_empty_texture,
        _Picks.sound => l10n.asset_picker_empty_sound,
        _Picks.model => l10n.asset_picker_empty,
      });
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
            title: Text(asset.displayName),
            subtitle: Text(_subtitle(context, asset)),
            trailing: asset.id == _selected?.id
                ? const Icon(Icons.check)
                : null,
            onTap: () => setState(() => _selected = asset),
          ),
      ],
    );
  }

  /// The key and kind of [asset], the size of a texture, which a font needs
  /// to know, and the length of a sound.
  String _subtitle(BuildContext context, AssetModel asset) {
    final parts = [asset.key, assetKindLabel(context.l10n, asset.kind)];
    if ((asset.width, asset.height) case (final width?, final height?)) {
      parts.add('$width × $height');
    }
    if (asset.durationMs case final ms?) {
      parts.add('${(ms / 1000).toStringAsFixed(1)} s');
    }
    return parts.join(' · ');
  }

  TextStyle? _errorStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.error);
}

enum _Picks { model, texture, sound }
