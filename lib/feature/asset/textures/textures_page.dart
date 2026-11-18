
import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/search_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/loading/project_assets.dart';
import 'package:stelaris/feature/asset/asset_actions.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/textures/texture_card.dart';
import 'package:stelaris/feature/asset/textures/texture_detail.dart';
import 'package:stelaris/feature/asset/textures/texture_info_dialog.dart';
import 'package:stelaris/feature/asset/textures/texture_library.dart';
import 'package:stelaris/feature/asset/textures/texture_usage_sources.dart';
import 'package:stelaris/feature/asset/textures/texture_usages.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_dialog.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/feature/base/button/card_actions_menu.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/build/download/download_helper.dart'
    as download;
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/model/model_grid.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/bytes.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The insets of the other list pages (see `ModelPage`): the header sits
/// 12px below the top.
const EdgeInsets _pagePadding = EdgeInsets.fromLTRB(16, 12, 16, 0);

/// Shows the textures of the selected project as a grid of cards, filtered
/// by the AppBar search (name and key) and, on demand, to the unused ones.
///
/// A card opens the texture's info in a dialog; its menu holds the actions.
/// [pickFile] opens the file dialog
/// of the uploads and [saveFile] hands a download to the browser, both
/// injectable for tests.
class TexturesPage extends StatelessWidget {
  const TexturesPage({
    this.library,
    this.pickFile = pickAssetFile,
    this.saveFile = _saveInBrowser,
    this.loadUsageSources = loadTextureUsageSources,
    this.openLocation,
    super.key,
  });

  /// The asset library to load from, [AssetLibrary.shared] when null.
  final AssetLibrary? library;
  final Future<PickedAssetFile?> Function() pickFile;

  /// Saves the downloaded [bytes] of a texture as [fileName].
  final void Function(List<int> bytes, String fileName) saveFile;

  static void _saveInBrowser(List<int> bytes, String fileName) =>
      download.saveFile(asUint8List(bytes), fileName);

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
    required this.library,
    required this.pickFile,
    required this.saveFile,
    required this.loadUsageSources,
    required this.openLocation,
    super.key,
  });

  final String projectId;
  final String namespace;
  final AssetLibrary library;
  final Future<PickedAssetFile?> Function() pickFile;
  final void Function(List<int> bytes, String fileName) saveFile;
  final Future<TextureUsageSources> Function(String projectId) loadUsageSources;
  final ValueChanged<String> openLocation;

  @override
  State<_TexturesBody> createState() => _TexturesBodyState();
}

class _TexturesBodyState extends State<_TexturesBody> {
  late final TextureLibrary _library = TextureLibrary(
    library: widget.library,
    projectId: widget.projectId,
    loadUsageSources: widget.loadUsageSources,
    onReloadFailed: _showReloadFailure,
  );

  ProjectAssets get _assets => _library.assets;

  /// The AppBar search, as of the last build.
  String _query = '';

  /// Shows only the textures nothing uses, once that is known.
  bool _onlyUnused = false;

