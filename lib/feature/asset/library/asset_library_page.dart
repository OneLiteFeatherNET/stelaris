import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/item_model_asset_preview.dart';
import 'package:stelaris/feature/asset/picker/asset_key.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Lists the assets of the selected project that have one of [kinds], with an
/// upload in the header and a preview of the selected asset beside the list.
///
/// Models are shown in 3D, textures as a pixel-sharp image. [pickFile] opens
/// the file dialog of the upload, injectable for tests.
class AssetLibraryPage extends StatelessWidget {
  const AssetLibraryPage({
    required this.kinds,
    required this.title,
    this.pickFile = pickAssetFile,
    super.key,
  });

  final Set<AssetKind> kinds;
  final String title;
  final Future<PickedAssetFile?> Function() pickFile;

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
                PageHeader.small(title: title),
                Expanded(
                  child: Center(
                    child: Text(context.l10n.asset_library_no_project),
                  ),
                ),
              ],
            ),
          );
        }
        return _AssetLibraryBody(
          projectId: project.id,
          namespace: project.key,
          kinds: kinds,
          title: title,
          pickFile: pickFile,
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

class _ProjectFactory
    extends VmFactory<AppState, AssetLibraryPage, _ProjectView> {
  @override
  _ProjectView fromStore() => _ProjectView(
    project: switch (state.selectedProject) {
      Project(id: final id?, :final key) => (id: id, key: key),
      _ => null,
    },
  );
}

List<AssetModel> _sortedByKey(Iterable<AssetModel> assets) =>
    [...assets]..sort((a, b) => a.key.compareTo(b.key));

class _AssetLibraryBody extends StatefulWidget {
  const _AssetLibraryBody({
    required this.projectId,
    required this.namespace,
    required this.kinds,
    required this.title,
    required this.pickFile,
  });

  final String projectId;

  /// The project key, which the suggested keys of uploads start with.
  final String namespace;
  final Set<AssetKind> kinds;
  final String title;
  final Future<PickedAssetFile?> Function() pickFile;

  @override
  State<_AssetLibraryBody> createState() => _AssetLibraryBodyState();
}

class _AssetLibraryBodyState extends State<_AssetLibraryBody> {
  static const int _pageSize = 50;

  /// From this width on there is room for the preview next to the list.
  static const double _previewBreakpoint = 840;

  /// Whether the preview is shown next to the list. Not kept across app
  /// starts, the app doesn't store settings locally yet.
  bool _showPreview = true;

  List<AssetModel> _assets = const [];
  AssetModel? _selected;
  bool _loading = true;
  ProblemDetail? _loadError;

  /// Counts the loads, so a load that ends after a newer one started is
  /// ignored.
  int _loadId = 0;

  /// Reloads the list when the app resumes, e.g. when the browser tab regains
  /// focus, so an asset saved elsewhere shows up.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _load);
    _load();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_AssetLibraryBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        !oldWidget.kinds.containsAll(widget.kinds) ||
        oldWidget.kinds.length != widget.kinds.length) {
      _selected = null;
      _load();
    }
  }

  Future<void> _load() async {
    final loadId = ++_loadId;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final lists = await Future.wait([
        for (final kind in widget.kinds) _fetchAll(kind),
      ]);
      if (!mounted || loadId != _loadId) return;
      final assets = _sortedByKey(lists.expand((list) => list));
      setState(() {
        _assets = assets;
        _selected = _sameAsset(assets, _selected);
        _loading = false;
      });
    } on DioException catch (error) {
      if (!mounted || loadId != _loadId) return;
      setState(() {
        _loadError = ProblemDetail.fromDioException(error);
        _loading = false;
      });
    }
  }

  /// Every page of [kind], one request per page.
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

  /// The listed asset with the key and kind of [asset], so the selection
  /// follows a reload, null when the asset is gone.
  static AssetModel? _sameAsset(List<AssetModel> assets, AssetModel? asset) {
    if (asset == null) return null;
    for (final listed in assets) {
      if (listed.key == asset.key && listed.kind == asset.kind) return listed;
    }
    return null;
  }

  Future<void> _upload() async {
    final asset = await showDialog<AssetModel>(
      context: context,
      builder: (_) => _AssetUploadDialog(
        projectId: widget.projectId,
        namespace: widget.namespace,
        pickFile: widget.pickFile,
      ),
    );
    if (asset == null || !mounted) return;
    if (!widget.kinds.contains(asset.kind)) {
      // Textures uploaded here are listed on the other page.
      ScaffoldMessenger.of(context).showSnackBar(
        InfoBarFactory().create(
          context.l10n.asset_library_uploaded_elsewhere(asset.key),
        ),
      );
      return;
    }
    await _load();
    if (!mounted) return;
    setState(() => _selected = asset);
  }

  /// The preview of [asset]: models in 3D, textures as the image itself.
  Widget _previewOf(AssetModel asset) => switch (asset.kind) {
    AssetKind.TEXTURE => _TexturePreview(
      key: ValueKey(asset.id),
      projectId: widget.projectId,
      asset: asset,
    ),
    _ => ItemModelPreview(
      key: ValueKey(asset.id),
      projectId: widget.projectId,
      asset: asset,
    ),
  };

  /// Without room next to the list, the preview opens as a bottom sheet.
  void _openPreviewSheet(AssetModel asset) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: 420,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: _previewOf(asset),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _previewBreakpoint;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader.small(
                title: widget.title,
                actions: [
                  _PreviewButton(
                    wide: wide,
                    shown: _showPreview,
                    onPressed: selected == null
                        ? null
                        : () => wide
                              ? setState(() => _showPreview = !_showPreview)
                              : _openPreviewSheet(selected),
                  ),
                  _UploadButton(onPressed: _upload),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildList()),
                    // Slides and fades in from the right edge, the list gives way.
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        // Top, the transition fills the height and would center it.
                        alignment: AlignmentDirectional.topStart,
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: wide && _showPreview && selected != null
                          ? Padding(
                              key: const ValueKey('asset_library_preview_slot'),
                              padding: const EdgeInsets.only(left: 16),
                              child: SizedBox(
                                width: (constraints.maxWidth * 0.35).clamp(
                                  280,
                                  420,
                                ),
                                child: _previewOf(selected),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList() {
    final l10n = context.l10n;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError case final problem?) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.asset_library_load_failed),
            Text(problem.displayMessage, style: _errorStyle(context)),
            TextButton(onPressed: _load, child: Text(l10n.asset_picker_retry)),
          ],
        ),
      );
    }
    if (_assets.isEmpty) {
      return Center(child: Text(l10n.asset_library_empty));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 96,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        return _AssetTile(
          key: ValueKey(asset.id),
          asset: asset,
          selected: asset.id == _selected?.id,
          onTap: () => setState(() => _selected = asset),
        );
      },
    );
  }

  TextStyle? _errorStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.error);
}

