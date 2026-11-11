import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/feature/asset/asset_kind_label.dart';
import 'package:stelaris/feature/asset/picker/asset_key.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
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

/// The tab of the upload, behind the one that lists the assets.
const _uploadTab = 1;

/// From this many assets on the list can be searched.
const _searchFrom = 8;

/// The height of a row of the list, a dense tile of two lines.
const double _rowHeight = 64;

/// How many rows the list shows before it scrolls. The half one hints at the
/// rows below.
const double _visibleRows = 4.5;

/// Lets the user choose an asset of [projectId] or upload a new one, each in
/// a tab of its own.
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

class _AssetPickerState extends State<AssetPicker>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final TextEditingController _search = TextEditingController();
  final ScrollController _listScroll = ScrollController();

  List<AssetModel> _assets = const [];
  AssetModel? _selected;
  bool _loading = true;
  ProblemDetail? _loadError;

  /// The key of the last texture uploaded while only models are listed. Such
  /// a texture is stored but not listed.
  String? _uploadedTextureKey;

  /// The name of the asset whose new version was stored last.
  String? _replacedName;

  /// The upload of a new asset, shown in its tab.
  late AssetUploadController _upload = _newUpload();

  /// The file of [_upload] the upload tab was opened for.
  PickedAssetFile? _takenFile;

  /// The upload of a new version, shown in place of the tabs, null while
  /// they are shown.
  AssetUploadController? _replace;

  /// Whether the user chose a tab, which an empty list then leaves alone.
  bool _tabChosen = false;

  /// The bytes of the listed textures by id and hash, so a row scrolled back
  /// into view does not load its texture again.
  final Map<String, Future<Uint8List>> _thumbnails = {};

  /// What the picker is for, which its texts name.
  _Picks get _picks => widget.kinds.contains(AssetKind.TEXTURE)
      ? _Picks.texture
      : widget.kinds.contains(AssetKind.SOUND)
      ? _Picks.sound
      : _Picks.model;

  /// The listed assets whose name or key contains what is searched for.
  List<AssetModel> get _matches {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _assets;
    return [
      for (final asset in _assets)
        if (asset.displayName.toLowerCase().contains(query) ||
            asset.key.toLowerCase().contains(query))
          asset,
    ];
  }

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearchChanged);
    _load();
  }

  void _onSearchChanged() => setState(() {});

  AssetUploadController _newUpload() => AssetUploadController(
    projectId: widget.projectId,
    namespace: widget.namespace,
    kinds: widget.uploadKinds,
    keyFolder: widget.keyFolder,
    pickFile: widget.pickFile,
  )..addListener(_showTakenFile);

  /// A file dropped on the dialog while it lists the assets is taken by the
  /// upload, which its tab then shows.
  void _showTakenFile() {
    final file = _upload.file;
    if (identical(file, _takenFile)) return;
    _takenFile = file;
    if (file != null) _tabs.index = _uploadTab;
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
      // Early in a project uploading is what the picker is opened for.
      if (assets.isEmpty && !_tabChosen) _tabs.index = _uploadTab;
      _revealSelected();
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

  Future<Uint8List> _thumbnail(AssetModel asset) => _thumbnails.putIfAbsent(
    '${asset.id}:${asset.sha1}',
    () async => Uint8List.fromList(
      await ApiService().assetApi.content(widget.projectId, asset.id),
    ),
  );

  /// Scrolls the list to the selected asset where it is out of view.
  void _revealSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listScroll.hasClients) return;
      final index = _matches.indexWhere((asset) => asset.id == _selected?.id);
      if (index < 0) return;
      final position = _listScroll.position;
      final top = index * _rowHeight;
      final inView =
          top >= position.pixels &&
          top + _rowHeight <= position.pixels + position.viewportDimension;
      if (!inView) {
        _listScroll.jumpTo(math.min(top, position.maxScrollExtent));
      }
    });
  }

  /// Switches to the upload of a new version of [asset].
  void _startReplace(AssetModel asset) {
    setState(() {
      _replace = AssetUploadController(
        projectId: widget.projectId,
        namespace: widget.namespace,
        kinds: {asset.kind},
        keyFolder: widget.keyFolder,
        pickFile: widget.pickFile,
        replaces: asset,
      );
    });
  }

  /// Leaves the new version for the tabs. One left without being stored may
  /// have failed on a newer one, so the list is loaded anew.
  void _endReplace({bool reload = false}) {
    final replace = _replace;
    if (replace == null || replace.uploading) return;
    // The form still listens to the controller until it is gone.
    WidgetsBinding.instance.addPostFrameCallback((_) => replace.dispose());
    setState(() => _replace = null);
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

  /// Stores the chosen file and picks it, as it was uploaded to be used. A
  /// file of a kind the picker does not list, e.g. a texture for an item, is
  /// stored and reported in the upload tab.
  Future<void> _submitUpload() async {
    final upload = _upload;
    if (!upload.canUpload) return;
    final asset = await upload.upload();
    if (asset == null || !mounted) return;
    if (widget.kinds.contains(asset.kind)) {
      widget.onPicked(asset);
      return;
    }
    // The next upload starts without the name and key of this one. The form
    // still listens to the controller until it is gone.
    upload.removeListener(_showTakenFile);
    WidgetsBinding.instance.addPostFrameCallback((_) => upload.dispose());
    setState(() {
      _upload = _newUpload();
      _takenFile = null;
      _replacedName = null;
      _uploadedTextureKey = asset.key;
    });
  }

  /// Stores the new version and shows the list with it.
  Future<void> _submitReplace() async {
    final replace = _replace;
    if (replace == null || !replace.canUpload) return;
    final asset = await replace.upload();
    if (asset == null || !mounted) return;
    _endReplace();
    setState(() {
      _uploadedTextureKey = null;
      _replacedName = asset.displayName;
      _show(asset);
    });
  }

  @override
  void dispose() {
    _upload.dispose();
    _replace?.dispose();
    _tabs.dispose();
    _search.dispose();
    _listScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final replace = _replace;
    // Escape and a tap beside the dialog go a step back where there is one,
    // as cancel does. The close icon still closes the dialog.
    return PopScope(
      canPop: replace == null && !widget.embedded,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (replace == null) {
          widget.onCancel();
        } else {
          _endReplace(reload: replace.conflict);
        }
      },
      child: replace == null
          ? ListenableBuilder(
              listenable: Listenable.merge([_tabs, _upload]),
              builder: (context, _) => _buildTabs(context),
            )
          : ListenableBuilder(
              listenable: replace,
              builder: (context, _) => _buildReplace(context, replace),
            ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selected;
    final uploads = _tabs.index == _uploadTab;
    return FormDialog(
      title: switch (_picks) {
        _Picks.texture => l10n.asset_picker_title_texture,
        _Picks.sound => l10n.asset_picker_title_sound,
        _Picks.model => l10n.asset_picker_title,
      },
      maxWidth: 560,
      leading: widget.embedded
          ? IconButton(
              key: const Key('asset_picker_back'),
              tooltip: l10n.asset_picker_back_out,
              onPressed: _upload.uploading ? null : widget.onCancel,
              icon: const Icon(Icons.arrow_back),
            )
          : null,
      // A running upload keeps its tab.
      header: IgnorePointer(
        ignoring: _upload.uploading,
        child: TabBar.secondary(
          controller: _tabs,
          dividerHeight: 0,
          onTap: (_) => _tabChosen = true,
          tabs: [
            Tab(
              key: const Key('asset_picker_tab_existing'),
              text: l10n.asset_picker_tab_existing,
            ),
            Tab(
              key: const Key('asset_picker_tab_upload'),
              text: l10n.asset_picker_tab_upload,
            ),
          ],
        ),
      ),
      onCancel: widget.onCancel,
      busy: _upload.uploading,
      actionLabel: uploads
          ? l10n.asset_picker_upload_action
          : l10n.asset_picker_choose,
      actionIcon: uploads ? Icons.upload : null,
      onSubmit: uploads
          ? (_upload.canUpload ? _submitUpload : null)
          : (selected == null ? null : () => widget.onPicked(selected)),
      // Both tabs stay mounted: the dialog keeps its height, the upload its
      // file, and a file dropped on the list still reaches the upload.
      content: IndexedStack(
        index: _tabs.index,
        children: [_buildExisting(context), _buildUploadTab(context)],
      ),
    );
  }

  Widget _buildExisting(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selected;
    final previewBuilder = widget.previewBuilder;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildList(context),
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
              onPressed: () => _startReplace(selected),
              icon: const Icon(Icons.upload_file),
              label: Text(l10n.asset_picker_replace),
            ),
          ),
          if (_replacedName case final name?)
            Text(l10n.asset_picker_replaced(name)),
        ],
      ],
    );
  }

  Widget _buildUploadTab(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AssetUploadForm(controller: _upload, onSubmitted: _submitUpload),
        if (_uploadedTextureKey case final key?) ...[
          const SizedBox(height: 12),
          Text(context.l10n.asset_picker_texture_uploaded(key)),
        ],
      ],
    );
  }

  /// The upload of a new version in place of the tabs, with a way back.
  Widget _buildReplace(BuildContext context, AssetUploadController replace) {
    final l10n = context.l10n;
    final back = replace.uploading
        ? null
        : () => _endReplace(reload: replace.conflict);
    return FormDialog(
      title: l10n.asset_upload_replace_title(replace.replaces!.displayName),
      leading: IconButton(
        key: const Key('asset_picker_back'),
        tooltip: l10n.asset_picker_back,
        onPressed: back,
        icon: const Icon(Icons.arrow_back),
      ),
      // Cancel drops the new version, as the back button does.
      onCancel: back,
      actionLabel: l10n.asset_picker_upload_action,
      actionIcon: Icons.upload,
      maxWidth: 560,
      busy: replace.uploading,
      onSubmit: replace.canUpload ? _submitReplace : null,
      content: AssetUploadForm(
        controller: replace,
        onSubmitted: _submitReplace,
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(switch (_picks) {
          _Picks.texture => l10n.asset_picker_empty_texture,
          _Picks.sound => l10n.asset_picker_empty_sound,
          _Picks.model => l10n.asset_picker_empty,
        }, textAlign: TextAlign.center),
      );
    }
    final matches = _matches;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_assets.length >= _searchFrom) ...[
          TextField(
            key: const Key('asset_picker_search'),
            controller: _search,
            decoration: InputDecoration(
              hintText: l10n.asset_picker_search,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.asset_picker_search_clear,
                      onPressed: _search.clear,
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        // As high as for all assets, so the dialog keeps its height while
        // the search narrows them down.
        SizedBox(
          height: math.min(_assets.length, _visibleRows) * _rowHeight,
          child: matches.isEmpty
              ? Center(child: Text(l10n.asset_picker_no_match))
              : ListView.builder(
                  controller: _listScroll,
                  itemExtent: _rowHeight,
                  itemCount: matches.length,
                  itemBuilder: (context, index) =>
                      _buildRow(context, matches[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, AssetModel asset) {
    final selected = asset.id == _selected?.id;
    return ListTile(
      dense: true,
      // As high as its row at any density, or its content sits above the
      // middle of the row.
      minTileHeight: _rowHeight,
      selected: selected,
      leading: asset.kind == AssetKind.TEXTURE
          ? TextureThumbnail(asset: asset, bytes: _thumbnail(asset))
          : Icon(assetKindIcon(asset.kind)),
      title: Text(
        asset.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _subtitle(context, asset),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: () => setState(() => _selected = asset),
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
