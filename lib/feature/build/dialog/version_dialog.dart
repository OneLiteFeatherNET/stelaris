import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/util/version/version.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class VersionDialog extends StatefulWidget {
  final ValueUpdate<String> valueUpdate;

  const VersionDialog({Key? key, required this.valueUpdate}) : super(key: key);

  @override
  State<VersionDialog> createState() => _VersionDialogState();
}

class _VersionDialogState extends State<VersionDialog> {
  String group = "Release";
  String oldVersion = "32.16.5";

  TextEditingController _newVersionController = TextEditingController();

  TextEditingController _currentVersionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentVersionController.text = oldVersion;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text(
        "Add new version",
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.all(20.0),
      children: [
        const Text("Version type"),
        Column(
          children: [
            RadioListTile(
              title: Text(Version.minor.display),
              value: Version.minor.display,
              groupValue: group,
              onChanged: (value) {
                setState(() {
                  group = value.toString();
                  _getNewVersion(oldVersion, Version.minor);
                });
              },
            ),
            RadioListTile(
              title: Text(Version.major.display),
              value: Version.major.display,
              groupValue: group,
              onChanged: (value) {
                setState(() {
                  group = value.toString();
                  _getNewVersion(oldVersion, Version.major);
                });
              },
            ),
            RadioListTile(
              title: Text(Version.patch.display),
              value: Version.patch.display,
              groupValue: group,
              onChanged: (value) {
                setState(() {
                  group = value.toString();
                  _getNewVersion(oldVersion, Version.patch);
                });
              },
            ),
          ],
        ),
        spaceTwentyFiveHeightBox,
        TextField(
          enabled: false,
          controller: _currentVersionController,
        ),
        spaceTwentyFiveHeightBox,
        TextField(
          enabled: false,
          controller: _newVersionController,
        ),
        spaceTwentyFiveHeightBox,
        TextButton(
          onPressed: () {
            if (_newVersionController.text.isNotEmpty) {
              widget.valueUpdate(_newVersionController.text);
              GoRouter.of(context).pop(true);
            } else {
              GoRouter.of(context).pop(false);
            }
          },
          child: addText,
        )
      ],
    );
  }

  _getNewVersion(String currentVersion, Version version) {
    var stringParts = currentVersion.split(dotPattern);
    print(stringParts);

    switch (version) {
      case Version.major:
        _newVersionController.text = '${int.parse(stringParts[0]) + 1}.0.0';
        break;
      case Version.minor:
        _newVersionController.text =
            '${stringParts[0]}.${int.parse(stringParts[1]) + 1}.0';
        break;
      default:
        _newVersionController.text =
            '${stringParts[0]}.${stringParts[1]}.${int.parse(stringParts[2]) + 1}';
        break;
    }
  }
}
