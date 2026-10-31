import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/actions/asset_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/asset_kind_label.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/models/flat_item_model.dart';
import 'package:stelaris/feature/asset/models/model_detail.dart';
import 'package:stelaris/feature/asset/models/model_textures.dart';
import 'package:stelaris/feature/asset/models/model_usage.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/asset/upload/asset_upload_dialog.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/build/download/download_helper.dart';
import 'package:stelaris/feature/dialogs/model_info_dialog.dart';
import 'package:stelaris/feature/dialogs/notes_edit_dialog.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/model/model_card_frame.dart';
import 'package:stelaris/feature/model/model_grid.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/notes.dart';
import 'package:stelaris/util/relative_time.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Shows the models of the selected project as a grid of cards with how many
/// of their textures are missing, and the selected model's detail in place
/// of the grid.
///
/// The selection is [selectedId]; the page reports a new one through
/// [onSelected], so the route can keep it. [pickFile] opens the file dialog
/// of the uploads and [saveFile] hands a download to the browser, both
/// injectable for tests.
class ModelsPage extends StatelessWidget {
  const ModelsPage({
    this.selectedId,
    this.onSelected,
    this.library,
    this.pickFile = pickAssetFile,
    this.saveFile = _saveInBrowser,
    this.loadUsages = _loadUsages,
    super.key,
  });

  final String? selectedId;
  final ValueChanged<String?>? onSelected;

  /// The asset library to load from, [AssetLibrary.shared] when null.
  final AssetLibrary? library;
  final Future<PickedAssetFile?> Function() pickFile;

  /// Saves the downloaded [bytes] of a model as [fileName].
  final void Function(List<int> bytes, String fileName) saveFile;

  static void _saveInBrowser(List<int> bytes, String fileName) =>
      triggerBrowserDownload(base64Encode(bytes), fileName);

  /// Loads the items of a project with their components, for "used by".
  final Future<Map<ItemModel, List<ItemComponentDto>>> Function(
    String projectId,
  )
  loadUsages;

