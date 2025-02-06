import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/util/constants.dart';

const int maxCommitLength = 10;

class DevBuildOption extends StatefulWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;

  const DevBuildOption({required this.controller, required this.formKey, super.key});

  @override
  State<DevBuildOption> createState() => _DevBuildOptionState();
}

class _DevBuildOptionState extends State<DevBuildOption> {
  late bool devMode;

  @override
  void initState() {
    devMode = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customize Git commit',
              textAlign: TextAlign.center,
            ),
            Checkbox(
              value: devMode,
              onChanged: (value) {
                setState(() {
                  devMode = value!;
                });
              },
            )
          ],
        ),
        if (devMode) _getDevBuild()
      ],
    );
  }

  Widget _getDevBuild() {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        autocorrect: true,
        maxLength: maxCommitLength, // TODO: Add a constant for this
        controller: widget.controller,
        decoration: const InputDecoration(
          labelText: 'Git commit',
          suffixIcon: Tooltip(
            message: 'Enter a valid Git commit (Only the first 10 characters)',
            child: Icon(Icons.info_outline_rounded),
          ),
        ),
        keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.allow(gitCommitPattern),
        ],
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
