import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris_models/stelaris_models.dart';

import 'project_form_dialog.dart';

class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _keyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _docuUrlController = TextEditingController();
  bool _labor = false;

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
      title: context.l10n.dialog_project_create_title,
      actionIcon: Icons.add,
      actionLabel: context.l10n.dialog_project_create_button,
      onSubmit: _handleCreate,
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: const [lowerCaseFormatter],
              decoration: InputDecoration(
                labelText: '${context.l10n.dialog_project_key} *',
                hintText: 'e.g. my_project',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
              ),
              validator: Validators.adventureNamespace(),
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

  void _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    final key = _keyController.text.trim();
    final displayName = _displayNameController.text.trim();
    final desc = _descriptionController.text.trim();
    final projectUrl = _projectUrlController.text.trim();
    final docuUrl = _docuUrlController.text.trim();

    final newProject = Project(
      displayName: displayName,
      key: key,
      description: desc.isEmpty ? null : desc,
      projectUrl: projectUrl.isEmpty ? null : projectUrl,
      docuUrl: docuUrl.isEmpty ? null : docuUrl,
      labor: _labor,
    );

    final status = await context.dispatchAndWait(
      AddProjectAction(newProject, select: true),
    );
    if (status.isCompletedOk && mounted) {
      Navigator.of(context).pop(newProject);
    }
  }
}
