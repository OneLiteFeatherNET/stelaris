import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/item/components/schema/schema_value.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The input of an RGB color as `#RRGGBB`, with a preview of the color.
class ColorField extends StatelessWidget {
  const ColorField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String? label;
  final int value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFF000000 | value),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            initialValue: colorHex(value),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: label ?? context.l10n.component_field_color,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
              LengthLimitingTextInputFormatter(7),
            ],
            validator: (input) => _parseHex(input) == null
                ? context.l10n.component_color_invalid
                : null,
            onChanged: (input) {
              final rgb = _parseHex(input);
              if (rgb != null) onChanged(rgb);
            },
          ),
        ),
      ],
    );
  }

  static int? _parseHex(String? input) {
    final hex = input?.replaceFirst('#', '');
    if (hex == null || hex.length != 6) return null;
    return int.tryParse(hex, radix: 16);
  }
}
