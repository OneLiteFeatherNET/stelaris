import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/feature/build/branch_option.dart';
import 'package:stelaris_ui/feature/build/parts/build_branch_selection.dart';
import 'package:stelaris_ui/feature/build/parts/version_update_input.dart';
import 'package:stelaris_ui/feature/build/version_group_selection.dart';
import 'package:stelaris_ui/util/constants.dart';

class BuildTrigger extends StatefulWidget {
  const BuildTrigger({required this.version, super.key});

  final String version;

  @override
  State<BuildTrigger> createState() => _BuildTriggerState();
}

class _BuildTriggerState extends State<BuildTrigger> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _newVersionController = TextEditingController();
  final ValueNotifier<BranchOption> _branchOption =
      ValueNotifier(BranchOption.release);
  VersionPart _versionPart = VersionPart.major;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _controller.text = widget.version;
    _newVersionController.text =
        _updateVersion(widget.version, _versionPart.index);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _newVersionController.dispose();
    _branchOption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heightTen,
          TextField(
            enabled: false,
            decoration: const InputDecoration(
              labelText: "Current version",
            ),
            controller: _controller,
          ),
          verticalSpacing25,
          const Text("Select the part of the version to update:"),
          verticalSpacing25,
          VersionGroupSelection(
            onSelected: (value) {
              _versionPart = value;
              _newVersionController.text =
                  _updateVersion(widget.version, _versionPart.index);
            },
          ),
          heightTen,
          const Divider(),
          heightTen,
          VersionUpdateInput(
            branchOption: _branchOption,
            controller: _newVersionController,
            formKey: _formKey,
          ),
          verticalSpacing25,
          BuildBranchSelection(branchOption: _branchOption),
          verticalSpacing25,
          Align(
            alignment: Alignment.center,
            child: FilledButton(
              onPressed: () {
                final state = _formKey.currentState;
                if (state == null) return;
                if (state.validate()) return;
                String branch;
                switch (_branchOption.value) {
                  case BranchOption.release:
                    branch = 'master';
                    break;
                  default:
                    branch = 'develop';
                }
                ApiService().generateApi.generate(branch);
              },
              child: const Text("Generate"),
            ),
          ),
        ],
      ),
    );
  }

  /// Update the version string based on the selected radio button index
  String _updateVersion(String currentVersion, int radioButtonIndex) {
    // Split the version string into parts
    List<String> versionParts = currentVersion.split('.');

    // Ensure that the version string has at least three parts
    if (versionParts.length < 3) {
      throw ArgumentError('Invalid version string format');
    }

    // Convert version parts to integers
    int major = int.parse(versionParts[0]);
    int minor = int.parse(versionParts[1]);
    int patch = int.parse(versionParts[2]);
    // Update the selected part based on the radio button index
    switch (radioButtonIndex) {
      case 0: // Update major version
        major++;
        minor = 0;
        patch = 0;
        break;
      case 1: // Update minor version
        minor++;
        patch = 0;
        break;
      case 2: // Update patch version
        patch++;
        break;
    }
    // Construct and return the updated version string
    return '$major.$minor.$patch';
  }
}