  @override
  void initState() {
    super.initState();
    _library.addListener(_onLibraryChanged);
    _load();
    // After the first frame: dispatching during initState would notify the
    // AppBar search mid-build. Also drops a search typed for another page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.dispatch(
        RegisterSearchFiltersAction(AssetNavigationEntry.textures, const []),
      );
    });
  }

  Future<void> _load() => _library.load();

  Future<void> _loadSources() => _library.loadSources();

  /// Where [texture] is used, null until everything it needs has loaded.
  TextureUsages? _usagesOf(AssetModel texture) => _library.usagesOf(texture);

  void _openModel(AssetModel model) => widget.openLocation(
    Uri(
      path: AssetNavigationEntry.models.route,
      queryParameters: {'id': model.id},
    ).toString(),
  );

  void _openFont(FontModel font) {
    if (!mounted) return;
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
    // The backend drops the texture from fonts; the store follows, so a
    // font saved later doesn't send the deleted id back.
    if (usages.fonts.isNotEmpty) {
      context.dispatch(TextureRemovedFromFontsAction(texture.id));
    }
    await _load();
  }

  /// Shows [texture] with where it is used.
  ///
  /// The dialog lives on the navigator, not in this page, so leaving the page
  /// (e.g. with the browser's back button) closes it, see [dispose].
  void _showInfo(AssetModel texture) => showDialog<void>(
    context: context,
    builder: (dialogContext) {
      _infoRoute = ModalRoute.of(dialogContext);
      return _infoDialog(texture);
    },
  );

  /// The route of the info dialog opened last; [dispose] closes it when it
  /// is still open.
  Route<void>? _infoRoute;

  Widget _infoDialog(AssetModel texture) => TextureInfoDialog(
    projectId: widget.projectId,
    texture: texture,
    changes: _library,
    usages: () => _usagesOf(texture),
    usagesFailed: () => _library.usagesFailed,
    onRetryUsages: _loadSources,
    source: _library.sourceOf(texture),
    loadContent: (projectId, _) =>
        widget.library.contentOf(projectId, texture),
    onOpenModel: _openModel,
    onOpenFont: _openFont,
  );

  /// The actions of [texture]'s card menu. An extracted texture belongs to
  /// its Blockbench model: no Update, no Delete. Delete stays disabled until
  /// the uses are known, so its dialog can name them.
  List<CardMenuEntry> _menuOf(AssetModel texture) {
    final l10n = context.l10n;
    final extracted = texture.sourceAssetId != null;
    final actions = AssetActions(
      model: texture,
      pickFile: widget.pickFile,
      saveFile: widget.saveFile,
      onChanged: _load,
      readOnly: extracted,
    );
    final usages = _usagesOf(texture);
    return [
      (
        icon: Icons.sticky_note_2_outlined,
        label: l10n.action_notes,
        onTap: () => actions.editNotes(context),
      ),
      (
        icon: Icons.info_outline,
        label: l10n.menu_item_info,
        onTap: () => actions.openInfo(context),
      ),
      (
        icon: Icons.history,
        label: l10n.asset_model_revisions,
        onTap: () => actions.openRevisions(context),
      ),
      if (!extracted)
        (
          icon: Icons.upload_outlined,
          label: l10n.asset_model_update,
          onTap: () => actions.update(context),
        ),
      (
        icon: Icons.download_outlined,
        label: l10n.button_download,
        onTap: () => actions.download(context),
      ),
      if (!extracted)
        (
          icon: Icons.delete_outline,
          label: l10n.asset_textures_delete,
          onTap: usages == null ? null : () => _delete(texture, usages),
        ),
    ];
  }

  @override
  void dispose() {
    // The navigator is locked while this page is torn down: close the info
    // dialog right after, before it can jump anywhere from a page that's gone.
    if (_infoRoute case final route? when route.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (route.isActive) route.navigator?.removeRoute(route);
      });
    }
    _library
      ..removeListener(_onLibraryChanged)
      ..dispose();
    super.dispose();
  }

  void _onLibraryChanged() {
    if (mounted) setState(() {});
  }

  void _showReloadFailure(ProblemDetail problem) {
    if (!mounted) return;
    // A failed reload keeps the list it would have replaced.
    ScaffoldMessenger.of(context)
        .showSnackBar(InfoBarFactory().createError(problem));
  }

  /// Whether the search or the Unused filter hides textures.
  bool get _filtered => _onlyUnused || _query.trim().isNotEmpty;

  /// The textures matching the search and the Unused filter, sorted by key
  /// like the models. Only the shown list is sorted: which of two textures
  /// with the same key models get still follows the backend's order.
  List<AssetModel> get _visible {
    final query = _query.trim().toLowerCase();
    return [
      for (final texture in _assets.textures)
        if ((!_onlyUnused || (_usagesOf(texture)?.isEmpty ?? false)) &&
            (query.isEmpty ||
                texture.displayName.toLowerCase().contains(query) ||
                texture.key.toLowerCase().contains(query)))
          texture,
    ]..sort(_byKey);
  }

  /// By key, then name and id, so textures with the same key keep one order.
  static int _byKey(AssetModel a, AssetModel b) {
    final byKey = a.key.compareTo(b.key);
    if (byKey != 0) return byKey;
    final byName = a.displayName.compareTo(b.displayName);
    return byName != 0 ? byName : a.id.compareTo(b.id);
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
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String>(
      converter: (store) => store.state.modelSearch.query,
      builder: (context, query) {
        _query = query;
        return _buildList();
      },
    );
  }

  Widget _buildList() {
    final l10n = context.l10n;
    final visible = _visible;
    final total = _assets.textures.length;
    // "3 of 12" while the search or the filter hides some.
    final count = _filtered
        ? l10n.asset_textures_count_filtered(visible.length, total)
        : '$total';
    return Padding(
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: _assets.listed
                ? '${l10n.asset_textures_title} ($count)'
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
          Expanded(child: _buildGrid(visible)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final l10n = context.l10n;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        FilterChip(
          key: const Key('textures_unused'),
          label: Text(l10n.asset_textures_unused_filter),
          selected: _onlyUnused,
          // Turned on once every use is known, so nothing in use shows up;
          // turning it off always works.
          onSelected:
              _onlyUnused || _library.usagesLoaded
              ? (selected) => setState(() => _onlyUnused = selected)
              : null,
        ),
        // Without the uses the Unused filter and Delete stay off; this says
        // why and loads them again.
        if (_library.usagesFailed)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 18,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 6),
              Text(l10n.asset_textures_usages_failed_short),
              TextButton(
                key: const Key('textures_usages_retry'),
                onPressed: _loadSources,
                child: Text(l10n.asset_textures_usages_retry),
              ),
            ],
          ),
      ],
    );
  }

  /// Lower than on the other list pages, a texture card has no notes line.
  static const double _cardHeight = 132;

  Widget _buildGrid(List<AssetModel> visible) {
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
    if (visible.isEmpty) {
      // Only the Unused filter hides them: there is no search to blame.
      final everyUsed = _onlyUnused && _query.trim().isEmpty;
      return Center(
        child: Text(
          everyUsed
              ? l10n.asset_textures_none_unused
              : l10n.asset_textures_no_matches,
        ),
      );
    }
    return ModelGrid<AssetModel>(
      key: const Key('textures_grid'),
      items: visible,
      cardHeight: _cardHeight,
      itemBuilder: (context, texture) => TextureCard(
        key: ValueKey('texture_${texture.id}'),
        texture: texture,
        source: _library.sourceOf(texture),
        usages: _usagesOf(texture),
        bytes: _library.thumbnailOf(texture),
        menu: _menuOf(texture),
        onTap: () => _showInfo(texture),
      ),
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
