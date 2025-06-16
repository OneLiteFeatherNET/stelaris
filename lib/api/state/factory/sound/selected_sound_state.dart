import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:stelaris/api/model/sound/sound_event_model.dart';
import 'package:stelaris/api/model/sound/sound_file_source.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/sound/sound_general_page.dart';

/// The [SelectedSoundState] is a factory class that creates a view model for the currently selected sound event.
/// It extends [VmFactory] and is used to provide the selected sound event's details to the view.
class SelectedSoundState
    extends VmFactory<AppState, SoundGeneralPage, SelectedSoundView> {
  SelectedSoundState();

  @override
  SelectedSoundView fromStore() =>
      SelectedSoundView(selected: state.selectedSoundEvent!);
}

/// The [SelectedSoundView] is a view model that represents the currently selected sound event.
/// It extends [Vm] and provides properties to access the selected sound event's details.
///
/// It includes additional methods to help determine if the selected sound event has associated sound files
class SelectedSoundView extends Vm {
  SelectedSoundView({required this.selected}) : super(equals: [selected]);

  final SoundEventModel selected;

  /// Returns a boolean indicator if the selected sound event contains sound files or not.
  bool get hasNoFiles => selected.files == null || selected.files!.isEmpty;

  /// Returns a list of sound file sources associated with the selected sound event.
  List<SoundFileSource> get sources => selected.files ?? <SoundFileSource>[];

  /// Returns the count of sound files associated with the selected sound event.
  int get fileCount => selected.files?.length ?? 0;

  /// Provides access to a specific sound file source by its index.
  /// If the index is out of bounds, it throws a [RangeError].
  SoundFileSource operator [](int index) {
    if (index < 0 || index >= fileCount) {
      throw RangeError.index(index, sources, 'index', null, fileCount);
    }
    return sources[index]; // Example usage, can be modified as needed
  }
}
