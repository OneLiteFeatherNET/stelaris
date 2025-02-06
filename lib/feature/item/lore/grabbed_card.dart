import 'package:flutter/material.dart';
import 'package:stelaris/util/constants.dart';

class GrabbedCard extends StatelessWidget {
  final Widget child;

  const GrabbedCard({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: Theme.of(context).colorScheme.secondary
        ),
        borderRadius: borderRadius12
      ),
      child: child,
    );
  }
}
