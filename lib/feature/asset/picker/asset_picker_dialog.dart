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
    builder: (dialogContext) => AssetPicker(
      onPicked: (asset) => Navigator.of(dialogContext).pop(asset),
      onCancel: () => Navigator.of(dialogContext).pop(),
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

/// The content of [showAssetPickerDialog], to show it in place of another
/// dialog's content instead of on top of it. [onPicked] gets the chosen
/// asset, [onCancel] is called when the user goes back without one.
///
/// With [embedded] a back button in the title leads to [onCancel], as the
/// user came from another content of the same dialog.
class AssetPicker extends StatefulWidget {
  const AssetPicker({
    required this.projectId,
    required this.onPicked,
    required this.onCancel,
    this.namespace,
    this.selectedKey,
    this.previewBuilder,
    this.kinds = modelAssetKinds,
    this.uploadKinds = visualAssetKinds,
    this.keyFolder = defaultAssetFolder,
    this.hideExtracted = false,
    this.replaceable = false,
    this.embedded = false,
    this.pickFile = pickAssetFile,
    super.key,
  });

  final ValueChanged<AssetModel> onPicked;
  final VoidCallback onCancel;
  final bool embedded;
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
  State<AssetPicker> createState() => _AssetPickerState();
}

class _AssetPickerState extends State<AssetPicker> {
  List<AssetModel> _assets = const [];
  AssetModel? _selected;
  bool _loading = true;
  ProblemDetail? _loadError;

  /// The key of the last texture uploaded while only models are listed. Such
  /// a texture is stored but not listed.
  String? _uploadedTextureKey;

  /// The name of the asset whose new version was stored last.
  String? _replacedName;

  /// The upload shown in place of the list, null while the list is shown.
  AssetUploadController? _upload;

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

  /// Switches to the upload, of a new asset or, with [replaces], of a new
  /// version of that one.
  void _startUpload({AssetModel? replaces}) {
    setState(() {
      _upload = AssetUploadController(
        projectId: widget.projectId,
        namespace: widget.namespace,
        kinds: switch (replaces) {
          final asset? => {asset.kind},
          null => widget.uploadKinds,
        },
        keyFolder: widget.keyFolder,
        pickFile: widget.pickFile,
        replaces: replaces,
      );
    });
  }

  /// Leaves the upload for the list. A new version left without being
  /// stored may have failed on a newer one, so the list is loaded anew.
  void _endUpload({bool reload = false}) {
    final upload = _upload;
    if (upload == null || upload.uploading) return;
    // The form still listens to the controller until it is gone.
    WidgetsBinding.instance.addPostFrameCallback((_) => upload.dispose());
    setState(() => _upload = null);
    if (reload) _load();
  }

  /// Lists [asset] in place of its older version and selects it.
  void _show(AssetModel asset) {
    _assets = _sortedByKey([
      ..._assets.where((listed) => listed.id != asset.id),
      asset,
    ]);
    _selected = asset;
  }

  /// Stores the chosen file and goes back to the list, where it is selected.
  /// A file of a kind the picker does not list, e.g. a texture for an item,
  /// is stored and reported.
  Future<void> _submitUpload() async {
    final upload = _upload;
    if (upload == null || !upload.canUpload) return;
    final replaces = upload.replaces;
    final asset = await upload.upload();
    if (asset == null || !mounted) return;
    _endUpload();
    setState(() {
      _uploadedTextureKey = null;
      _replacedName = replaces == null ? null : asset.displayName;
      if (widget.kinds.contains(asset.kind)) {
        _show(asset);
      } else {
        _uploadedTextureKey = asset.key;
      }
    });
  }

  @override
  void dispose() {
    _upload?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upload = _upload;
    // Escape and a tap beside the dialog go a step back where there is one,
    // as cancel does. The close icon still closes the dialog.
    return PopScope(
      canPop: upload == null && !widget.embedded,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (upload == null) {
          widget.onCancel();
        } else {
          _endUpload(reload: upload.conflict);
        }
      },
      child: upload == null
          ? _buildPicker(context)
          : ListenableBuilder(
              listenable: upload,
              builder: (context, _) => _buildUpload(context, upload),
            ),
    );
  }

  Widget _buildPicker(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selected;
    final previewBuilder = widget.previewBuilder;
    return FormDialog(
      title: switch (_picks) {
        _Picks.texture => l10n.asset_picker_title_texture,
        _Picks.sound => l10n.asset_picker_title_sound,
        _Picks.model => l10n.asset_picker_title,
      },
      titleActions: [
        // The empty list offers the upload itself.
        if (_assets.isNotEmpty)
          TextButton.icon(
            key: const Key('asset_picker_upload'),
            onPressed: _startUpload,
            icon: const Icon(Icons.upload),
            label: Text(l10n.asset_picker_upload_new),
          ),
      ],
      actionLabel: l10n.asset_picker_choose,
      maxWidth: 560,
      leading: widget.embedded
          ? IconButton(
              key: const Key('asset_picker_back'),
              tooltip: l10n.asset_picker_back_out,
              onPressed: widget.onCancel,
              icon: const Icon(Icons.arrow_back),
            )
          : null,
      onCancel: widget.onCancel,
      onSubmit: selected == null ? null : () => widget.onPicked(selected),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildList(context),
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
                onPressed: () => _startUpload(replaces: selected),
                icon: const Icon(Icons.upload_file),
                label: Text(l10n.asset_picker_replace),
              ),
            ),
            if (_replacedName case final name?)
              Text(l10n.asset_picker_replaced(name)),
          ],
        ],
      ),
    );
  }

  /// The upload in place of the list, with a way back to it.
  Widget _buildUpload(BuildContext context, AssetUploadController upload) {
    final l10n = context.l10n;
    final replaces = upload.replaces;
    return FormDialog(
      title: switch ((replaces, _picks)) {
        (final asset?, _) => l10n.asset_upload_replace_title(
          asset.displayName,
        ),
        (null, _Picks.texture) => l10n.asset_upload_title_texture,
        (null, _Picks.sound) => l10n.asset_upload_title_sound,
        (null, _Picks.model) => l10n.asset_upload_title_model,
      },
      leading: IconButton(
        key: const Key('asset_picker_back'),
        tooltip: l10n.asset_picker_back,
        onPressed: upload.uploading
            ? null
            : () => _endUpload(reload: upload.conflict),
        icon: const Icon(Icons.arrow_back),
      ),
      // Cancel drops the upload, as the back button does.
      onCancel: upload.uploading
          ? null
          : () => _endUpload(reload: upload.conflict),
      actionLabel: l10n.asset_picker_upload_action,
      actionIcon: Icons.upload,
      maxWidth: 560,
      busy: upload.uploading,
      onSubmit: upload.canUpload ? _submitUpload : null,
      content: AssetUploadForm(
        controller: upload,
        onSubmitted: _submitUpload,
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
      // Early in a project uploading is what the picker is opened for.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(switch (_picks) {
              _Picks.texture => l10n.asset_picker_empty_texture,
              _Picks.sound => l10n.asset_picker_empty_sound,
              _Picks.model => l10n.asset_picker_empty,
            }, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              key: const Key('asset_picker_upload'),
              onPressed: _startUpload,
              icon: const Icon(Icons.upload),
              label: Text(l10n.asset_picker_upload_new),
            ),
          ],
        ),
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
