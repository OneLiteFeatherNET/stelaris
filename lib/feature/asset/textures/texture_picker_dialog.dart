import 'dart:async';
import 'dart:math' as math;

import 'package:async_redux/async_redux.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/app_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/picker/asset_key.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/textures/texture_card.dart';
import 'package:stelaris/feature/asset/textures/texture_detail.dart';
import 'package:stelaris/feature/asset/textures/texture_library.dart';
import 'package:stelaris/feature/asset/textures/texture_usage_sources.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Lets the user choose an uploaded texture of [projectId] from a grid of
/// cards, with a preview of the chosen one beside it that can be hidden.
///
/// Resolves to the chosen texture, or null when the dialog is closed.
/// [selectedId] is selected when the dialog opens. A new texture is
/// uploaded under [keyFolder] of [namespace]; [onUpdated] is told about
/// every texture stored in a new version, also when the dialog is closed
/// afterwards. [currentFontId] is the font the texture is chosen for, which
/// the update does not name among the other uses.
Future<AssetModel?> showTexturePickerDialog(
  BuildContext context, {
  required String projectId,
  required String namespace,
  String? selectedId,
  String? currentFontId,
  String keyFolder = defaultAssetFolder,
  ValueChanged<AssetModel>? onUpdated,
  AssetLibrary? library,
  Future<PickedAssetFile?> Function() pickFile = pickAssetFile,
  Future<TextureUsageSources> Function(String projectId) loadUsageSources =
      loadTextureUsageSources,
}) => showDialog<AssetModel>(
  context: context,
  builder: (dialogContext) => TexturePicker(
    projectId: projectId,
    namespace: namespace,
    selectedId: selectedId,
    currentFontId: currentFontId,
    keyFolder: keyFolder,
    onUpdated: onUpdated,
    library: library,
    pickFile: pickFile,
    loadUsageSources: loadUsageSources,
    onPicked: (texture) => Navigator.of(dialogContext).pop(texture),
    onCancel: () => Navigator.of(dialogContext).pop(),
  ),
);

/// The content of [showTexturePickerDialog]. [onPicked] gets the chosen
/// texture, [onCancel] is called when the user leaves without one.
class TexturePicker extends StatefulWidget {
  const TexturePicker({
    required this.projectId,
    required this.namespace,
    required this.onPicked,
    required this.onCancel,
    this.selectedId,
    this.currentFontId,
    this.keyFolder = defaultAssetFolder,
    this.onUpdated,
    this.library,
    this.pickFile = pickAssetFile,
    this.loadUsageSources = loadTextureUsageSources,
    super.key,
  });

  final String projectId;
  final String namespace;
  final ValueChanged<AssetModel> onPicked;
  final VoidCallback onCancel;
  final String? selectedId;
  final String? currentFontId;
  final String keyFolder;
  final ValueChanged<AssetModel>? onUpdated;

  /// The asset library to load from, [AssetLibrary.shared] when null.
  final AssetLibrary? library;
  final Future<PickedAssetFile?> Function() pickFile;
  final Future<TextureUsageSources> Function(String projectId) loadUsageSources;

  @override
  State<TexturePicker> createState() => _TexturePickerState();
}

/// The widest a card gets before another column fits.
const double _maxCardExtent = 280;

/// The height of a card, as on the textures page.
const double _cardHeight = 132;

/// The space between two cards, across and down.
const double _spacing = 12;

/// The width of the preview beside the grid.
const double _previewWidth = 280;

/// From this width on the preview sits beside the grid, below it before.
const double _besideFrom = 720;

/// The height of the content, so the dialog keeps it while searching.
const double _contentHeight = 440;

class _TexturePickerState extends State<TexturePicker> {
  late final AssetLibrary _assetLibrary = widget.library ?? AssetLibrary.shared;
  late final TextureLibrary _library = TextureLibrary(
    library: _assetLibrary,
    projectId: widget.projectId,
    loadUsageSources: widget.loadUsageSources,
  );
  final TextEditingController _search = TextEditingController();
  final ScrollController _grid = ScrollController();