/// Shows and hides the preview next to the list, or opens it as a bottom
/// sheet when there is no room for it.
class _PreviewButton extends StatelessWidget {
  const _PreviewButton({
    required this.wide,
    required this.shown,
    required this.onPressed,
  });

  final bool wide;
  final bool shown;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PageHeaderAction(
      key: const Key('asset_library_preview_toggle'),
      // The icon tells what a press does.
      icon: Icon(
        wide && shown
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
      ),
      label: context.l10n.lore_preview_title,
      onPressed: onPressed,
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PageHeaderAction(
      key: const Key('asset_library_upload'),
      icon: const Icon(Icons.upload_file),
      label: context.l10n.asset_picker_upload_action,
      primary: true,
      onPressed: onPressed,
    );
  }
}

/// One asset of the list: its key and its kind, highlighted when selected.
class _AssetTile extends StatelessWidget {
  const _AssetTile({
    required this.asset,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final AssetModel asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card.outlined(
      color: selected ? colorScheme.secondaryContainer : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(_kindIcon(asset.kind), color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _kindLabel(l10n, asset.kind),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _kindIcon(AssetKind kind) => switch (kind) {
    AssetKind.TEXTURE => Icons.image_outlined,
    AssetKind.BBMODEL => Icons.view_in_ar,
    AssetKind.MODEL => Icons.category_outlined,
  };

  static String _kindLabel(AppLocalizations l10n, AssetKind kind) =>
      switch (kind) {
        AssetKind.TEXTURE => l10n.asset_library_kind_texture,
        AssetKind.BBMODEL => l10n.asset_picker_kind_bbmodel,
        AssetKind.MODEL => l10n.asset_picker_kind_model,
      };
}

/// Shows a texture on the preview surface, scaled up to fit and kept
/// pixel-sharp.
class _TexturePreview extends StatefulWidget {
  const _TexturePreview({
    required this.projectId,
    required this.asset,
    super.key,
  });

  final String projectId;
  final AssetModel asset;

  @override
  State<_TexturePreview> createState() => _TexturePreviewState();
}

class _TexturePreviewState extends State<_TexturePreview> {
  late final Future<List<int>> _bytes = ApiService().assetApi.content(
    widget.projectId,
    widget.asset.id,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.preview_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.lore_preview_title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            key: const Key('asset_library_texture_preview'),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: previewBackground,
              borderRadius: BorderRadius.circular(AppShapes.extraSmall),
              border: Border.all(color: previewBorder),
            ),
            child: FutureBuilder<List<int>>(
              future: _bytes,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      l10n.asset_preview_failed,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final bytes = snapshot.data;
                if (bytes == null) {
                  return const Center(
                    child: SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.memory(
                    Uint8List.fromList(bytes),
                    fit: BoxFit.contain,
                    // Nearest neighbour when scaled up, so the pixels stay sharp.
                    filterQuality: FilterQuality.none,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Picks a file, suggests its key and uploads it. A rejected upload keeps the
/// dialog open and shows the reasons under the field they name.
class _AssetUploadDialog extends StatefulWidget {
  const _AssetUploadDialog({
    required this.projectId,
    required this.namespace,
    required this.pickFile,
  });

  final String projectId;
  final String namespace;
  final Future<PickedAssetFile?> Function() pickFile;

  @override
  State<_AssetUploadDialog> createState() => _AssetUploadDialogState();
}

class _AssetUploadDialogState extends State<_AssetUploadDialog> {
  final TextEditingController _keyController = TextEditingController();

  PickedAssetFile? _pending;
  bool _uploading = false;
  String? _keyError;
  String? _fileError;
  String? _uploadError;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
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
      setState(() => _uploading = false);
      Navigator.of(context).pop(asset);
    } on DioException catch (error) {
      if (!mounted) return;
      final problem = ProblemDetail.fromDioException(error);
      setState(() {
        _uploading = false;
        _showUploadProblem(problem);
      });
    }
  }

  /// Puts the backend's reasons under the field they name. The dialog stays
  /// open so the key can be corrected.
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
    final pending = _pending;
    return FormDialog(
      title: l10n.asset_library_upload_title,
      actionLabel: l10n.asset_picker_upload_action,
      maxWidth: 560,
      busy: _uploading,
      onSubmit: pending == null || _uploading ? null : _upload,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (pending == null)
            OutlinedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: Text(l10n.asset_picker_upload),
              onPressed: _uploading ? null : _chooseFile,
            )
          else ...[
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
          ],
        ],
      ),
    );
  }

  TextStyle? _errorStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.error);
}
