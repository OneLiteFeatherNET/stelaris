import 'package:flutter/material.dart';

class VersionGroupSelection extends StatefulWidget {
  final Function(VersionPart) onSelected;

  const VersionGroupSelection({
    required this.onSelected,
    super.key,
  });

  @override
  State<VersionGroupSelection> createState() => _VersionGroupSelectionState();
}

class _VersionGroupSelectionState extends State<VersionGroupSelection> {
  VersionPart _selectedPart = VersionPart.major;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile(
          title: Text(VersionPart.major.description),
          value: VersionPart.major,
          groupValue: _selectedPart,
          onChanged: (VersionPart? value) => _updateGroupValue(value ?? VersionPart.major),
        ),
        RadioListTile(
          title: Text(VersionPart.minor.description),
          value: VersionPart.minor,
          groupValue: _selectedPart,
          onChanged: (VersionPart? value) => _updateGroupValue(value ?? VersionPart.minor),
        ),
        RadioListTile(
          title: Text(VersionPart.patch.description),
          value: VersionPart.patch,
          groupValue: _selectedPart,
          onChanged: (VersionPart? value) => _updateGroupValue(value ?? VersionPart.patch),
        ),
      ],
    );
  }

  /// Updates the selected part of the version
  void _updateGroupValue(VersionPart value) {
    widget.onSelected(value);
    setState(() {
      _selectedPart = value;
    });
  }
}

enum VersionPart {
  major('Major'),
  minor('Minor'),
  patch('Patch');

  final String description;

  const VersionPart(this.description);
}
