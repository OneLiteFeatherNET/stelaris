import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/feature/base/snackbar/info_bar.dart';
import 'package:stelaris_ui/feature/build/parts/dev_build_option.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:web/web.dart' as web;

class DownloadSelection extends StatefulWidget {
  final List<DropdownMenuItem<String>> branches;

  const DownloadSelection({
    required this.branches,
    super.key,
  });

  @override
  State<DownloadSelection> createState() => _DownloadSelectionState();
}

class _DownloadSelectionState extends State<DownloadSelection> {
  String? defaultValue;
  late final TextEditingController _gitCommitController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    defaultValue = widget.branches.first.value;
    _gitCommitController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    defaultValue = null;
    _gitCommitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
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
            ),
          ),
          verticalSpacing25,
          DevBuildOption(
            controller: _gitCommitController,
            formKey: _formKey,
          ),
          verticalSpacing25,
          FilledButton(
            onPressed: () async {
              final defaultValue = this.defaultValue;
              final currentState = _formKey.currentState;
              if (defaultValue == null) return;
              if (currentState != null && currentState.validate()) return;
              Navigator.of(context).pop();
              final text = context.l10n.error_generation_submit;
              ScaffoldMessenger.of(context)
                  .showSnackBar(InfoBarFactory().create(text));
              final data =
                  await ApiService().generateApi.download(defaultValue);
              final content = base64Encode(data);
              web.HTMLAnchorElement()
                ..setAttribute(
                    "href", "data:application/octet-stream;base64,$content")
                ..setAttribute("download", "generated.zip")
                ..click();
            },
            child: Text(context.l10n.button_download),
          )
        ],
      ),
    );
  }
}
