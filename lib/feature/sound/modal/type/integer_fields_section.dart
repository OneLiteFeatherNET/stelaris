import 'package:flutter/material.dart';
import 'package:stelaris/feature/sound/modal/section/base_section.dart';
import 'package:stelaris/feature/sound/modal/section/base_integer_section_field.dart';

class IntegerFieldsSection extends StatelessWidget {
  final int weight;
  final int attenuation;
  final int minValue;
  final ValueChanged<int> onWeightChanged;
  final ValueChanged<int> onAttenuationChanged;

  const IntegerFieldsSection({
    required this.weight,
    required this.attenuation,
    required this.onWeightChanged,
    required this.onAttenuationChanged,
    this.minValue = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BaseSection(
      child: Column(
        children: [
          BaseIntegerField(
            label: 'Weight',
            initialValue: weight,
            minValue: minValue,
            onChanged: onWeightChanged,
          ),
          const SizedBox(height: 12),
          BaseIntegerField(
            label: 'Attenuation Distance',
            initialValue: attenuation,
            minValue: minValue,
            onChanged: onAttenuationChanged,
          ),
        ],
      ),
    );
  }
}
