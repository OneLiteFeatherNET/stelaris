import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/build/parts/download_selection.dart';
import 'package:stelaris_ui/util/constants.dart';

class DownloadTrigger extends StatelessWidget {
  final List<String>? filter;

  const DownloadTrigger({this.filter, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiService().generateApi.branches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: loader,
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: ModelText(
              displayName: 'An error occurred during data fetching',
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: ModelText(
              displayName: 'Found no data!',
            ),
          );
        } else {
          final list = snapshot.data as List<String>;
          final filter = this.filter;
          List<DropdownMenuItem<String>> items = filter == null
              ? _getItems(list)
              : _getItemsWithFilter(list, filter);
          return DownloadSelection(
            branches: items,
          );
        }
      },
    );
  }

  List<DropdownMenuItem<String>> _getItems(List<String> branches) {
    return branches
        .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ))
        .toList();
  }

  List<DropdownMenuItem<String>> _getItemsWithFilter(
      List<String> branches, List<String> filter) {
    if (filter.isEmpty) return _getItems(branches);
    return branches
        .where((element) => filter.contains(element))
        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
        .toList();
  }
}
