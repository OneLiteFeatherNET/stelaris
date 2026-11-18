import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/loading/project_assets.dart';
import 'package:stelaris/feature/asset/models/asset_model_actions.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/feature/asset/textures/texture_detail.dart';
import 'package:stelaris/feature/asset/textures/texture_usage_sources.dart';
import 'package:stelaris/feature/asset/textures/texture_usages.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_dialog.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/search/dialog_search_bar.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/build/download/download_helper.dart'
    as download;
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/model/model_card_frame.dart';
import 'package:stelaris/feature/model/model_grid.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The insets of the other list pages (see `ModelPage`): the header sits
/// 12px below the top.
const EdgeInsets _pagePadding = EdgeInsets.fromLTRB(16, 12, 16, 0);

/// Where a texture comes from.
enum TextureOrigin {
  all,

  /// Uploaded on its own.
  uploaded,

  /// Extracted from a Blockbench model, see [AssetModel.sourceAssetId].
  extracted;

  bool matches(AssetModel texture) => switch (this) {
    all => true,
    uploaded => texture.sourceAssetId == null,
    extracted => texture.sourceAssetId != null,
  };
}

/// Shows the textures of the selected project as a grid of cards, with a
/// search by name and key and a filter by origin.
///
/// The selection is [selectedId]; the page reports a new one through
/// [onSelected], so the route can keep it. [pickFile] opens the file dialog
/// of the uploads and [saveFile] hands a download to the browser, both
/// injectable for tests.
class TexturesPage extends StatelessWidget {
  const TexturesPage({
    this.selectedId,
    this.onSelected,
    this.library,
    this.pickFile = pickAssetFile,
    this.saveFile = _saveInBrowser,
    this.loadUsageSources = loadTextureUsageSources,
    this.openLocation,
    super.key,
  });

  final String? selectedId;
  final ValueChanged<String?>? onSelected;

  /// The asset library to load from, [AssetLibrary.shared] when null.
  final AssetLibrary? library;
  final Future<PickedAssetFile?> Function() pickFile;

  /// Saves the downloaded [bytes] of a texture as [fileName].
  final void Function(List<int> bytes, String fileName) saveFile;

  static void _saveInBrowser(List<int> bytes, String fileName) =>
      download.saveFile(Uint8List.fromList(bytes), fileName);

  /// Loads the fonts and pack metas that refer to textures, for "used in".
  final Future<TextureUsageSources> Function(String projectId) loadUsageSources;

  /// Goes to another page, `context.go` when null; injectable for tests.
  final ValueChanged<String>? openLocation;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectView>(
      vm: () => _ProjectFactory(),
      builder: (context, vm) {
        final project = vm.project;
        if (project == null) {
          return Padding(
            padding: _pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(title: context.l10n.asset_textures_title),
                Expanded(
                  child: Center(
                    child: Text(context.l10n.asset_textures_no_project),
                  ),
                ),
              ],
            ),
          );
        }
        return _TexturesBody(
          key: ValueKey(project.id),
          projectId: project.id,
          namespace: project.key,
          selectedId: selectedId,
          onSelected: onSelected,
          library: library ?? AssetLibrary.shared,
          pickFile: pickFile,
          saveFile: saveFile,
          loadUsageSources: loadUsageSources,
          openLocation: openLocation ?? context.go,
        );
      },
    );
  }
}

class _ProjectView extends Vm {
  _ProjectView({required this.project}) : super(equals: [project]);

  /// The id and the key of the selected project, null without a project.
  final ({String id, String key})? project;
}

class _ProjectFactory extends VmFactory<AppState, TexturesPage, _ProjectView> {
  @override
  _ProjectView fromStore() => _ProjectView(
    project: switch (state.selectedProject) {
      Project(id: final id?, :final key) => (id: id, key: key),
      _ => null,
    },
  );
}

