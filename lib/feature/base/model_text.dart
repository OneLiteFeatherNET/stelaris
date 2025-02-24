import 'package:flutter/material.dart';
import 'package:stelaris/util/constants.dart';

class ModelText extends StatelessWidget {
  const ModelText({
    required this.displayName,
    super.key,
  });

  final String? displayName;

  @override
  Widget build(BuildContext context) {
    return Text(
      displayName ?? unknownEntry,
      overflow: TextOverflow.ellipsis,
    );
  }
}
