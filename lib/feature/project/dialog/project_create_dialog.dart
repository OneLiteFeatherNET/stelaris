import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

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

  final _keyRegex = RegExp(r'^[a-zA-Z0-9_-]+$');

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
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.dialog_project_create_title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  ),
                ],
              ),
              const Divider(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _displayNameController,
                          decoration: InputDecoration(
                            labelText: '${context.l10n.dialog_project_display_name} *',
                            hintText: 'e.g. My Awesome Project',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.title),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Display name is required';
                            }
                            return null;
                          },
                        ),
                        verticalSpacing10,
                        TextFormField(
                          controller: _keyController,
                          decoration: InputDecoration(
                            labelText: '${context.l10n.dialog_project_key} *',
                            hintText: 'e.g. my_project',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.vpn_key_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Key / Namespace is required';
                            }
                            if (!_keyRegex.hasMatch(value.trim())) {
                              return 'Only alphanumeric characters, underscores, and dashes allowed';
                            }
                            return null;
                          },
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
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.button_cancel),
                  ),
                  horizontalSpacing10,
                  FilledButton.icon(
                    onPressed: _handleCreate,
                    icon: const Icon(Icons.add),
                    label: Text(context.l10n.dialog_project_create_button),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCreate() {
    if (!_formKey.currentState!.validate()) return;

    final key = _keyController.text.trim();
    final displayName = _displayNameController.text.trim();
    final desc = _descriptionController.text.trim();
    final projectUrl = _projectUrlController.text.trim();
    final docuUrl = _docuUrlController.text.trim();

    final newProject = Project(
      id: key,
      displayName: displayName,
      key: key,
      description: desc.isEmpty ? null : desc,
      projectUrl: projectUrl.isEmpty ? null : projectUrl,
      docuUrl: docuUrl.isEmpty ? null : docuUrl,
      labor: _labor,
    );

    context.dispatch(AddProjectAction(newProject, select: true));
    Navigator.of(context).pop(newProject);
  }
}
