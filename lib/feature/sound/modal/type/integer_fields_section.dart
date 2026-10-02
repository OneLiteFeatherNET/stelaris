import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/sound/modal/section/base_section.dart';
import 'package:stelaris/feature/sound/modal/section/base_integer_section_field.dart';
import 'package:stelaris/util/l10n_ext.dart';

class IntegerFieldsSection extends StatelessWidget {
  final int weight;
  final int attenuation;
  final int minValue;
  final ValueChanged<int> onWeightChanged;
  final ValueChanged<int> onAttenuationChanged;
  final bool dense;

  const IntegerFieldsSection({
    required this.weight,
    required this.attenuation,
    required this.onWeightChanged,
    required this.onAttenuationChanged,
    this.minValue = 1,
    this.dense = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final verticalGap = dense ? 8.0 : 12.0;
    return BaseSection(
      title: context.l10n.sound_section_weight_attenuation,
      padding: dense ? const EdgeInsets.all(16) : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canRow = !dense && constraints.maxWidth >= 520;
          if (canRow) {
            return Row(
              children: [
                Expanded(
                  child: BaseIntegerField(
                    label: context.l10n.sound_weight,
                    initialValue: weight,
                    minValue: minValue,
                    onChanged: onWeightChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BaseIntegerField(
                    label: context.l10n.sound_attenuation_distance,
                    initialValue: attenuation,
                    minValue: minValue,
                    onChanged: onAttenuationChanged,
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              BaseIntegerField(
                label: context.l10n.sound_weight,
                initialValue: weight,
                minValue: minValue,
                onChanged: onWeightChanged,
              ),
              SizedBox(height: verticalGap),
              BaseIntegerField(
                label: context.l10n.sound_attenuation_distance,
                initialValue: attenuation,
                minValue: minValue,
                onChanged: onAttenuationChanged,
              ),
            ],
          );
        },
      ),
    );
  }
}
