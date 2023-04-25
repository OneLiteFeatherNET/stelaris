import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/constants.dart';

class ModelText extends StatelessWidget {

  final String? displayName;

  const ModelText({Key? key, required this.displayName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      displayName ?? unknownEntry,
      overflow: TextOverflow.ellipsis,
    );
  }
}
