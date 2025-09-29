import 'package:flutter/material.dart';
import 'package:stelaris/feature/sound/modal/section/base_section.dart';
import 'package:stelaris/feature/sound/modal/section/sound_slider.dart';

/// A dedicated section for controlling sound volume and pitch settings.
///
/// `VolumeSection` provides a visually grouped pair of sliders for adjusting
/// the volume and pitch of a sound. It manages the immediate state of these
/// sliders and reports the finalized values back to its parent widget
/// when the user finishes interacting with a slider.
///
/// This widget is typically used within modals or settings panels where
/// detailed sound properties need to be configured. It applies a distinct
/// background and padding to visually separate these controls.
///
class VolumeSection extends StatefulWidget {
  const VolumeSection({
    required this.initialVolume,
    required this.initialPitch,
    required this.onVolumeFinalized,
    required this.onPitchFinalized,
    super.key,
  });

  final double initialVolume;
  final double initialPitch;
  final ValueChanged<double> onVolumeFinalized;
  final ValueChanged<double> onPitchFinalized;

  @override
  State<VolumeSection> createState() => _VolumeSectionState();
}

class _VolumeSectionState extends State<VolumeSection> {
  late double _currentVolume;
  late double _currentPitch;

  @override
  void initState() {
    super.initState();
    _currentVolume = widget.initialVolume;
    _currentPitch = widget.initialPitch;
  }

  @override
  Widget build(BuildContext context) {
    return BaseSection(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SoundSliderRow(
            label: 'Volume',
            value: _currentVolume,
            onChanged: (newVolume) {
              setState(() {
                _currentVolume = newVolume;
              });
            },
            onChangeEnd:
                widget.onVolumeFinalized, // Pass through the finalized callback
          ),
          const SizedBox(height: 12), // Your existing spacer
          SoundSliderRow(
            label: 'Pitch',
            value: _currentPitch,
            onChanged: (newPitch) {
              setState(() {
                _currentPitch = newPitch;
              });
            },
            onChangeEnd:
                widget.onPitchFinalized, // Pass through the finalized callback
          ),
        ],
      ),
    );
  }
}
