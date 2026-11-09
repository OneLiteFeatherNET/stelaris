import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/service/client/asset_client_api.dart';
import 'package:stelaris/api/service/client/pack_meta_client_api.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/feature/asset/picker/asset_key.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/project/dialog/pack_icon_field.dart';
import 'package:stelaris/feature/project/dialog/pack_meta_form.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/util/dispatch_ext.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';

/// The tabs of the [EditProjectDialog].
enum EditProjectTab { project, pack }

/// Edits a [Project] in two tabs: the project itself and the `pack.mcmeta`
/// of its resource pack. One save stores both.
///
/// The pack icon is a texture asset of the project the pack meta refers to.
/// A changed icon replaces the content of that asset, a removed one deletes
/// it, so no unused icon is left behind.
class EditProjectDialog extends StatefulWidget {
  final Project project;

  /// The pack meta client, the shared one of [ApiService] when not given.
  final PackMetaClientApi? packMetaApi;

  /// The asset client storing the pack icon, the shared one of [ApiService]
  /// when not given.
  final AssetClientApi? assetApi;

  /// Opens the file dialog for the pack icon.
  final Future<PickedAssetFile?> Function() pickIcon;

  /// The tab shown first.
  final EditProjectTab initialTab;

  const EditProjectDialog({
    required this.project,
    this.packMetaApi,
    this.assetApi,
    this.pickIcon = pickPackIcon,
    this.initialTab = EditProjectTab.project,
    super.key,
  });

  /// The key the pack icon of [project] is uploaded under.
  static String packIconKey(Project project) =>
      '${validNamespaceOr(project.key)}:pack/icon';

