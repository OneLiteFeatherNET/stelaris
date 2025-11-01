import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/sound/sound_event_model.dart';
import 'package:stelaris/api/model/sound/sound_file_source.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/api/service/client/sound_client_api.dart';
import 'package:stelaris/api/state/app_state.dart';

class InitSoundFileAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    if (state.selectedSoundEvent == null) return null;

    final SoundEventModel model = state.selectedSoundEvent!;

    if (model.files.items.isNotEmpty) return null;

    final soundClient = ApiService().soundApi as SoundClientApi;
    final PaginatedResult<SoundFileSource> files = await soundClient.getFiles(model.id!);
    return state.copyWith(
      selectedSoundEvent: model.copyWith(
        files: model.files.copyWith(
          items: List.of(model.files.items, growable: true)
            ..addAll(files.items),
          currentPage: files.currentPage,
          totalPages: files.totalPages,
          totalItems: files.totalItems,
        ),
      ),
    );
  }
}

class SoundFileLinkAction extends ReduxAction<AppState> {

  final SoundFileSource source;

  SoundFileLinkAction(this.source);

  @override
  Future<AppState?> reduce() async {
    if (state.selectedSoundEvent == null) return null;

    final SoundEventModel soundModel = state.selectedSoundEvent!;
    final List<SoundFileSource> list = List.of(soundModel.files.items, growable: true);
    final SoundClientApi soundApi = ApiService().soundApi as SoundClientApi;
    final SoundFileSource linkedFile = await soundApi.linkFile(soundModel.id!, source);

    list.add(linkedFile);

    // Create a new PaginatedResult with the new list and updated counts
    final PaginatedResult<SoundFileSource> updatedSources = soundModel.files.copyWith(
      items: list,
      totalItems: soundModel.files.totalItems + 1, // Adjust counts as necessary
      // Potentially update totalPages if this new item pushes it to a new page
    );
    return state.copyWith(selectedSoundEvent: soundModel.copyWith(files: updatedSources));

  }
}

class SoundFileUpdateAction extends ReduxAction<AppState> {
  final SoundFileSource soundFile;

  SoundFileUpdateAction(this.soundFile);

  @override
  Future<AppState?> reduce() async {
    if (state.selectedSoundEvent == null) return null;

    final SoundEventModel soundModel = state.selectedSoundEvent!;
    final SoundClientApi soundApi = ApiService().soundApi as SoundClientApi;

    // Call the API to update the file
    final SoundFileSource updatedFile = await soundApi.updateFile(soundModel.id!, soundFile);

    // Create a new list with the updated item
    final List<SoundFileSource> list = List.of(soundModel.files.items);
    final int index = list.indexWhere((file) => file.id == updatedFile.id);
    if (index != -1) {
      list[index] = updatedFile;
    }

    // Create a new PaginatedResult with the updated list
    final PaginatedResult<SoundFileSource> updatedSources = soundModel.files.copyWith(
      items: list,
    );

    return state.copyWith(selectedSoundEvent: soundModel.copyWith(files: updatedSources));
  }
}


class LoadMoreSoundFiles extends ReduxAction<AppState> {
  LoadMoreSoundFiles({required this.pageToLoad, this.pageSize = 1});

  final int pageToLoad;
  final int pageSize;

  @override
  void before() {
    dispatch(SetSelectedSoundLoading(true));
  }

  @override
  void after() {
    dispatch(SetSelectedSoundLoading(false));
  }

  @override
  Future<AppState?> reduce() async {
    if (state.selectedSoundEvent == null) return null;

    final SoundEventModel model = state.selectedSoundEvent!;
    final soundClient = ApiService().soundApi as SoundClientApi;
    final PaginatedResult<SoundFileSource> files = await soundClient.getFiles(
      model.id!,
      pageToLoad,
      pageSize,
    );
    final PaginatedResult<SoundFileSource> entries = model.files;

    final updatedSoundEvent = model.copyWith(
      files: entries.copyWith(
        items: List.of(entries.items, growable: true)..addAll(files.items),
        currentPage: files.currentPage,
        totalPages: files.totalPages,
        totalItems: files.totalItems,
      ),
    );

    return state.copyWith(selectedSoundEvent: updatedSoundEvent);
  }
}

class SetSelectedSoundLoading extends ReduxAction<AppState> {
  SetSelectedSoundLoading(this.isLoading);

  final bool isLoading;

  @override
  AppState? reduce() {
    final sel = state.selectedSoundEvent;
    if (sel == null) return null;
    return state.copyWith(selectedSoundEvent: sel.copyWith(isLoading: isLoading));
  }
}
