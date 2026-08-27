import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris_models/stelaris_models.dart';

import 'project_form_dialog.dart';

class EditProjectDialog extends StatefulWidget {
  final Project project;

  const EditProjectDialog({
    super.key,
    required this.project,
  });

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _keyController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _projectUrlController;
  late final TextEditingController _docuUrlController;
  late bool _labor;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.project.displayName);
    _keyController = TextEditingController(text: widget.project.key);
    _descriptionController = TextEditingController(text: widget.project.description ?? '');
    _projectUrlController = TextEditingController(text: widget.project.projectUrl ?? '');
    _docuUrlController = TextEditingController(text: widget.project.docuUrl ?? '');
    _labor = widget.project.labor;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _keyController.dispose();
    _descriptionController.dispose();
    _projectUrlController.dispose();
    _docuUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProjectFormDialog(
      title: context.l10n.dialog_project_edit_title,
      actionIcon: Icons.save_outlined,
      actionLabel: context.l10n.dialog_project_edit_button,
      onSubmit: _handleSave,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _displayNameController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: '${context.l10n.dialog_project_display_name} *',
                hintText: 'e.g. My Awesome Project',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: Validators.required('Display name is required'),
            ),
            verticalSpacing10,
            TextFormField(
              controller: _keyController,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: context.l10n.dialog_project_key,
                border: const OutlineInputBorder(),
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
                hintText: 'Brief description of the project',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            verticalSpacing10,
            TextFormField(
              controller: _projectUrlController,
              decoration: InputDecoration(
                labelText: context.l10n.dialog_project_url,
                hintText: 'https://github.com/...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
            verticalSpacing10,
            TextFormField(
              controller: _docuUrlController,
              decoration: InputDecoration(
                labelText: context.l10n.dialog_project_docu_url,
                hintText: 'https://docs.example.com/...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.menu_book_outlined),
              ),
            ),
            verticalSpacing10,
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.dialog_project_labor),
              subtitle: const Text(
                'Mark as laboratory / experimental project',
                style: TextStyle(fontSize: 12),
              ),
              value: _labor,
              onChanged: (val) {
                setState(() {
                  _labor = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

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

    await context.dispatchAndWait(UpdateProjectAction(updatedProject));
    if (mounted) {
      Navigator.of(context).pop(updatedProject);
    }
  }
}
