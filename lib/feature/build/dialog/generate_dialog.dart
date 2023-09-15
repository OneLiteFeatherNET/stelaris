import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class GenerateDialog extends StatefulWidget {
  final List<DropdownMenuItem<String>> branches;

  const GenerateDialog({Key? key, required this.branches}) : super(key: key);

  @override
  State<GenerateDialog> createState() => _GenerateDialogState();
}

class _GenerateDialogState extends State<GenerateDialog> {
  String? defaultValue;

  @override
  Widget build(BuildContext context) {
    defaultValue = widget.branches.first.value;
    return SimpleDialog(
      title: Text(
        context.l10n.button_generate,
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.all(20.0),
      children: [
        Text(
          context.l10n.text_branch,
          textAlign: TextAlign.center,
        ),
        verticalSpacing25,
        SizedBox(
            width: 300,
            child: DropdownButtonFormField<String>(
              items: widget.branches,
              value: defaultValue,
              onChanged: (String? value) {
                if (value == null) return;
                defaultValue = value;
              },
            )),
        verticalSpacing25,
        TextButton(
            onPressed: () async {
              if (defaultValue != null) {
                final data =
                    await ApiService().generateApi.generate(defaultValue!);
                if (data.statusCode != 200) {
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(context.l10n.error_generation_failure),
                      ));
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                          content: Text(context.l10n.error_generation_submit)));
                  }
                }
                if (mounted) {
                  context.pop();
                }
              }
            },
            child: Text(context.l10n.button_generate))
      ],
    );
  }
}
