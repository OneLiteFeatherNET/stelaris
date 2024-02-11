import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/util/constants.dart';

class AttributeRow extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputFormatter? formatter;

  const AttributeRow({
    required this.controller,
    required this.label,
    this.formatter,
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
          horizontalSpacing10,
          Expanded(
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: TextFormField(
                maxLength: maxInputLength,
                inputFormatters: formatter != null ? [formatter!] : null,
                controller: controller,
              ),
            ),
          )
        ],
      ),
    );
  }
}
