import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class DownloadDialog extends StatefulWidget {
  final List<DropdownMenuItem<String>> branches;

  const DownloadDialog({super.key, required this.branches});

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  String? defaultValue;

  @override
  Widget build(BuildContext context) {
    defaultValue = widget.branches.first.value;
    return SimpleDialog(
      title: Text(
        context.l10n.button_download,
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
                    await ApiService().generateApi.download(defaultValue!);
                final content = base64Encode(data);
                final anchor = AnchorElement(
                    href: "data:application/octet-stream;base64,$content")
                  ..setAttribute("download", "generated.zip")
                  ..click();
                if (mounted) {
                  context.pop();
                }
              }
            },
            child: Text(context.l10n.button_download))
      ],
    );
  }
}
