import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:stelaris/api/model/sound/sound_event_model.dart';
import 'package:stelaris/api/model/sound/sound_file_source.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/api/state/actions/sound/sound_file_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/sound/sound_general_page.dart';

/// The [SelectedSoundState] is a factory class that creates a view model for the currently selected sound event.
/// It extends [VmFactory] and is used to provide the selected sound event's details to the view.
class SelectedSoundState
    extends VmFactory<AppState, SoundGeneralPage, SelectedSoundView> {
  SelectedSoundState();

  @override
  SelectedSoundView fromStore() {
    final selectedEvent = state.selectedSoundEvent;

    return SelectedSoundView(
      selected: state.selectedSoundEvent!,
      onLoadMoreSoundFiles: () {
        if (selectedEvent != null &&
            selectedEvent.id != null &&
            selectedEvent.files.hasNextPage &&
            !selectedEvent.isLoading) {
          dispatch(
            LoadMoreSoundFiles(pageToLoad: selectedEvent.files.currentPage + 1),
          );
        }
      },
    );
  }
}

/// The [SelectedSoundView] is a view model that represents the currently selected sound event.
/// It extends [Vm] and provides properties to access the selected sound event's details.
///
/// It includes additional methods to help determine if the selected sound event has associated sound files
class SelectedSoundView extends Vm {
  SelectedSoundView({
    required this.selected,
    required this.onLoadMoreSoundFiles,
  }) : super(equals: [selected, selected.files.items.length]);

  final SoundEventModel selected;
  final VoidCallback onLoadMoreSoundFiles;

  /// Returns a boolean indicator if the selected sound event contains sound files or not.
  bool get hasNoFiles => selected.files.items.isEmpty;

  /// Internal variable to hold the paginated result of sound files
  PaginatedResult<SoundFileSource> get _fileResults => selected.files;

  /// Returns a list of sound file sources associated with the selected sound event.
  List<SoundFileSource> get sources => _fileResults.items;

  /// Returns the count of sound files associated with the selected sound event.
  int get fileCount => selected.files.items.length;

  /// Indication if there are more pages of sound files to load
  bool get hasNextPage => _fileResults.hasNextPage;

  /// Returns the current page of sound files associated with the selected sound event.
  bool get isLoadingFiles => selected.isLoading;

  /// Provides access to a specific sound file source by its index.
  /// If the index is out of bounds, it throws a [RangeError].
  SoundFileSource operator [](int index) {
    if (index < 0 || index >= fileCount) {
      throw RangeError.index(index, sources, 'index', null, fileCount);
    }
    return sources[index];
  }
}
