import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/sound/sound_file_source.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/sound/selected_sound_state.dart';
import 'package:stelaris/feature/base/chips/action_chips.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/sound/card/sound_file_card.dart';
import 'package:stelaris/feature/sound/modal/sound_file_modal.dart';
import 'package:stelaris/util/constants.dart';

class SoundFileEntryPage extends StatefulWidget {
  const SoundFileEntryPage({super.key});

  @override
  State<SoundFileEntryPage> createState() => _SoundFileEntriesState();
}

class _SoundFileEntriesState extends State<SoundFileEntryPage> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedSoundView>(
        vm: () => SelectedSoundState(),
        builder: (context, vm) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              verticalSpacing25,
              _getActionWidget(context),
              const SizedBox(height: 16,),
              vm.hasNoFiles
                  ? const Flexible(flex: 1, child: const EmptyDataWidget())
                  : Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.fileCount, // Example: 10 items
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 220,
                          maxWidth: 400,
                        ),
                        child: SoundFileCard(eventModel: vm[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
    );
  }

  Widget _getActionWidget(BuildContext context) {
    return ActionChips(
      addCallback: () => _openAddDialog(),
      saveCallback: () {},
    );
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          SoundFileModal(
            create: true,
            onSave:
                ({
              required volume,
              required pitch,
              required weight,
              required stream,
              required attenuationDistance,
              required preload,
              required type,
            }) {
              // Handle save logic here
            },
          ),
    );
  }

  void _create({
    required double volume,
    required double pitch,
    required int weight,
    required bool stream,
    required int attenuationDistance,
    required bool preload,
    required String type,
  }) {
    SoundFileSource fileSource = SoundFileSource(name: 'Test',
        volume: volume,
        pitch: pitch,
        attenuationDistance: attenuationDistance,
        preload: preload,
        type: type,
        weight: weight
    );

    //context.dispatch(SelectedS)
  }
}
