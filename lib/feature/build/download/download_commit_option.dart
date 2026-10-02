import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

const int maxCommitLength = 10;

class DevBuildOption extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;

  const DevBuildOption({
    required this.controller,
    required this.formKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        autocorrect: true,
        maxLength: maxCommitLength,
        controller: controller,
        decoration: InputDecoration(
          labelText: context.l10n.download_commit_label,
          prefixIcon: const Icon(Icons.commit),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
          ),
          suffixIcon: Tooltip(
            message: context.l10n.download_commit_tooltip,
            child: const Icon(Icons.info_outline_rounded),
          ),
        ),
        keyboardType: TextInputType.text,
        inputFormatters: [FilteringTextInputFormatter.allow(gitCommitPattern)],
        validator: (value) {
          if (value != null && value.length < maxCommitLength) {
            return context.l10n.validation_commit_length;
          }
          return null;
        },
      ),
    );
  }
}