class _TexturesBody extends StatefulWidget {
  const _TexturesBody({
    required this.projectId,
    required this.namespace,
    required this.selectedId,
    required this.onSelected,
    required this.library,
    required this.pickFile,
    required this.saveFile,
    required this.loadUsageSources,
    required this.openLocation,
    super.key,
  });

  final String projectId;
  final String namespace;
  final String? selectedId;
  final ValueChanged<String?>? onSelected;
  final AssetLibrary library;
  final Future<PickedAssetFile?> Function() pickFile;
  final void Function(List<int> bytes, String fileName) saveFile;
  final Future<TextureUsageSources> Function(String projectId) loadUsageSources;
  final ValueChanged<String> openLocation;

  @override
  State<_TexturesBody> createState() => _TexturesBodyState();
}

class _TexturesBodyState extends State<_TexturesBody> {
  late final ProjectAssets _assets = ProjectAssets(
    library: widget.library,
    projectId: widget.projectId,
    onReloadFailed: _showReloadFailure,
  );

  /// The bytes of the textures shown as thumbnails, by their sha1, so a
  /// rebuild doesn't load them again.
  final Map<String, Future<Uint8List>> _thumbnails = {};

  String _query = '';
  TextureOrigin _origin = TextureOrigin.all;
  late String? _selectedId = widget.selectedId;

  /// The fonts and pack metas of the current load, null while they load.
  TextureUsageSources? _sources;
  bool _sourcesFailed = false;

  /// Counts the loads of [_sources], so an older one ending last is ignored.
  int _sourcesLoadId = 0;

  @override
  void initState() {
    super.initState();
    _assets.addListener(_onAssetsChanged);
    _load();
  }

