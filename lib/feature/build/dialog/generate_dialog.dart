import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/api_service.dart';
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
      title: const Text(
        "Generate",
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.all(20.0),
      children: [
        const Text(
          "Please select a branch",
          textAlign: TextAlign.center,
        ),
        spaceTwentyFiveHeightBox,
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
        spaceTwentyFiveHeightBox,
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
                        content: Text("Generation fails at backend"),
                      ));
                  }
                } else{
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text("Generation submited to backend"),
                      ));
                  }
                }
                if (mounted) {
                  context.pop();
                }
              }
            },
            child: const Text("Generate"))
      ],
    );
  }
}
