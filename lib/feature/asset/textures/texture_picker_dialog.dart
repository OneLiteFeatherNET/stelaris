import 'dart:async';
import 'dart:math' as math;

import 'package:async_redux/async_redux.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/actions/app_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/picker/asset_key.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/feature/asset/textures/texture_card.dart';
import 'package:stelaris/feature/asset/textures/texture_detail.dart';
import 'package:stelaris/feature/asset/textures/texture_library.dart';
import 'package:stelaris/feature/asset/textures/texture_usage_sources.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_controller.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_form.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/feature/base/search/dialog_search_bar.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
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
const double _maxCardExtent = 200;

/// The height of a card, the compact one of [TextureCard].
const double _cardHeight = TextureCard.compactHeight;

/// The space between two cards, across and down.
const double _spacing = 12;

/// The width of the preview beside the grid.
const double _previewWidth = 280;

/// From this width on the preview sits beside the grid, below it before.
const double _besideFrom = 720;

/// The share of the window the dialog takes at most, so a larger window
/// shows more rows.
const double _heightShare = 0.85;

/// The height of the dialog around its content: title, bar and buttons.
const double _chromeHeight = 260;

/// The lowest the content gets, on a small window.
const double _minContentHeight = 300;

/// What the dialog shows: the grid, the upload of a new texture or a new
/// version of the selected one. The steps swap the content of the dialog.
enum _Step { choose, upload, update }

class _TexturePickerState extends State<TexturePicker> {
  late final AssetLibrary _assetLibrary = widget.library ?? AssetLibrary.shared;
  late final TextureLibrary _library = TextureLibrary(
    library: _assetLibrary,
    projectId: widget.projectId,
    loadUsageSources: widget.loadUsageSources,
    onReloadFailed: _showReloadFailure,
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

  _Step _step = _Step.choose;

  /// The upload of the current step, null while choosing.
  AssetUploadController? _upload;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
    _library.addListener(_onLibraryChanged);
    _library.load();
  }

