import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/util/constants.dart';

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
          labelText: 'Git commit',
          prefixIcon: const Icon(Icons.commit),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
          ),
          suffixIcon: const Tooltip(
            message: 'Enter a valid Git commit (Only the first 10 characters)',
            child: Icon(Icons.info_outline_rounded),
          ),
        ),
        keyboardType: TextInputType.text,
        inputFormatters: [FilteringTextInputFormatter.allow(gitCommitPattern)],
        validator: (value) {
          if (value != null && value.length < maxCommitLength) {
            return 'The commit must contains 10 chars';
          }
          return null;
        },
      ),
    );
  }
}
