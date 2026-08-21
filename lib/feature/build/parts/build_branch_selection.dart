import 'package:flutter/material.dart';
import 'package:stelaris/feature/build/branch_option.dart';

class BuildBranchSelection extends StatefulWidget {
  final ValueNotifier<BranchOption> branchOption;

  const BuildBranchSelection({required this.branchOption, super.key});

  @override
  State<BuildBranchSelection> createState() => _BuildBranchSelectionState();
}

class _BuildBranchSelectionState extends State<BuildBranchSelection> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<BranchOption>(
        segments: _getOptions(),
        selected: <BranchOption>{widget.branchOption.value},
        onSelectionChanged: (selected) {
          if (widget.branchOption.value == selected.first) return;
          setState(() {
            widget.branchOption.value = selected.first;
          });
        },
      ),
    );
  }

  List<ButtonSegment<BranchOption>> _getOptions() {
    return BranchOption.values.map((e) {
      return ButtonSegment<BranchOption>(value: e, label: Text(e.name));
    }).toList();
  }
}
