import 'package:flutter/material.dart';
import 'package:stelaris/feature/build/download/download_selection.dart';

class DownloadTrigger extends StatelessWidget {
  const DownloadTrigger({
    required this.branches,
    super.key,
  });

  final List<String> branches;

  @override
  Widget build(BuildContext context) {
    return DownloadSelection(
      branches: branches
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }
}
