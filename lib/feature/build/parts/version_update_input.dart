import 'package:flutter/material.dart';
import 'package:stelaris/feature/build/branch_option.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/formatter/version_input_formatter.dart';

VersionInputFormatter versionFormatter = const VersionInputFormatter();

class VersionUpdateInput extends StatefulWidget {
  final ValueNotifier<BranchOption> branchOption;
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;

  const VersionUpdateInput({
    required this.branchOption,
    required this.controller,
    required this.formKey,
    super.key,
  });

  @override
  State<VersionUpdateInput> createState() => _VersionUpdateInputState();
}

class _VersionUpdateInputState extends State<VersionUpdateInput> {
  late String? cache;

  @override
  void initState() {
    widget.branchOption.addListener(_callback);
    super.initState();
  }

  @override
  void dispose() {
    widget.branchOption.removeListener(_callback);
    cache = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: TextFormField(
        enabled: widget.branchOption.value == BranchOption.snapshot,
        autovalidateMode: widget.branchOption.value == BranchOption.snapshot
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        decoration: InputDecoration(
          labelText: 'New version',
          suffixIcon: _getSuffix(),
        ),
        controller: widget.controller,
        keyboardType: TextInputType.text,
        inputFormatters: [
          versionFormatter,
        ],
        validator: (value) {
          if (widget.branchOption.value != BranchOption.snapshot) return null;
          final String input = value!;
          if (input.trim().isEmpty) {
            return 'The major part must start with 99';
          }

          String? part;

          if (!input.contains(dotPattern)) {
            part = input;
          } else {
            part = input.split(dotPattern)[0];
          }

          if (part.startsWith('99')) return null;
          return 'The major part must start with 99';
        },
      ),
    );
  }

  Widget? _getSuffix() {
    if (widget.branchOption.value == BranchOption.release) return null;
    return const Tooltip(
      message: 'Specify the version that you want to use',
      child: Icon(Icons.info_outline_rounded),
    );
  }

  _callback() {
    setState(() {
      if (widget.branchOption.value == BranchOption.snapshot) {
        cache = widget.controller.text;
      } else {
        widget.controller.text = cache!;
        cache = null;
      }
    });
  }
}
