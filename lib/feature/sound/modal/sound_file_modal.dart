import 'package:flutter/material.dart';
import 'package:stelaris/feature/base/button/cancel_button.dart';
import 'package:stelaris/feature/sound/modal/section/integer_fields_section.dart';
import 'package:stelaris/feature/sound/modal/section/sound_switch_section.dart';
import 'package:stelaris/feature/sound/modal/section/volume_section.dart';

class SoundFileModal extends StatefulWidget {
  final void Function({
    required double volume,
    required double pitch,
    required int weight,
    required bool stream,
    required int attenuationDistance,
    required bool preload,
    required String type,
  })?
      onSave;

  final bool create;

  const SoundFileModal({required this.create, required this.onSave, super.key});

  @override
  State<SoundFileModal> createState() => _SoundFileModalState();
}

class _SoundFileModalState extends State<SoundFileModal> {
  double _volume = 1;
  double _pitch = 1;
  int _weight = 1;
  bool _stream = true;
  int _attenuationDistance = 16;
  bool _preload = false;
  String _type = 'file';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final surfaceVariant = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.create ? 'Create Sound' : 'Edit Sound',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                // Section 1: Volume & Pitch
                VolumeSection(
                  initialPitch: _pitch,
                  initialVolume: _volume,
                  onPitchFinalized: (v) => setState(() => _pitch = v),
                  onVolumeFinalized: (v) => setState(() => _volume = v),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: IntegerFieldsSection(
                    initialWeight: _weight,
                    initialAttenuationDistance: _attenuationDistance,
                    onWeightChanged: (v) => setState(() => _weight = v),
                    onAttenuationDistanceChanged: (v) =>
                        setState(() => _attenuationDistance = v),
                  ),
                ),
                const SizedBox(height: 16),
                // Section 3: Switches
                SwitchesSection(
                  streamValue: _stream,
                  onStreamChanged: (v) => setState(() => _stream = v),
                  preloadValue: _preload,
                  onPreloadChanged: (v) => setState(() => _preload = v),
                  backgroundColor: surfaceVariant, // Pass the color
                ),
                const SizedBox(height: 16),
                // Section 4: Type dropdown
                Container(
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'file', child: Text('File')),
                      DropdownMenuItem(value: 'event', child: Text('Event')),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'file'),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CancelButton(callback: () => Navigator.pop(context)),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          widget.onSave?.call(
                            volume: _volume,
                            pitch: _pitch,
                            weight: _weight,
                            stream: _stream,
                            attenuationDistance: _attenuationDistance,
                            preload: _preload,
                            type: _type,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
