import 'package:flutter/material.dart';
import 'package:stelaris/feature/build/branch_option.dart';

class BuildBranchSelection extends StatefulWidget {
  final ValueNotifier<BranchOption> branchOption;

  const BuildBranchSelection({
    required this.branchOption,
    super.key,
  });

  @override
  State<BuildBranchSelection> createState() => _BuildBranchSelectionState();
}

class _BuildBranchSelectionState extends State<BuildBranchSelection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Branch: '),
            SegmentedButton<BranchOption>(
              segments: _getOptions(),
              selected: <BranchOption>{widget.branchOption.value},
              onSelectionChanged: (selected) {
                if (widget.branchOption.value == selected.first) return;
                setState(() {
                  widget.branchOption.value = selected.first;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  List<ButtonSegment<BranchOption>> _getOptions() {
    return BranchOption.values.map((e) {
      return ButtonSegment<BranchOption>(
        value: e,
        label: Text(e.name),
      );
    }).toList();
  }
}
