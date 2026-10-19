import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/service/client/sound_client_api.dart';
import 'package:stelaris/api/state/app_state.dart';

class InitSoundFileAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    if (state.selectedSoundEvent == null) return null;

    final SoundEventModel model = state.selectedSoundEvent!;

    if (model.files.items.isNotEmpty) return null;

    final soundClient = ApiService().soundApi as SoundClientApi;
    final PaginatedResult<SoundFileSource> files = await soundClient.getFiles(
      model.id!,
    );

    // Another sound event was selected, or its files changed, while they
    // loaded, so the page no longer belongs to them.
    final SoundEventModel? current = _stillSelected(state, model);
    if (current == null || !identical(current.files, model.files)) {
      return null;
    }

    return state.copyWith(
      selectedSoundEvent: current.copyWith(
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
    final SoundClientApi soundApi = ApiService().soundApi as SoundClientApi;
    final SoundFileSource linkedFile = await soundApi.linkFile(
      soundModel.id!,
      source,
    );

    final SoundEventModel? current = _stillSelected(state, soundModel);
    if (current == null) return null;

    // Create a new PaginatedResult with the new list and updated counts
    final PaginatedResult<SoundFileSource>
    updatedSources = current.files.copyWith(
      items: [...current.files.items, linkedFile],
      totalItems: current.files.totalItems + 1, // Adjust counts as necessary
      // Potentially update totalPages if this new item pushes it to a new page
    );
    return state.copyWith(
      selectedSoundEvent: current.copyWith(files: updatedSources),
    );
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
    final SoundFileSource updatedFile = await soundApi.updateFile(
      soundModel.id!,
      soundFile,
    );

    final SoundEventModel? current = _stillSelected(state, soundModel);
    if (current == null) return null;

    // Create a new list with the updated item
    final List<SoundFileSource> list = List.of(current.files.items);
    final int index = list.indexWhere((file) => file.id == updatedFile.id);
    if (index != -1) {
      list[index] = updatedFile;
    }

    // Create a new PaginatedResult with the updated list
    final PaginatedResult<SoundFileSource> updatedSources = current.files
        .copyWith(items: list);

    return state.copyWith(
      selectedSoundEvent: current.copyWith(files: updatedSources),
    );
  }
}

class SoundFileSourceDeleteAction extends ReduxAction<AppState> {
  final SoundFileSource soundFile;

  SoundFileSourceDeleteAction(this.soundFile);

  @override
  Future<AppState?> reduce() async {
    if (state.selectedSoundEvent == null) return null;

    final SoundEventModel model = state.selectedSoundEvent!;
    final soundClient = ApiService().soundApi as SoundClientApi;

    final SoundFileSource deletedFile = await soundClient.deleteFile(
      model.id!,
      soundFile,
    );

    final SoundEventModel? current = _stillSelected(state, model);
    if (current == null) return null;

    final PaginatedResult<SoundFileSource> entries = current.files;

    final List<SoundFileSource> updatedFiles = List.of(
      entries.items,
      growable: true,
    );
    updatedFiles.removeWhere((file) => file.id == deletedFile.id);

    final updatedSoundEvent = current.copyWith(
      files: entries.copyWith(
        items: updatedFiles,
        currentPage: entries.currentPage,
        totalPages: entries.totalPages,
        totalItems: entries.totalItems - 1,
      ),
    );

    return state.copyWith(selectedSoundEvent: updatedSoundEvent);
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

    // Another sound event was selected, or its files changed, while the
    // page loaded, so the page no longer continues them.
    final SoundEventModel? current = _stillSelected(state, model);
    if (current == null || !identical(current.files, model.files)) {
      return null;
    }

    final PaginatedResult<SoundFileSource> entries = model.files;

    final updatedSoundEvent = current.copyWith(
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
    return state.copyWith(
      selectedSoundEvent: sel.copyWith(isLoading: isLoading),
    );
  }
}

/// The selected sound event when it is still [model], as it is now. A
/// request made for [model] applies to it, so form edits made while the
/// request ran are kept. Null when another sound event was selected
/// meanwhile, which the response doesn't belong to.
SoundEventModel? _stillSelected(AppState state, SoundEventModel model) {
  final SoundEventModel? current = state.selectedSoundEvent;
  return current != null && current.id == model.id ? current : null;
}
