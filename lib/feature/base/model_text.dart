import 'package:flutter/material.dart';
import 'package:stelaris/util/constants.dart';

class ModelText extends StatelessWidget {
  final String? displayName;

  const ModelText({
    required this.displayName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      displayName ?? unknownEntry,
      overflow: TextOverflow.ellipsis,
    );
  }
}
