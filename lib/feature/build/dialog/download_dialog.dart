import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/constants.dart';

class DownloadDialog extends StatefulWidget {

  final List<DropdownMenuItem<String>> branches;

  const DownloadDialog({Key? key, required this.branches}) : super(key: key);

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {

  String? defaultValue;

  @override
  Widget build(BuildContext context) {
    defaultValue = widget.branches.first.value;
    return SimpleDialog(
      title: const Text("Download", textAlign: TextAlign.center,),
      contentPadding: const EdgeInsets.all(20.0),
      children: [
        const Text("Please select a branch", textAlign: TextAlign.center,),
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
            )
        ),
        spaceTwentyFiveHeightBox,
        TextButton(
            onPressed: () {},
            child: const Text("Download")
        )
      ],
    );
  }
}
