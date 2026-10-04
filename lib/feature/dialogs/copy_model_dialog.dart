import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/copy_model_result.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// A relation that can be copied along with a model, e.g. an item's lore.
class CopyRelation {
  const CopyRelation(this.id, this.label);

  /// The backend's name for it, e.g. `LORE`.
  final String id;
  final String Function(AppLocalizations l10n) label;
}

/// Asks where to copy a model to and what to call the copy.
///
/// Like [ModelCreateDialog] plus a target project and, for models that have
/// them, a checkbox per relation, all checked. Submitting waits for
/// [onSubmit]: on an error the dialog stays open and shows it, otherwise it
/// closes with the [CopyModelResult].
class CopyModelDialog extends StatefulWidget {
  const CopyModelDialog({
    required this.title,
    required this.projects,
    required this.currentProject,
    required this.initialName,
    required this.initialKey,
    required this.onSubmit,
    this.relations = const [],
    super.key,
  });

  final String title;
  final List<Project> projects;
  final Project currentProject;
  final String initialName;
  final String initialKey;
  final List<CopyRelation> relations;

  /// Copies; resolves to the error, or `null` when it worked.
  final Future<Object?> Function(CopyModelResult result) onSubmit;

  @override
  State<CopyModelDialog> createState() => _CopyModelDialogState();
}

class _CopyModelDialogState extends State<CopyModelDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _keyController;
  late final List<Project> _projects;
  late String _targetProjectId;
  late final Set<String> _relations;
  bool _copying = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _keyController = TextEditingController();
    // Only stored projects can be copied into; the open one is always
    // offered, even if the project list hasn't been loaded.
    final stored = widget.projects.where((p) => p.id != null).toList();
    _projects = [
      if (!stored.any((p) => p.id == widget.currentProject.id))
        widget.currentProject,
      ...stored,
    ];
    _targetProjectId = widget.currentProject.id!;
    _relations = {for (final relation in widget.relations) relation.id};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_nameController.text.isEmpty && _keyController.text.isEmpty) {
      final l10n = context.l10n;
      _nameController.text =
          '${widget.initialName}${l10n.dialog_model_copy_name_suffix}';
      _keyController.text =
          '${widget.initialKey}${l10n.dialog_model_copy_key_suffix}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Project get _targetProject =>
      _projects.firstWhere((p) => p.id == _targetProjectId);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final result = CopyModelResult(
      targetProject: _targetProject,
      name: _nameController.text.trim(),
      key: _keyController.text.trim(),
      relations: Set.of(_relations),
    );

    setState(() => _copying = true);
    final error = await widget.onSubmit(result);
    if (!mounted) return;
    setState(() => _copying = false);

    if (error != null) {
      context.showErrorSnackBar(error);
      return;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return FormDialog(
      title: widget.title,
      actionIcon: Icons.copy_outlined,
      actionLabel: l10n.dialog_model_copy_button,
      onSubmit: _copying ? null : _submit,
      busy: _copying,
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _targetProjectId,
              decoration: InputDecoration(
                labelText: l10n.dialog_model_copy_project_label,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.folder_outlined),
              ),
              items: [
                for (final project in _projects)
                  DropdownMenuItem(
                    value: project.id,
                    child: Text(
                      '${project.displayName} (${project.key})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (id) {
                if (id != null) setState(() => _targetProjectId = id);
              },
            ),
            verticalSpacing10,
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: '${l10n.dialog_model_name_label} *',
                hintText: l10n.dialog_model_name_hint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: Validators.required(l10n.validation_name_required),
              onFieldSubmitted: (_) => _copying ? null : _submit(),
            ),
            verticalSpacing10,
            TextFormField(
              controller: _keyController,
              inputFormatters: const [lowerCaseFormatter],
              decoration: InputDecoration(
                labelText: '${l10n.dialog_model_key_label} *',
                hintText: l10n.dialog_model_key_hint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
              ),
              validator: Validators.adventureKeyPart(l10n),
              onFieldSubmitted: (_) => _copying ? null : _submit(),
            ),
            verticalSpacing10,
            NoticeBox(
              icon: Icons.preview_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dialog_model_preview_label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _keyController,
                    builder: (context, value, _) {
                      final text = value.text.trim();
                      return Text(
                        '${_targetProject.key}:${text.isEmpty ? '<key>' : text}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (widget.relations.isNotEmpty) ...[
              verticalSpacing10,
              Text(
                l10n.dialog_model_copy_relations_label,
                style: theme.textTheme.labelMedium,
              ),
              for (final relation in widget.relations)
                CheckboxListTile(
                  value: _relations.contains(relation.id),
                  onChanged: (checked) => setState(
                    () => checked == true
                        ? _relations.add(relation.id)
                        : _relations.remove(relation.id),
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(relation.label(l10n)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