  /// The id of the selected texture, also before the textures are loaded.
  String? _selectedId;

  /// Whether the grid was scrolled to the texture selected on opening.
  bool _revealed = false;

  /// The texture tapped last, picked by a second tap until [_armTimer] ends.
  String? _armedId;
  Timer? _armTimer;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
    _library.addListener(_onLibraryChanged);
    _search.addListener(_onSearchChanged);
    _library.load();
  }

  @override
  void dispose() {
    _armTimer?.cancel();
    _library
      ..removeListener(_onLibraryChanged)
      ..dispose();
    _search.dispose();
    _grid.dispose();
    super.dispose();
  }

  void _onLibraryChanged() {
    if (mounted) setState(() {});
  }

  void _onSearchChanged() => setState(() {});

  /// The uploaded textures; an extracted one belongs to its model.
  List<AssetModel> get _uploaded => [
    for (final texture in _library.textures)
      if (texture.sourceAssetId == null) texture,
  ];

  /// The uploaded textures matching the search, sorted by key.
  List<AssetModel> _matching(List<AssetModel> uploaded) {
    final query = _search.text.trim().toLowerCase();
    return [
      for (final texture in uploaded)
        if (query.isEmpty ||
            texture.displayName.toLowerCase().contains(query) ||
            texture.key.toLowerCase().contains(query))
          texture,
    ]..sort(_byKey);
  }

  /// By key, then name and id, like the textures page.
  static int _byKey(AssetModel a, AssetModel b) {
    final byKey = a.key.compareTo(b.key);
    if (byKey != 0) return byKey;
    final byName = a.displayName.compareTo(b.displayName);
    return byName != 0 ? byName : a.id.compareTo(b.id);
  }

  /// The selected texture as last loaded, null when it isn't listed.
  AssetModel? _selectedIn(List<AssetModel> uploaded) {
    final id = _selectedId;
    if (id == null) return null;
    for (final texture in uploaded) {
      if (texture.id == id) return texture;
    }
    return null;
  }

  /// Selects [texture]; a second tap on it within the double tap time picks
  /// it. No double tap recognizer: it would hold back every single tap.
  void _tap(AssetModel texture) {
    if (_armedId == texture.id) {
      _armTimer?.cancel();
      widget.onPicked(texture);
      return;
    }
    setState(() => _selectedId = texture.id);
    _armedId = texture.id;
    _armTimer?.cancel();
    _armTimer = Timer(kDoubleTapTimeout, () => _armedId = null);
  }

  void _startUpload() {}

  void _startUpdate(AssetModel texture) {}

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.openTexturePreview,
      builder: (context, open) => _buildChoose(context, open),
    );
  }

  Widget _buildChoose(BuildContext context, bool open) {
    final l10n = context.l10n;
    final uploaded = _uploaded;
    final selected = _selectedIn(uploaded);
    return FormDialog(
      title: l10n.asset_picker_title_texture,
      maxWidth: 900,
      header: _buildBar(context, open),
      onCancel: widget.onCancel,
      actionLabel: l10n.asset_picker_choose,
      onSubmit: selected == null ? null : () => widget.onPicked(selected),
      content: SizedBox(
        height: _contentHeight,
        child: _buildBody(context, open, uploaded, selected),
      ),
    );
  }

  Widget _buildBar(BuildContext context, bool open) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('texture_picker_search'),
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
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          key: const Key('texture_picker_upload'),
          onPressed: _startUpload,
          icon: const Icon(Icons.upload_file),
          label: Text(l10n.asset_textures_picker_upload),
        ),
        const SizedBox(width: 8),
        IconButton(
          key: const Key('texture_picker_preview_toggle'),
          isSelected: open,
          tooltip: open
              ? l10n.asset_textures_picker_preview_hide
              : l10n.asset_textures_picker_preview_show,
          onPressed: () => context.dispatch(ToggleTexturePreviewAction()),
          icon: const Icon(Icons.info_outline),
          selectedIcon: const Icon(Icons.info),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    bool open,
    List<AssetModel> uploaded,
    AssetModel? selected,
  ) {
    final l10n = context.l10n;
    final assets = _library.assets;
    if (assets.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (assets.loadError case final problem?) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.asset_picker_load_failed_texture),
            Text(problem.displayMessage),
            TextButton(
              onPressed: _library.load,
              child: Text(l10n.asset_picker_retry),
            ),
          ],
        ),
      );
    }
    if (uploaded.isEmpty) {
      return Center(
        child: Text(
          l10n.asset_picker_empty_texture,
          textAlign: TextAlign.center,
        ),
      );
    }
    final matching = _matching(uploaded);
    return LayoutBuilder(
      builder: (context, constraints) {
        final beside = constraints.maxWidth >= _besideFrom;
        final gridWidth = open && beside
            ? constraints.maxWidth - _previewWidth - 20
            : constraints.maxWidth;
        _reveal(matching, gridWidth);
        final grid = matching.isEmpty
            ? Center(child: Text(l10n.asset_picker_no_match))
            : _buildGrid(matching, selected);
        if (!open) return grid;
        final preview = _buildPreview(context, selected);
        if (beside) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: grid),
              const VerticalDivider(width: 20),
              SizedBox(width: _previewWidth, child: preview),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: grid),
            const Divider(height: 20),
            SizedBox(height: 200, child: preview),
          ],
        );
      },
    );
  }

  /// Scrolls the grid once to the texture selected on opening, the row it
  /// is in worked out from the columns of a grid [width] wide.
  void _reveal(List<AssetModel> matching, double width) {
    if (_revealed) return;
    final index = matching.indexWhere((texture) => texture.id == _selectedId);
    _revealed = true;
    if (index <= 0) return;
    final columns = math.max(1, (width / (_maxCardExtent + _spacing)).ceil());
    final offset = (index ~/ columns) * (_cardHeight + _spacing);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_grid.hasClients) return;
      _grid.jumpTo(math.min(offset, _grid.position.maxScrollExtent));
    });
  }

  Widget _buildGrid(List<AssetModel> matching, AssetModel? selected) {
    return GridView.builder(
      key: const Key('texture_picker_grid'),
      controller: _grid,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _maxCardExtent,
        mainAxisExtent: _cardHeight,
        crossAxisSpacing: _spacing,
        mainAxisSpacing: _spacing,
      ),
      itemCount: matching.length,
      itemBuilder: (context, index) {
        final texture = matching[index];
        return TextureCard(
          key: ValueKey('texture_${texture.id}'),
          texture: texture,
          usages: _library.usagesOf(texture),
          source: null,
          bytes: _library.thumbnailOf(texture),
          selected: texture.id == selected?.id,
          onTap: () => _tap(texture),
        );
      },
    );
  }

  Widget _buildPreview(BuildContext context, AssetModel? selected) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (selected == null) {
      return KeyedSubtree(
        key: const Key('texture_picker_preview'),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 48,
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      );
    }
    final size = switch ((selected.width, selected.height)) {
      (final width?, final height?) => '$width × $height',
      _ => null,
    };
    return SingleChildScrollView(
      key: const Key('texture_picker_preview'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextureDetail(
            key: ValueKey(selected.id),
            projectId: widget.projectId,
            texture: selected,
            usages: _library.usagesOf(selected),
            usagesFailed: _library.usagesFailed,
            onRetryUsages: _library.loadSources,
            loadContent: (projectId, _) =>
                _assetLibrary.contentOf(projectId, selected),
          ),
          if (size != null) ...[
            const SizedBox(height: 12),
            Text(
              size,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.tonalIcon(
              key: const Key('texture_picker_update'),
              onPressed: () => _startUpdate(selected),
              icon: const Icon(Icons.upload_outlined),
              label: Text(l10n.asset_textures_picker_update),
            ),
          ),
        ],
      ),
    );
  }
}
