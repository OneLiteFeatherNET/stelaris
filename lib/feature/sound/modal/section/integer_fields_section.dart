import 'package:flutter/material.dart';
import 'package:stelaris/feature/sound/modal/section/base_section.dart';
import 'package:stelaris/util/formatter/min_value_fomatter.dart';

class IntegerFieldsSection extends StatefulWidget {
  final int initialWeight;
  final int initialAttenuationDistance;
  final int minValue;
  final ValueChanged<int> onWeightChanged;
  final ValueChanged<int> onAttenuationDistanceChanged;

  const IntegerFieldsSection({
    required this.initialWeight,
    required this.initialAttenuationDistance,
    required this.onWeightChanged,
    required this.onAttenuationDistanceChanged,
    this.minValue = 1,
    super.key,
  });

  @override
  State<IntegerFieldsSection> createState() => _IntegerFieldsSectionState();
}

class _IntegerFieldsSectionState extends State<IntegerFieldsSection> {
  late final TextEditingController _weightController;
  late final TextEditingController _attenuationController;

  @override
  void initState() {
    super.initState();
    _weightController =
        TextEditingController(text: widget.initialWeight.toString());
    _attenuationController = TextEditingController(
        text: widget.initialAttenuationDistance.toString());
  }

  @override
  void dispose() {
    _weightController.dispose();
    _attenuationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseSection(
      child: Column(
        children: [
          TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight',
              border: OutlineInputBorder(),
            ),
            inputFormatters: [
              MinValueFormatter(widget.minValue)
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter a weight';
              final val = int.tryParse(v);
              if (val == null) return 'Enter a valid integer';
              return null;
            },
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null) widget.onWeightChanged(parsed);
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _attenuationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Attenuation Distance',
              border: OutlineInputBorder(),
            ),
            inputFormatters: [
              MinValueFormatter(widget.minValue)
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter a distance';
              final val = int.tryParse(v);
              if (val == null) return 'Enter a valid integer';
              return null;
            },
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null) widget.onAttenuationDistanceChanged(parsed);
            },
          ),
        ],
      ),
    );
  }
}
