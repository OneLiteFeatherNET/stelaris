import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/loading/project_assets.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_dialog.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/search/dialog_search_bar.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/build/download/download_helper.dart'
    as download;
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
    super.key,
  });

  final String projectId;
  final String namespace;
  final String? selectedId;
  final ValueChanged<String?>? onSelected;
  final AssetLibrary library;
  final Future<PickedAssetFile?> Function() pickFile;
  final void Function(List<int> bytes, String fileName) saveFile;

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

  @override
  void initState() {
    super.initState();
    _assets
      ..addListener(_onAssetsChanged)
      ..load();
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
    await _assets.load();
    if (!mounted) return;
    widget.onSelected?.call(asset.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            TextButton(
              onPressed: _assets.load,
              child: Text(l10n.asset_picker_retry),
            ),
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
        onTap: () => widget.onSelected?.call(texture.id),
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