  @override
  void dispose() {
    _armTimer?.cancel();
    _upload?.dispose();
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

  /// Called on a changed text only, not when the cursor moves.
  void _onSearchChanged(String _) => setState(() {});

  void _clearSearch() {
    _search.clear();
    _onSearchChanged('');
  }

  /// A failed reload, e.g. after an upload, keeps the grid it would have
  /// replaced.
  void _showReloadFailure(ProblemDetail problem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(InfoBarFactory().createError(problem));
  }

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

  void _startUpload() => setState(() {
    _upload = AssetUploadController(
      projectId: widget.projectId,
      namespace: widget.namespace,
      pickFile: widget.pickFile,
      kinds: const {AssetKind.TEXTURE},
      keyFolder: widget.keyFolder,
    );
    _step = _Step.upload;
  });

  void _startUpdate(AssetModel texture) => setState(() {
    _upload = AssetUploadController(
      projectId: widget.projectId,
      namespace: widget.namespace,
      pickFile: widget.pickFile,
      kinds: const {AssetKind.TEXTURE},
      replaces: texture,
    );
    _step = _Step.update;
  });

  /// Goes back to the grid, unless an upload runs. After a conflict the
  /// textures are loaded again, so the stored version shows.
  void _back() {
    final upload = _upload;
    if (upload == null || upload.uploading) return;
    // The form still listens to the controller until it is gone.
    WidgetsBinding.instance.addPostFrameCallback((_) => upload.dispose());
    setState(() {
      _upload = null;
      _step = _Step.choose;
    });
    if (upload.conflict) _library.load();
  }

  /// Stores the new texture, selects it and shows it in the grid.
  Future<void> _submitUpload() async {
    final upload = _upload;
    if (upload == null || !upload.canUpload) return;
    final texture = await upload.upload();
    if (texture == null || !mounted) return;
    _selectedId = texture.id;
    _revealed = false;
    _back();
    await _library.load();
  }

  /// Stores the new version and goes back to the grid with it selected.
  Future<void> _submitUpdate() async {
    final upload = _upload;
    if (upload == null || !upload.canUpload) return;
    final texture = await upload.upload();
    if (texture == null || !mounted) return;
    widget.onUpdated?.call(texture);
    _back();
    await _library.load();
  }

  @override
  Widget build(BuildContext context) {
    final upload = _upload;
    // Escape and a tap beside the dialog go back from a step, as its back
    // button does; while choosing they close the dialog.
    return PopScope(
      canPop: upload == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: switch ((_step, upload)) {
        (_Step.upload, final upload?) => ListenableBuilder(
          listenable: upload,
          builder: (context, _) => _buildUpload(context, upload),
        ),
        (_Step.update, final upload?) => ListenableBuilder(
          listenable: upload,
          builder: (context, _) => _buildUpdate(context, upload),
        ),
        _ => StoreConnector<AppState, bool>(
          converter: (store) => store.state.openTexturePreview,
          builder: (context, open) => _buildChoose(context, open),
        ),
      },
    );
  }

  Widget _backButton(BuildContext context, AssetUploadController upload) =>
      IconButton(
        key: const Key('texture_picker_back'),
        tooltip: context.l10n.asset_picker_back,
        onPressed: upload.uploading ? null : _back,
        icon: const Icon(Icons.arrow_back),
      );

  Widget _buildUpload(BuildContext context, AssetUploadController upload) {
    final l10n = context.l10n;
    return FormDialog(
      title: l10n.asset_textures_upload_title,
      leading: _backButton(context, upload),
      onCancel: upload.uploading ? null : _back,
      actionLabel: l10n.asset_picker_upload_action,
      actionIcon: Icons.upload,
      maxWidth: 560,
      busy: upload.uploading,
      onSubmit: upload.canUpload ? _submitUpload : null,
      content: AssetUploadForm(controller: upload, onSubmitted: _submitUpload),
    );
  }

  Widget _buildUpdate(BuildContext context, AssetUploadController upload) {
    final l10n = context.l10n;
    final texture = upload.replaces!;
    final otherUses = _otherUses(context, texture);
    return FormDialog(
      title: l10n.asset_upload_replace_title(texture.displayName),
      leading: _backButton(context, upload),
      onCancel: upload.uploading ? null : _back,
      actionLabel: l10n.asset_model_update,
      actionIcon: Icons.upload,
      maxWidth: 640,
      busy: upload.uploading,
      onSubmit: upload.canUpload ? _submitUpdate : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (otherUses != null) ...[otherUses, const SizedBox(height: 16)],
          AssetUploadForm(
            controller: upload,
            onSubmitted: _submitUpdate,
            currentPreview: TexturePreview(
              projectId: widget.projectId,
              asset: texture,
              loadContent: (projectId, _) =>
                  _assetLibrary.contentOf(projectId, texture),
            ),
          ),
        ],
      ),
    );
  }

  /// Where else [texture] is used, which the new version changes too; the
  /// font it is chosen for is left out. Null when nothing else uses it.
  Widget? _otherUses(BuildContext context, AssetModel texture) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (_library.usagesFailed) {
      return Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
          const SizedBox(width: 6),
          Flexible(child: Text(l10n.asset_textures_usages_failed_short)),
          TextButton(
            onPressed: _library.loadSources,
            child: Text(l10n.asset_textures_usages_retry),
          ),
        ],
      );
    }
    final usages = _library.usagesOf(texture);
    if (usages == null) {
      return const Align(
        key: Key('texture_picker_uses_loading'),
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    final names = [
      for (final model in usages.models) model.displayName,
      for (final font in usages.fonts)
        if (font.id != widget.currentFontId) font.uiName,
      for (final type in usages.packIcons) packIconLabel(l10n, type),
    ];
    if (names.isEmpty) return null;
    return NoticeBox(
      key: const Key('texture_picker_also_used'),
      icon: Icons.warning_amber_outlined,
      content: Text(l10n.asset_textures_picker_also_used(names.join(', '))),
    );
  }

  Widget _buildChoose(BuildContext context, bool open) {
    final l10n = context.l10n;
    final uploaded = _uploaded;
    final selected = _selectedIn(uploaded);
    final maxHeight = MediaQuery.sizeOf(context).height * _heightShare;
    // Fixed, so the dialog keeps its height while the search narrows the
    // grid down.
    final contentHeight = math.max(
      _minContentHeight,
      maxHeight - _chromeHeight,
    );
    return FormDialog(
      title: l10n.asset_picker_title_texture,
      maxWidth: 900,
      maxHeight: maxHeight,
      titleActions: _titleActions(context, open),
      header: _buildSearch(context),
      onCancel: widget.onCancel,
      actionLabel: l10n.asset_picker_choose,
      onSubmit: selected == null ? null : () => widget.onPicked(selected),
      content: SizedBox(
        height: contentHeight,
        child: _buildBody(context, open, uploaded, selected),
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    final l10n = context.l10n;
    return DialogSearchBar(
      key: const Key('texture_picker_search'),
      controller: _search,
      hintText: l10n.asset_picker_search,
      trailing: [
        if (_search.text.isNotEmpty)
          IconButton(
            tooltip: l10n.asset_picker_search_clear,
            onPressed: _clearSearch,
            icon: const Icon(Icons.close),
          ),
      ],
      onChanged: _onSearchChanged,
    );
  }

  List<Widget> _titleActions(BuildContext context, bool open) {
    final l10n = context.l10n;
    return [
      IconButton(
        key: const Key('texture_picker_upload'),
        tooltip: l10n.asset_textures_picker_upload,
        onPressed: _startUpload,
        icon: const Icon(Icons.upload_file),
      ),
      IconButton(
        key: const Key('texture_picker_preview_toggle'),
        tooltip: open
            ? l10n.asset_textures_picker_preview_hide
            : l10n.asset_textures_picker_preview_show,
        isSelected: open,
        onPressed: () => context.dispatch(ToggleTexturePreviewAction()),
        icon: const Icon(Icons.view_sidebar_outlined),
        selectedIcon: const Icon(Icons.view_sidebar),
      ),
    ];
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
    // Not listed yet, e.g. a new texture before the list is loaded again.
    if (index < 0) return;
    _revealed = true;
    if (index == 0) return;
    final columns = math.max(1, (width / (_maxCardExtent + _spacing)).ceil());
    final offset = (index ~/ columns) * (_cardHeight + _spacing);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_grid.hasClients) return;
      // Not clamped to the max extent: until the grid has built its end
      // that is only an estimate. A jump past the end settles at the end.
      _grid.jumpTo(offset);
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
          compact: true,
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
            color: theme.colorScheme.onSurfaceVariant,
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
            // A new version shows its own file.
            key: ValueKey('${selected.id}/${selected.sha1}'),
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