  /// The file name the pack icon is uploaded with.
  static const String packIconFileName = 'pack.png';

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

enum _MetaLoad { loading, loaded, failed }

class _EditProjectDialogState extends State<EditProjectDialog>
    with SingleTickerProviderStateMixin {
  final _projectFormKey = GlobalKey<FormState>();
  final _metaFormKey = GlobalKey<FormState>();
  late final TabController _tabController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _keyController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _projectUrlController;
  late final TextEditingController _docuUrlController;
  late bool _labor;

  final _meta = PackMetaFormController();
  _MetaLoad _metaLoad = _MetaLoad.loading;

  /// The pack meta as the backend has it, null if the project has none.
  PackMeta? _existingMeta;

  /// The stored asset of the pack icon and the bytes it holds. It can
  /// outlive the pack meta's reference when deleting it failed, so the next
  /// save tries again instead of uploading a second icon under its key.
  AssetModel? _iconAsset;
  Uint8List? _iconAssetBytes;
  bool _saving = false;

  PackMetaClientApi get _packMetaApi =>
      widget.packMetaApi ?? ApiService().packMetaApi;

  AssetClientApi get _assetApi => widget.assetApi ?? ApiService().assetApi;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: EditProjectTab.values.length,
      initialIndex: widget.initialTab.index,
      vsync: this,
    )..addListener(() => setState(() {}));
    _displayNameController = TextEditingController(
      text: widget.project.displayName,
    );
    _keyController = TextEditingController(text: widget.project.key);
    _descriptionController = TextEditingController(
      text: widget.project.description ?? '',
    );
    _projectUrlController = TextEditingController(
      text: widget.project.projectUrl ?? '',
    );
    _docuUrlController = TextEditingController(
      text: widget.project.docuUrl ?? '',
    );
    _labor = widget.project.labor;
    _loadPackMeta();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _displayNameController.dispose();
    _keyController.dispose();
    _descriptionController.dispose();
    _projectUrlController.dispose();
    _docuUrlController.dispose();
    _meta.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: context.l10n.dialog_project_edit_title,
      actionIcon: Icons.save_outlined,
      actionLabel: context.l10n.dialog_project_edit_button,
      onSubmit: _saving ? null : _handleSave,
      busy: _saving,
      maxWidth: 550,
      maxHeight: 700,
      header: TabBar.secondary(
        controller: _tabController,
        dividerHeight: 0,
        tabs: [
          Tab(text: context.l10n.dialog_project_tab_project),
          Tab(text: context.l10n.dialog_project_tab_pack_meta),
        ],
      ),
      // Both tabs stay mounted, so their fields keep what was typed and one
      // save validates both.
      content: IndexedStack(
        index: _tabController.index,
        children: [
          Form(key: _projectFormKey, child: _buildProjectFields(context)),
          Form(key: _metaFormKey, child: _buildPackMetaTab(context)),
        ],
      ),
    );
  }

  Widget _buildProjectFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _displayNameController,
          maxLength: maxTextLength,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: '${context.l10n.dialog_project_display_name} *',
            hintText: 'e.g. My Awesome Project',
            prefixIcon: const Icon(Icons.title),
          ),
          validator: Validators.required(
            context.l10n.validation_display_name_required,
          ),
        ),
        verticalSpacing10,
        TextFormField(
          controller: _keyController,
          readOnly: true,
          enabled: false,
          decoration: InputDecoration(
            labelText: context.l10n.dialog_project_key,
            prefixIcon: const Icon(Icons.lock_outline),
            helperText: context.l10n.dialog_project_key_readonly_hint,
          ),
        ),
        verticalSpacing10,
        TextFormField(
          controller: _descriptionController,
          maxLength: maxTextLength,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.l10n.dialog_project_description,
            hintText: context.l10n.project_description_hint,
            alignLabelWithHint: true,
          ),
        ),
        verticalSpacing10,
        TextFormField(
          controller: _projectUrlController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: Validators.maxLength(context.l10n, maxTextLength),
          decoration: InputDecoration(
            labelText: context.l10n.dialog_project_url,
            hintText: 'https://github.com/...',
            prefixIcon: const Icon(Icons.link),
          ),
        ),
        verticalSpacing10,
        TextFormField(
          controller: _docuUrlController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: Validators.maxLength(context.l10n, maxTextLength),
          decoration: InputDecoration(
            labelText: context.l10n.dialog_project_docu_url,
            hintText: 'https://docs.example.com/...',
            prefixIcon: const Icon(Icons.menu_book_outlined),
          ),
        ),
        verticalSpacing10,
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.dialog_project_labor),
          subtitle: Text(
            context.l10n.project_labor_toggle,
            style: const TextStyle(fontSize: 12),
          ),
          value: _labor,
          onChanged: (val) {
            setState(() {
              _labor = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPackMetaTab(BuildContext context) {
    return switch (_metaLoad) {
      _MetaLoad.loading => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      _MetaLoad.failed => Column(
        children: [
          verticalSpacing10,
          Text(context.l10n.pack_meta_load_failed),
          verticalSpacing10,
          OutlinedButton.icon(
            onPressed: _loadPackMeta,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.pack_meta_retry),
          ),
        ],
      ),
      _MetaLoad.loaded => PackMetaForm(
        controller: _meta,
        pickIcon: widget.pickIcon,
      ),
    };
  }

  /// Loads the resource pack's meta and its icon; a 404 for the meta means
  /// the project has none.
  ///
  /// An icon that can't be loaded fails the whole tab: shown without it, a
  /// save would remove it.
  Future<void> _loadPackMeta() async {
    if (_metaLoad != _MetaLoad.loading) {
      setState(() => _metaLoad = _MetaLoad.loading);
    }
    final projectId = widget.project.id!;
    PackMeta? meta;
    AssetModel? iconAsset;
    Uint8List? icon;
    var failed = false;
    try {
      meta = await _packMetaApi.get(projectId, PackType.resource);
    } on DioException catch (error) {
      failed = error.response?.statusCode != 404;
    } catch (_) {
      failed = true;
    }
    final iconAssetId = meta?.iconAssetId;
    if (!failed && iconAssetId != null) {
      try {
        final (asset, bytes) = await (
          _assetApi.getById(projectId, iconAssetId),
          _assetApi.content(projectId, iconAssetId),
        ).wait;
        iconAsset = asset;
        icon = Uint8List.fromList(bytes);
      } catch (_) {
        failed = true;
      }
    }
    if (!mounted) return;
    setState(() {
      if (failed) {
        _metaLoad = _MetaLoad.failed;
        return;
      }
      _existingMeta = meta;
      _iconAsset = iconAsset;
      _iconAssetBytes = icon;
      _meta.fill(meta, icon: icon);
      _metaLoad = _MetaLoad.loaded;
    });
  }

  void _handleSave() async {
    if (!_projectFormKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }
    if (_metaLoad == _MetaLoad.loaded &&
        !_metaFormKey.currentState!.validate()) {
      _tabController.animateTo(1);
      return;
    }

    final displayName = _displayNameController.text.trim();
    final desc = _descriptionController.text.trim();
    final projectUrl = _projectUrlController.text.trim();
    final docuUrl = _docuUrlController.text.trim();

    final updatedProject = widget.project.copyWith(
      displayName: displayName,
      description: desc.isEmpty ? null : desc,
      projectUrl: projectUrl.isEmpty ? null : projectUrl,
      docuUrl: docuUrl.isEmpty ? null : docuUrl,
      labor: _labor,
    );

    setState(() => _saving = true);
    final (:ok, :error) = await context.dispatchAndCatch(
      UpdateProjectAction(updatedProject),
    );
    if (!mounted) return;
    if (error != null || !ok) {
      setState(() => _saving = false);
      if (error != null) context.showErrorSnackBar(error);
      return;
    }

    try {
      await _savePackMeta();
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showErrorSnackBar(error);
      return;
    }
    if (mounted) Navigator.of(context).pop(updatedProject);
  }

  /// Stores the pack meta tab: creates or replaces the pack meta when it is
  /// filled in and changed, removes it when all its fields were cleared. Leaves it alone
  /// when it could not be loaded, as there is nothing known to change.
  ///
  /// The icon is stored first, so the pack meta can refer to it. A removed
  /// icon is deleted only after the pack meta no longer refers to it.
  Future<void> _savePackMeta() async {
    if (_metaLoad != _MetaLoad.loaded) return;
    final projectId = widget.project.id!;
    final existing = _existingMeta;
    final icon = _meta.icon;
    if (!_meta.isEmpty) {
      final iconAsset = icon == null ? null : await _storeIcon(icon);
      final meta = _meta.toMeta(existing).copyWith(iconAssetId: iconAsset?.id);
      if (meta != existing) {
        _existingMeta = await _packMetaApi.put(projectId, meta);
      }
    } else if (existing != null) {
      await _packMetaApi.delete(projectId, existing.packType);
      _existingMeta = null;
    }
    if (icon == null) await _deleteIcon();
  }

  /// Stores [icon] as the pack icon asset: uploads it if there is none yet,
  /// otherwise replaces the asset's content if it changed.
  Future<AssetModel> _storeIcon(Uint8List icon) async {
    final stored = _iconAsset;
    if (stored != null && listEquals(_iconAssetBytes, icon)) return stored;
    final asset = stored == null
        ? await _assetApi.upload(
            widget.project.id!,
            key: EditProjectDialog.packIconKey(widget.project),
            displayName: context.l10n.pack_icon_asset_name,
            fileName: EditProjectDialog.packIconFileName,
            bytes: icon,
          )
        : await _assetApi.replaceContent(
            stored,
            fileName: EditProjectDialog.packIconFileName,
            bytes: icon,
          );
    _iconAsset = asset;
    _iconAssetBytes = icon;
    return asset;
  }

  /// Deletes the pack icon asset, if there is one.
  Future<void> _deleteIcon() async {
    final stored = _iconAsset;
    if (stored == null) return;
    await _assetApi.delete(widget.project.id!, stored.id);
    _iconAsset = null;
    _iconAssetBytes = null;
  }
}
