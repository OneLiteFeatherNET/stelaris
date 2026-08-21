import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/status_card.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:web/web.dart' as web;

import 'download_commit_option.dart';

class DownloadTrigger extends StatefulWidget {
  const DownloadTrigger({
    required this.branches,
    this.isLoading = false,
    this.onRefresh,
    super.key,
  });

  final List<String>? branches;
  final bool isLoading;
  final VoidCallback? onRefresh;

  @override
  State<DownloadTrigger> createState() => _DownloadTriggerState();
}

class _DownloadTriggerState extends State<DownloadTrigger> {
  late final TextEditingController _gitCommitController;
  final _formKey = GlobalKey<FormState>();
  String? defaultValue;
  bool _useCommit = false;

  @override
  void initState() {
    super.initState();
    _updateDefaultValue();
    _gitCommitController = TextEditingController();
  }

  @override
  void didUpdateWidget(DownloadTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.branches != oldWidget.branches) {
      _updateDefaultValue();
    }
  }

  void _updateDefaultValue() {
    final branches = widget.branches;
    if (branches != null && branches.isNotEmpty) {
      if (defaultValue == null || !branches.contains(defaultValue)) {
        defaultValue = branches.first;
      }
    } else {
      defaultValue = null;
    }
  }

  @override
  void dispose() {
    defaultValue = null;
    _gitCommitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (widget.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StatusCard(
            text: 'Fetching branches...',
            backgroundColor: theme.colorScheme.secondaryContainer.withValues(
              alpha: 0.5,
            ),
            textColor: theme.colorScheme.onSecondaryContainer,
            height: 70,
            icon: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    if (widget.branches == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StatusCard(
            text: 'Service unavailable',
            backgroundColor: theme.colorScheme.errorContainer.withValues(
              alpha: 0.8,
            ),
            textColor: theme.colorScheme.onErrorContainer,
            height: 70,
          ),
        ),
      );
    }

    if (widget.branches!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StatusCard(
            text: 'No branches found! Please create some in the repository',
            backgroundColor: theme.colorScheme.errorContainer,
            glowColor: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
            height: 70,
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: widget.onRefresh,
              tooltip: 'Refresh branches',
            ),
          ),
        ),
      );
    }

    // Map branches to DropdownMenuItems
    final branchItems = widget.branches!
        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
        .toList();

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
                  style: theme.textTheme.titleSmall,
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      items: branchItems,
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
                    if (!(_formKey.currentState?.validate() ?? false)) {
                      return;
                    }
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

                  final (data, filename) = await ApiService().generateApi
                      .download(value);

                  final content = base64Encode(data);

                  web.HTMLAnchorElement()
                    ..setAttribute(
                      'href',
                      'data:application/octet-stream;base64,$content',
                    )
                    ..setAttribute('download', filename)
                    ..click();
                },
                label: Text(context.l10n.button_download),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