  @override
  void didUpdateWidget(_TexturesBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      _selectedId = widget.selectedId;
    }
  }

  Future<void> _load() async {
    final loadId = ++_sourcesLoadId;
    setState(() {
      _sources = null;
      _sourcesFailed = false;
    });
    final sources = widget
        .loadUsageSources(widget.projectId)
        .then<TextureUsageSources?>((sources) => sources)
        .catchError((Object _) => null);
    await _assets.load();
    final loaded = await sources;
    if (!mounted || loadId != _sourcesLoadId) return;
    setState(() {
      _sources = loaded;
      _sourcesFailed = loaded == null;
    });
  }

  void _select(String? id) {
    setState(() => _selectedId = id);
    widget.onSelected?.call(id);
  }

  AssetModel? get _selected {
    for (final texture in _assets.textures) {
      if (texture.id == _selectedId) return texture;
    }
    return null;
  }

  /// Where [texture] is used, null until everything it needs has loaded.
  TextureUsages? _usagesOf(AssetModel texture) {
    final sources = _sources;
    if (sources == null || !_assets.referencesLoaded) return null;
    return textureUsages(
      texture,
      models: _assets.models,
      textures: _assets.textures,
      references: _assets.references,
      fonts: sources.fonts,
      packMetas: sources.packMetas,
    );
  }

  void _openModel(AssetModel model) => widget.openLocation(
    Uri(
      path: AssetNavigationEntry.models.route,
      queryParameters: {'id': model.id},
    ).toString(),
  );

  void _openFont(FontModel font) {
    context.dispatch(SelectFontAction(font));
    widget.openLocation(detailLocation(NavigationEntry.font.route));
  }

  /// Asks before deleting [texture], naming every use, then deletes it and
  /// goes back to the grid.
  Future<void> _delete(AssetModel texture, TextureUsages usages) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => FormDialog(
        title: l10n.asset_textures_delete_title(texture.displayName),
        actionIcon: Icons.delete_outline,
        actionLabel: l10n.tooltip_delete,
        destructive: true,
        maxWidth: 420,
        onSubmit: () => Navigator.of(context).pop(true),
        content: _DeleteContent(usages: usages),
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ApiService().assetApi.delete(widget.projectId, texture.id);
    } on DioException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        InfoBarFactory().createError(ProblemDetail.fromDioException(error)),
      );
      return;
    }
    if (!mounted) return;
    _select(null);
    await _load();
  }

  @override
  void dispose() {
    _assets
      ..removeListener(_onAssetsChanged)
      ..dispose();
    super.dispose();
  }

  void _onAssetsChanged() {
    if (mounted) setState(() {});
  }

  void _showReloadFailure(ProblemDetail problem) {
    if (!mounted) return;
    // A failed reload keeps the list it would have replaced.
    ScaffoldMessenger.of(context)
        .showSnackBar(InfoBarFactory().createError(problem));
  }

  Future<Uint8List> _thumbnailOf(AssetModel texture) => _thumbnails.putIfAbsent(
    texture.sha1,
    () async => Uint8List.fromList(
      await widget.library.contentOf(widget.projectId, texture),
    ),
  );

  /// The textures matching the search and the origin filter.
  List<AssetModel> get _visible {
    final query = _query.trim().toLowerCase();
    return [
      for (final texture in _assets.textures)
        if (_origin.matches(texture) &&
            (query.isEmpty ||
                texture.displayName.toLowerCase().contains(query) ||
                texture.key.toLowerCase().contains(query)))
          texture,
    ];
  }

  /// The model [texture] was extracted from, null for an uploaded one.
  AssetModel? _sourceOf(AssetModel texture) {
    final sourceId = texture.sourceAssetId;
    if (sourceId == null) return null;
    for (final model in _assets.models) {
      if (model.id == sourceId) return model;
    }
    return null;
  }

  Future<void> _upload() async {
    final asset = await showDialog<AssetModel>(
      context: context,
      builder: (context) => AssetUploadDialog(
        projectId: widget.projectId,
        namespace: widget.namespace,
        title: context.l10n.asset_textures_upload_title,
        pickFile: widget.pickFile,
        kinds: const {AssetKind.TEXTURE},
      ),
    );
    if (asset == null || !mounted) return;
    await _load();
    if (!mounted) return;
    _select(asset.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selected;
    if (selected != null) return _buildDetail(selected);
    return Padding(
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: _assets.listed
                ? '${l10n.asset_textures_title} (${_assets.textures.length})'
                : l10n.asset_textures_title,
            actions: [
              PageHeaderAction(
                key: const Key('textures_upload'),
                icon: const Icon(Icons.upload_file),
                label: l10n.asset_picker_upload_action,
                primary: true,
                onPressed: _upload,
              ),
            ],
          ),
          verticalSpacing10,
          _buildFilters(),
          verticalSpacing10,
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildDetail(AssetModel texture) {
    final l10n = context.l10n;
    final usages = _usagesOf(texture);
    final extracted = texture.sourceAssetId != null;
    return Padding(
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: texture.displayName,
            onBack: () => _select(null),
            compactBelow: PageHeader.detailCompactThreshold,
            actions: [
              if (!extracted) ...[
                PageHeaderAction(
                  key: const Key('texture_delete'),
                  icon: const Icon(Icons.delete_outline),
                  label: l10n.asset_textures_delete,
                  onPressed: usages == null
                      ? null
                      : () => _delete(texture, usages),
                ),
                const SizedBox(width: 8),
              ],
              AssetModelActions(
                model: texture,
                pickFile: widget.pickFile,
                saveFile: widget.saveFile,
                onChanged: _load,
                readOnly: extracted,
              ),
            ],
          ),
          verticalSpacing10,
          Expanded(
            child: SingleChildScrollView(
              child: TextureDetail(
                key: ValueKey(texture.id),
                projectId: widget.projectId,
                texture: texture,
                usages: usages,
                usagesFailed: _sourcesFailed,
                source: _sourceOf(texture),
                loadContent: (projectId, _) =>
                    widget.library.contentOf(projectId, texture),
                onOpenModel: _openModel,
                onOpenFont: _openFont,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final l10n = context.l10n;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: DialogSearchBar(
            key: const Key('textures_search'),
            hintText: l10n.asset_textures_search,
            onChanged: (query) => setState(() => _query = query),
          ),
        ),
        SegmentedButton<TextureOrigin>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: TextureOrigin.all,
              label: Text(l10n.asset_textures_origin_all),
            ),
            ButtonSegment(
              value: TextureOrigin.uploaded,
              label: Text(l10n.asset_textures_origin_uploaded),
            ),
            ButtonSegment(
              value: TextureOrigin.extracted,
              label: Text(l10n.asset_textures_origin_extracted),
            ),
          ],
          selected: {_origin},
          onSelectionChanged: (selection) =>
              setState(() => _origin = selection.single),
        ),
      ],
    );
  }

  /// Lower than on the other list pages, a texture card has no notes line.
  static const double _cardHeight = 132;

  Widget _buildGrid() {
    final l10n = context.l10n;
    if (_assets.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_assets.loadError case final problem?) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.asset_textures_load_failed),
            Text(problem.displayMessage),
            TextButton(onPressed: _load, child: Text(l10n.asset_picker_retry)),
          ],
        ),
      );
    }
    if (_assets.textures.isEmpty) {
      return Center(
        child: Text(l10n.asset_textures_empty, textAlign: TextAlign.center),
      );
    }
    final visible = _visible;
    if (visible.isEmpty) {
      return Center(child: Text(l10n.asset_textures_no_matches));
    }
    return ModelGrid<AssetModel>(
      key: const Key('textures_grid'),
      items: visible,
      cardHeight: _cardHeight,
      itemBuilder: (context, texture) => _TextureCard(
        key: ValueKey('texture_${texture.id}'),
        texture: texture,
        source: _sourceOf(texture),
        bytes: _thumbnailOf(texture),
        onTap: () => _select(texture.id),
      ),
    );
  }
}

