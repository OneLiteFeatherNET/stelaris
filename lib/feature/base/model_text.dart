import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/constants.dart';

class ModelText extends StatelessWidget {

  final String? displayName;

  const ModelText({super.key, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Text(
      displayName ?? unknownEntry,
      overflow: TextOverflow.ellipsis,
    );
  }
}
