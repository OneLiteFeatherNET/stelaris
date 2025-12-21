import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:web/web.dart' as web;

import 'download_commit_option.dart';

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

  bool _useCommit = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search by Commit',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                Switch(
                  value: _useCommit,
                  onChanged: (value) {
                    setState(() {
                      _useCommit = value;
                    });
                  },
                ),
              ],
            ),
            verticalSpacing25,
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _useCommit
                  ? DevBuildOption(
                      controller: _gitCommitController,
                      formKey: _formKey,
                    )
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: widget.branches,
                      initialValue: defaultValue,
                      onChanged: (String? value) {
                        if (value == null) return;
                        defaultValue = value;
                      },
                    ),
            ),
            verticalSpacing25,
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  late String value;
                  if (_useCommit) {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    value = _gitCommitController.text;
                  } else {
                    final defaultValue = this.defaultValue;
                    if (defaultValue == null) return;
                    value = defaultValue;
                  }

                  Navigator.of(context).pop();
                  final text = context.l10n.error_generation_submit;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(InfoBarFactory().create(text));
                  final data = await ApiService().generateApi.download(value);
                  final content = base64Encode(data);
                  web.HTMLAnchorElement()
                    ..setAttribute(
                        'href', 'data:application/octet-stream;base64,$content')
                    ..setAttribute('download', 'generated.zip')
                    ..click();
                },
                label: Text(context.l10n.button_download),
              ),
            )
          ],
        ),
      ),
    );
  }
}