  static Future<Map<ItemModel, List<ItemComponentDto>>> _loadUsages(
    String projectId,
  ) => loadItemComponents(ApiService().itemApi, projectId);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectView>(
      vm: () => _ProjectFactory(),
      builder: (context, vm) {
        final project = vm.project;
        if (project == null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader.small(title: context.l10n.asset_models_title),
                Expanded(
                  child: Center(
                    child: Text(context.l10n.asset_models_no_project),
                  ),
                ),
              ],
            ),
          );
        }
        return _ModelsBody(
          key: ValueKey(project.id),
          projectId: project.id,
          namespace: project.key,
          selectedId: selectedId,
          onSelected: onSelected,
          library: library ?? AssetLibrary.shared,
          pickFile: pickFile,
          saveFile: saveFile,
          loadUsages: loadUsages,
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

class _ProjectFactory extends VmFactory<AppState, ModelsPage, _ProjectView> {
  @override
  _ProjectView fromStore() => _ProjectView(
    project: switch (state.selectedProject) {
      Project(id: final id?, :final key) => (id: id, key: key),
      _ => null,
    },
  );
}

class _ModelsBody extends StatefulWidget {
  const _ModelsBody({
    required this.projectId,
    required this.namespace,
    required this.selectedId,
    required this.onSelected,
    required this.library,
    required this.pickFile,
    required this.saveFile,
    required this.loadUsages,
    super.key,
  });

  final String projectId;
  final String namespace;
  final String? selectedId;
  final ValueChanged<String?>? onSelected;
  final AssetLibrary library;
  final Future<PickedAssetFile?> Function() pickFile;
  final void Function(List<int> bytes, String fileName) saveFile;
  final Future<Map<ItemModel, List<ItemComponentDto>>> Function(
    String projectId,
  )
  loadUsages;

  @override
  State<_ModelsBody> createState() => _ModelsBodyState();
}

class _ModelsBodyState extends State<_ModelsBody> {
  List<AssetModel> _models = const [];
  List<AssetModel> _textures = const [];

  /// The texture keys of every model JSON read so far. Filled after the list
  /// is shown, so the badges come in a moment later.
  Map<AssetModel, Set<String>> _references = const {};

  /// The items with their components, loaded once a detail asks for them.
  Future<Map<ItemModel, List<ItemComponentDto>>>? _usages;

  /// The items using each model key, so a rebuild keeps the same future.
  final Map<String, Future<List<ItemModel>>> _usedBy = {};

  late String? _selectedId = widget.selectedId;
  bool _loading = true;
  ProblemDetail? _loadError;

  /// Whether the list was loaded once, so a reload keeps it on screen.
  bool _listed = false;

  /// Counts the loads, so a load that ends after a newer one is ignored.
  int _loadId = 0;

  /// Reloads when the app resumes, e.g. when the browser tab regains focus,
  /// so assets saved elsewhere are counted.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _load);
    _load();
  }

  @override
  void didUpdateWidget(_ModelsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      _selectedId = widget.selectedId;
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final loadId = ++_loadId;
    _usages = null;
    _usedBy.clear();
    final library = widget.library;
    final projectId = widget.projectId;
    if (!_listed) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    final List<List<AssetModel>> lists;
    try {
      lists = await Future.wait([
        library.assetsOf(projectId, AssetKind.MODEL),
        library.assetsOf(projectId, AssetKind.BBMODEL),
        library.assetsOf(projectId, AssetKind.TEXTURE),
      ]);
    } on DioException catch (error) {
      if (!mounted || loadId != _loadId) return;
      final problem = ProblemDetail.fromDioException(error);
      if (_listed) {
        // A failed reload keeps the list it would have replaced.
        ScaffoldMessenger.of(context)
            .showSnackBar(InfoBarFactory().createError(problem));
      }
      setState(() {
        _loading = false;
        if (!_listed) _loadError = problem;
      });
      return;
    }
    if (!mounted || loadId != _loadId) return;
    final models = [...lists[0], ...lists[1]]
      ..sort((a, b) => a.key.compareTo(b.key));
    setState(() {
      _models = models;
      _textures = lists[2];
      _loading = false;
      _listed = true;
    });

    final references = <AssetModel, Set<String>>{};
    for (final model in models) {
      if (model.kind != AssetKind.MODEL) continue;
      try {
        references[model] = await library.textureKeysOf(projectId, model);
      } on Object {
        // A file that can't be read has no textures to count; its preview
        // says what is wrong.
      }
    }
    if (!mounted || loadId != _loadId) return;
    setState(() => _references = references);
  }

  ModelTextures _texturesOf(AssetModel model) =>
      modelTextures(model, references: _references, textures: _textures);

  Future<List<ItemModel>> _usedByOf(AssetModel model) =>
      _usedBy.putIfAbsent(model.key, () async {
        final usages = _usages ??= widget.loadUsages(widget.projectId);
        return usedBy(model.key, await usages);
      });

  void _openItem(ItemModel item) {
    context.dispatch(SelectedItemAction(item));
    context.go(detailLocation(NavigationEntry.items.route));
  }

  void _select(String? id) {
    setState(() => _selectedId = id);
    widget.onSelected?.call(id);
  }

  Future<void> _upload() async {
    final asset = await showDialog<AssetModel>(
      context: context,
      builder: (context) => AssetUploadDialog(
        projectId: widget.projectId,
        namespace: widget.namespace,
        title: context.l10n.asset_models_upload_title,
        pickFile: widget.pickFile,
        kinds: const {AssetKind.MODEL, AssetKind.BBMODEL},
      ),
    );
    if (asset == null || !mounted) return;
    await _load();
    if (!mounted) return;
    _select(asset.id);
  }

  /// Uploads a texture and the flat item model drawing it, under one key and
  /// one name.
  ///
  /// When the model can't be stored the texture stays, so a retry only needs
  /// the model.
  Future<void> _newFromTexture() async {
    final texture = await showDialog<AssetModel>(
      context: context,
      builder: (context) => AssetUploadDialog(
        projectId: widget.projectId,
        namespace: widget.namespace,
        title: context.l10n.asset_models_from_texture_title,
        pickFile: widget.pickFile,
        kinds: const {AssetKind.TEXTURE},
      ),
    );
    if (texture == null || !mounted) return;
    final file = flatItemModel(texture.key);
    final AssetModel model;
    try {
      model = await ApiService().assetApi.upload(
        widget.projectId,
        key: texture.key,
        displayName: texture.displayName,
        fileName: file.fileName,
        bytes: file.bytes,
      );
    } on DioException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        InfoBarFactory().createError(ProblemDetail.fromDioException(error)),
      );
      await _load();
      return;
    }
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    _select(model.id);
  }

  /// Uploads the missing texture of [slot] under the key the model refers to.
  Future<void> _uploadTexture(TextureSlot slot) async {
    final asset = await showDialog<AssetModel>(
      context: context,
      builder: (context) => AssetUploadDialog(
        projectId: widget.projectId,
        namespace: widget.namespace,
        title: context.l10n.asset_model_texture_upload_title,
        pickFile: widget.pickFile,
        kinds: const {AssetKind.TEXTURE},
        fixedKey: slot.key,
      ),
    );
    if (asset == null || !mounted) return;
    await _load();
  }

  AssetModel? get _selected {
    for (final model in _models) {
      if (model.id == _selectedId) return model;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Builder(
        builder: (context) {
          // Like the other list pages: a grid of cards, and a model opens
          // in place of it under a detail page's header.
          if (selected != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: selected.displayName,
                  onBack: () => _select(null),
                  compactBelow: PageHeader.detailCompactThreshold,
                  actions: [
                    _notesAction(selected),
                    PageHeaderAction(
                      key: const Key('model_info'),
                      icon: const Icon(Icons.info_outline),
                      label: context.l10n.menu_item_info,
                      onPressed: () => _openInfo(selected),
                    ),
                    // The main action here, as saving is on other detail pages.
                    PageHeaderAction(
                      key: const Key('model_download'),
                      icon: const Icon(Icons.download_outlined),
                      label: context.l10n.button_download,
                      primary: true,
                      onPressed: () => _download(selected),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(child: _buildDetail(selected)),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader.small(
                title: context.l10n.asset_models_title,
                actions: [
                  PageHeaderAction(
                    key: const Key('models_from_texture'),
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: context.l10n.asset_models_from_texture,
                    onPressed: _newFromTexture,
                  ),
                  PageHeaderAction(
                    key: const Key('models_upload'),
                    icon: const Icon(Icons.upload_file),
                    label: context.l10n.asset_picker_upload_action,
                    primary: true,
                    onPressed: _upload,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildGrid()),
            ],
          );
        },
      ),
    );
  }

  /// Opens the notes of [model] for editing. Unlike the other detail pages,
  /// which only show them, because a model card has no menu to edit them.
  Widget _notesAction(AssetModel model) {
    final l10n = context.l10n;
    final hasNotes = notesSummary(model.comment) != null;
    return PageHeaderAction(
      key: const Key('model_notes'),
      icon: Badge(
        isLabelVisible: hasNotes,
        smallSize: 8,
        child: Icon(
          hasNotes ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined,
          semanticLabel: hasNotes ? l10n.tooltip_notes_present : null,
        ),
      ),
      label: l10n.action_notes,
      onPressed: () => _editNotes(model),
    );
  }

  Future<void> _editNotes(AssetModel model) async {
    await showDialog<void>(
      context: context,
      builder: (_) => NotesEditDialog(
        name: model.displayName,
        notes: model.comment,
        saveAction: (notes) => AssetNotesUpdateAction(model, notes),
      ),
    );
    if (!mounted) return;
    await _load();
  }

  void _openInfo(AssetModel model) => showDialog<void>(
    context: context,
    builder: (_) => ModelInfoDialog(
      name: model.displayName,
      namespacedKey: model.key,
      id: model.id,
      creationDate: model.creationDate,
      modificationDate: model.modificationDate,
    ),
  );

  /// Downloads the stored file of [model] under its file name.
  Future<void> _download(AssetModel model) async {
    final List<int> bytes;
    try {
      bytes = await ApiService().assetApi.content(widget.projectId, model.id);
    } on DioException catch (error) {
      if (!mounted) return;
      context.showErrorSnackBar(error);
      return;
    }
    widget.saveFile(bytes, model.fileName);
  }

  Widget _buildDetail(AssetModel model) => SingleChildScrollView(
    child: ModelDetail(
      key: ValueKey(model.id),
      projectId: widget.projectId,
      model: model,
      textures: _texturesOf(model),
      usedBy: _usedByOf(model),
      onOpenItem: _openItem,
      onUploadTexture: _uploadTexture,
    ),
  );

  /// Lower than on the other list pages, a model card has no notes line.
  static const double _cardHeight = 132;

  Widget _buildGrid() {
    final l10n = context.l10n;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError case final problem?) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.asset_models_load_failed),
            Text(problem.displayMessage),
            TextButton(onPressed: _load, child: Text(l10n.asset_picker_retry)),
          ],
        ),
      );
    }
    if (_models.isEmpty) {
      return Center(
        child: Text(l10n.asset_models_empty, textAlign: TextAlign.center),
      );
    }
    return ModelGrid<AssetModel>(
      key: const Key('models_grid'),
      items: _models,
      cardHeight: _cardHeight,
      itemBuilder: (context, model) => _ModelCard(
        key: ValueKey('model_${model.id}'),
        model: model,
        missing: _texturesOf(model).missingCount,
        onTap: () => _select(model.id),
      ),
    );
  }
}

/// One model of the grid in the frame of the other list pages' cards: its
/// name and key, a warning when it misses textures, and a footer with its
/// kind and last change.
class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.model,
    required this.missing,
    required this.onTap,
    super.key,
  });

  final AssetModel model;
  final int missing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final date = model.modificationDate ?? model.creationDate;
    return ModelCardFrame(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            model.displayName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // The key already carries the namespace, so no ModelCardContent.
          InfoChip(icon: Icons.vpn_key_outlined, text: model.key),
        ],
      ),
      trailing: missing == 0
          ? null
          : Tooltip(
              message: l10n.asset_models_missing_tooltip(missing),
              child: Icon(
                Icons.warning_amber_rounded,
                key: ValueKey('model_missing_${model.id}'),
                color: colorScheme.error,
              ),
            ),
      footerIcon: assetKindIcon(model.kind),
      footerText: [
        assetKindLabel(l10n, model.kind),
        if (date != null) relativeTime(context, date),
      ].join(' · '),
      onTap: onTap,
    );
  }
}
