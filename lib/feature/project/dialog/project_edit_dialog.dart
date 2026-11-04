import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/service/client/pack_meta_client_api.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/project/dialog/pack_meta_form.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/util/dispatch_ext.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';

/// Edits a [Project] in two tabs: the project itself and the `pack.mcmeta`
/// of its resource pack. One save stores both.
class EditProjectDialog extends StatefulWidget {
  final Project project;

  /// The pack meta client, the shared one of [ApiService] when not given.
  final PackMetaClientApi? packMetaApi;

  const EditProjectDialog({required this.project, this.packMetaApi, super.key});

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
  bool _saving = false;

  PackMetaClientApi get _packMetaApi =>
      widget.packMetaApi ?? ApiService().packMetaApi;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
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
          decoration: InputDecoration(
            labelText: context.l10n.dialog_project_url,
            hintText: 'https://github.com/...',
            prefixIcon: const Icon(Icons.link),
          ),
        ),
        verticalSpacing10,
        TextFormField(
          controller: _docuUrlController,
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
      _MetaLoad.loaded => PackMetaForm(controller: _meta),
    };
  }

  /// Loads the resource pack's meta; a 404 means the project has none.
  Future<void> _loadPackMeta() async {
    if (_metaLoad != _MetaLoad.loading) {
      setState(() => _metaLoad = _MetaLoad.loading);
    }
    PackMeta? meta;
    var failed = false;
    try {
      meta = await _packMetaApi.get(widget.project.id!, PackType.resource);
    } on DioException catch (error) {
      failed = error.response?.statusCode != 404;
    } catch (_) {
      failed = true;
    }
    if (!mounted) return;
    setState(() {
      if (failed) {
        _metaLoad = _MetaLoad.failed;
        return;
      }
      _existingMeta = meta;
      _meta.fill(meta);
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
  Future<void> _savePackMeta() async {
    if (_metaLoad != _MetaLoad.loaded) return;
    final projectId = widget.project.id!;
    final existing = _existingMeta;
    if (!_meta.isEmpty) {
      final meta = _meta.toMeta(existing);
      if (meta == existing) return;
      _existingMeta = await _packMetaApi.put(projectId, meta);
    } else if (existing != null) {
      await _packMetaApi.delete(projectId, existing.packType);
      _existingMeta = null;
    }
  }
}