/// One texture of the grid: its thumbnail, name and key, and in the footer
/// where it comes from.
class _TextureCard extends StatelessWidget {
  const _TextureCard({
    required this.texture,
    required this.source,
    required this.bytes,
    required this.onTap,
    super.key,
  });

  final AssetModel texture;

  /// The Blockbench model the texture was extracted from.
  final AssetModel? source;
  final Future<Uint8List> bytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final source = this.source;
    return ModelCardFrame(
      content: Row(
        children: [
          TextureThumbnail(asset: texture, bytes: bytes),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  texture.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                InfoChip(icon: Icons.vpn_key_outlined, text: texture.key),
              ],
            ),
          ),
        ],
      ),
      footerIcon: texture.sourceAssetId == null
          ? Icons.upload_file
          : Icons.view_in_ar_outlined,
      footerText: texture.sourceAssetId == null
          ? l10n.asset_textures_origin_uploaded
          : l10n.asset_textures_extracted_from(
              source?.displayName ?? texture.sourceAssetId!,
            ),
      onTap: onTap,
    );
  }
}

/// The body of the delete dialog: every use of the texture and what happens
/// to it.
class _DeleteContent extends StatelessWidget {
  const _DeleteContent({required this.usages});

  final TextureUsages usages;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (usages.isEmpty)
          Text(l10n.asset_textures_unused)
        else ...[
          Text(l10n.asset_textures_used_in),
          const SizedBox(height: 4),
          for (final model in usages.models) Text('• ${model.displayName}'),
          for (final font in usages.fonts) Text('• ${font.uiName}'),
          for (final type in usages.packIcons)
            Text('• ${packIconLabel(l10n, type)}'),
        ],
        verticalSpacing10,
        NoticeBox(
          icon: Icons.warning_amber_rounded,
          color: theme.colorScheme.error,
          content: Text(
            usages.isEmpty
                ? l10n.delete_dialog_irreversible
                : l10n.asset_textures_delete_warning,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
