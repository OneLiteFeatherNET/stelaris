import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/sound/modal/section/base_integer_section_field.dart';
import 'package:stelaris/feature/sound/modal/section/sound_slider.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';

class SoundFileModal extends StatefulWidget {
  const SoundFileModal({
    required this.create,
    required this.onSave,
    this.initialData,
    super.key,
  });

  final void Function(SoundFileSource soundFile)? onSave;
  final bool create;
  final SoundFileSource? initialData;

  @override
  State<SoundFileModal> createState() => _SoundFileModalState();
}

class _SoundFileModalState extends State<SoundFileModal> {
  late final TextEditingController _nameController;
  late double _volume;
  late double _pitch;
  late int _weight;
  late int _attenuationDistance;
  late bool _preload;
  late String _type;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController = TextEditingController(text: data?.name ?? '');
    _volume = data?.volume ?? 1;
    _pitch = data?.pitch ?? 1;
    _weight = data?.weight ?? 1;
    _attenuationDistance = data?.attenuationDistance ?? 16;
    _preload = data?.preload ?? false;
    _type = data?.type ?? 'file';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final headingStyle = Theme.of(context).textTheme.titleSmall;

    return FormDialog(
      title: widget.create ? l10n.sound_create : l10n.sound_edit,
      actionIcon: widget.create ? Icons.add : Icons.save_outlined,
      actionLabel: l10n.button_save,
      minWidth: 400,
      onSubmit: _handleSave,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: widget.create,
              decoration: InputDecoration(
                labelText: l10n.sound_name,
                hintText: l10n.sound_name_hint,
              ),
              validator: Validators.required(
                l10n.validation_field_required(l10n.sound_name),
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'file',
                  label: Text(l10n.sound_type_file),
                ),
                ButtonSegment(
                  value: 'event',
                  label: Text(l10n.sound_type_event),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) =>
                  setState(() => _type = selection.first),
            ),
            const SizedBox(height: 24),
            Text(l10n.sound_section_volume_pitch, style: headingStyle),
            const SizedBox(height: 8),
            SoundSliderRow(
              label: l10n.sound_volume,
              value: _volume,
              onChanged: (v) => setState(() => _volume = v),
            ),
            SoundSliderRow(
              label: l10n.sound_pitch,
              value: _pitch,
              onChanged: (v) => setState(() => _pitch = v),
            ),
            const SizedBox(height: 16),
            Text(l10n.sound_section_weight_attenuation, style: headingStyle),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: BaseIntegerField(
                    label: l10n.sound_weight,
                    initialValue: _weight,
                    minValue: 1,
                    onChanged: (v) => _weight = v,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BaseIntegerField(
                    label: l10n.sound_attenuation_distance,
                    initialValue: _attenuationDistance,
                    minValue: 1,
                    onChanged: (v) => _attenuationDistance = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.sound_preload),
              value: _preload,
              onChanged: (v) => setState(() => _preload = v),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSave?.call(
      SoundFileSource(
        id: widget.initialData?.id,
        name: _nameController.text.trim(),
        volume: _volume,
        pitch: _pitch,
        weight: _weight,
        attenuationDistance: _attenuationDistance,
        preload: _preload,
        type: _type,
      ),
    );
    Navigator.pop(context);
  }
}
