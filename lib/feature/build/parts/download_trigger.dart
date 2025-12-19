import 'package:flutter/material.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/feature/base/model_text.dart';
import 'package:stelaris/feature/base/stelaris_loader.dart';
import 'package:stelaris/feature/build/parts/download_selection.dart';

class DownloadTrigger extends StatefulWidget {
  const DownloadTrigger({super.key});

  @override
  State<DownloadTrigger> createState() => _DownloadTriggerState();
}

class _DownloadTriggerState extends State<DownloadTrigger> {
  late Future<List<String>> _branchesFuture;

  @override
  void initState() {
    super.initState();
    _branchesFuture = ApiService().generateApi.branches();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _branchesFuture,
      builder: (context, snapshot) => switch (snapshot) {
        AsyncSnapshot(connectionState: ConnectionState.waiting) => const StelarisLoader(),
        AsyncSnapshot(hasError: true) => _buildErrorState(),
        AsyncSnapshot(hasData: false) => _buildNoDataState(),
        AsyncSnapshot(data: final branches?) => _buildDataState(branches),
        _ => _buildNoDataState(),
      },
    );
  }

  /// Returns the [Widget] which display an error message when something went wrong
  Widget _buildErrorState() {
    return const Center(
      child: TextWidget(displayName: 'An error occurred during data fetching'),
    );
  }

  /// Returns a [Widget] that shows some information when no data is available
  Widget _buildNoDataState() {
    return const Center(child: TextWidget(displayName: 'Found no data!'));
  }

  /// Builds the [DownloadSelection] widget with the given branch data
  Widget _buildDataState(List<String> branches) {
    final items = _getItems(branches);
    return DownloadSelection(branches: items);
  }

  /// Returns a list of [DropdownMenuItem]s where each entry represents one branch from a repository.
  ///
  /// The [branches] parameter contains the raw branch names as strings.
  List<DropdownMenuItem<String>> _getItems(List<String> branches) {
    return branches
        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
        .toList();
  }
}
