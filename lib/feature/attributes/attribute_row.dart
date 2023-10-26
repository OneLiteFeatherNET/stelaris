import 'package:flutter/material.dart';

import '../base/base_layout.dart';

class AttributeRow extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const AttributeRow({
    required this.controller,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          // Add your Row children here
          Text(label),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: TextFormField(
                controller: controller,
              ),
            ),
          )
        ],
      ),
    );
  }
}
