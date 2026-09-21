import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/copy_model_result.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';

/// A dialog for duplicating a model, in the same project or into a
/// different one.
///
/// Reuses [ModelCreateDialog]'s field conventions (name/key validation and
/// the live `namespace:key` preview), plus a target-project picker and an
/// optional "include relationships" checkbox that only appears when
/// [hasRelationshipData] is true.
class CopyModelDialog extends StatefulWidget {
  const CopyModelDialog({
    required this.title,
    required this.projects,
    required this.currentProject,
    required this.initialName,
    required this.initialKey,
    required this.hasRelationshipData,
    required this.onSubmit,
    this.maxWidth = 520,
    super.key,
  });

  final String title;
  final List<Project> projects;
  final Project currentProject;
  final String initialName;
  final String initialKey;
  final bool hasRelationshipData;
  final void Function(CopyModelResult result) onSubmit;
  final double maxWidth;

  @override
  State<CopyModelDialog> createState() => _CopyModelDialogState();
}

class _CopyModelDialogState extends State<CopyModelDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _keyController;
  late Project _targetProject;
  bool _includeRelationships = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _keyController = TextEditingController(text: widget.initialKey);
    _targetProject = widget.currentProject;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final targetProjectId = _targetProject.id;
    if (targetProjectId == null) return;

    widget.onSubmit(
      CopyModelResult(
        targetProjectId: targetProjectId,
        name: _nameController.text.trim(),
        key: _keyController.text.trim(),
        includeRelationships: _includeRelationships,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormDialog(
      title: widget.title,
      actionIcon: Icons.copy_outlined,
      actionLabel: context.l10n.dialog_model_copy_button,
      maxWidth: widget.maxWidth,
      onSubmit: _handleSubmit,
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<Project>(
              initialValue: _targetProject,
              decoration: InputDecoration(
                labelText: context.l10n.dialog_model_copy_project_label,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.folder_outlined),
              ),
              items: widget.projects
                  .map(
                    (project) => DropdownMenuItem<Project>(
                      value: project,
                      child: Text(
                        '${project.displayName} (${project.key})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (project) {
                if (project == null) return;
                setState(() => _targetProject = project);
              },
            ),
            verticalSpacing10,
            TextFormField(
              controller: _nameController,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(stringWithSpacePattern),
              ],
              decoration: InputDecoration(
                labelText: '${context.l10n.dialog_model_name_label} *',
                hintText: context.l10n.dialog_model_name_hint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: Validators.required('Name is required'),
              onFieldSubmitted: (_) => _handleSubmit(),
            ),
            verticalSpacing10,
            TextFormField(
              controller: _keyController,
              inputFormatters: const [lowerCaseFormatter],
              decoration: InputDecoration(
                labelText: '${context.l10n.dialog_model_key_label} *',
                hintText: context.l10n.dialog_model_key_hint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
              ),
              validator: Validators.adventureKeyPart(),
              onFieldSubmitted: (_) => _handleSubmit(),
            ),
            verticalSpacing10,
            NoticeBox(
              icon: Icons.preview_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.dialog_model_preview_label,
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
                          color: text.isEmpty
                              ? theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                )
                              : theme.colorScheme.primary,
                          fontStyle: text.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (widget.hasRelationshipData) ...[
              verticalSpacing10,
              CheckboxListTile(
                value: _includeRelationships,
                onChanged: (value) =>
                    setState(() => _includeRelationships = value ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(context.l10n.dialog_model_copy_relationships_label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
