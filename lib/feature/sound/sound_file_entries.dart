import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/service/sound/sound_file_loader.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_file_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/sound/selected_sound_state.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/model/model_grid.dart';
import 'package:stelaris/feature/sound/card/sound_file_card.dart';
import 'package:stelaris/feature/sound/modal/sound_file_modal_helper.dart';
import 'package:stelaris/feature/sound/playback/sound_decoder.dart';
import 'package:stelaris/feature/sound/playback/sound_file_player.dart';
import 'package:stelaris/feature/sound/playback/sound_playback_controller.dart';
import 'package:stelaris/feature/sound/playback/sound_player.dart';
import 'package:stelaris/util/l10n_ext.dart';

class SoundFileEntryPage extends StatefulWidget {
  const SoundFileEntryPage({this.playback, this.soundAssetNames, super.key});

  /// Plays the files; when null the page keeps its own over
  /// [ApiService.soundFileLoader] and the browser's audio.
  final SoundPlaybackController? playback;

  /// The display names of the sound assets of a project by their id; when
  /// null they are read from [AssetLibrary.shared].
  final Future<Map<String, String>> Function(String projectId)? soundAssetNames;

  @override
  State<SoundFileEntryPage> createState() => _SoundFileEntriesState();
}

/// The sound files of the selected sound event, as cards in the grid of the
/// model pages, each with a player when it has uploaded audio.
class _SoundFileEntriesState extends State<SoundFileEntryPage> {
  SoundPlaybackController? _ownPlayback;

  SoundPlaybackController get _playback =>
      widget.playback ??
      (_ownPlayback ??= SoundPlaybackController(
        loader: ApiService().soundFileLoader,
        player: SoundPlayer(),
        decoder: SoundDecoder(),
      ));

  /// The display names of the sound assets of [_namesProject] by id, and
  /// the ids already asked for, so an asset uploaded later reads them again
  /// once.
  String? _namesProject;
  Map<String, String> _assetNames = const {};
  final Set<String> _askedAssetIds = {};
  bool _loadingNames = false;

  /// The ids of the names being read.
  Set<String> _pendingAssetIds = const {};

  @override
  void dispose() {
    _ownPlayback?.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _readAssetNames(String projectId) async {
    final read = widget.soundAssetNames;
    if (read != null) return read(projectId);
    final assets = await AssetLibrary.shared.assetsOf(
      projectId,
      AssetKind.SOUND,
    );
    return {for (final asset in assets) asset.id: asset.displayName};
  }

  /// Reads the asset names when [sources] link an asset not asked for yet.
  void _loadAssetNamesFor(String? projectId, List<SoundFileSource> sources) {
    if (projectId == null || _loadingNames) return;
    if (projectId != _namesProject) {
      _namesProject = projectId;
      _assetNames = const {};
      _askedAssetIds.clear();
    }
    final missing = {
      for (final source in sources)
        if (source.assetId case final id?)
          if (!_askedAssetIds.contains(id)) id,
    };
    if (missing.isEmpty) return;
    _askedAssetIds.addAll(missing);
    _pendingAssetIds = missing;
    _loadingNames = true;
    _readAssetNames(projectId)
        .then((names) {
          if (!mounted || _namesProject != projectId) return;
          setState(() => _assetNames = names);
        })
        .catchError((Object e) {
          // Without names the cards show the keys, which still name the files.
          debugPrint('Sound asset names failed: $e');
        })
        .whenComplete(() {
          _loadingNames = false;
          if (mounted) setState(() => _pendingAssetIds = const {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedSoundView>(
      vm: () => SelectedSoundState(),
      onInit: (store) => store.dispatch(InitSoundFileAction()),
      builder: (context, vm) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader.small(
                title: context.l10n.tab_entries,
                actions: [
                  PageHeaderAction(
                    key: const Key('sound_files_save'),
                    icon: const Icon(Icons.save_outlined),
                    label: context.l10n.button_save,
                    onPressed: () => context.dispatch(SoundDatabaseUpdate()),
                  ),
                  PageHeaderAction(
                    key: const Key('sound_files_add'),
                    icon: const Icon(Icons.add),
                    label: context.l10n.button_add,
                    primary: true,
                    onPressed: () => _openModal(create: true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              vm.hasNoFiles
                  ? const Flexible(child: EmptyDataWidget())
                  : Expanded(child: _buildGrid(vm)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(SelectedSoundView vm) {
    final projectId = StoreProvider.state<AppState>(context)
        .selectedProject
        ?.id;
    _loadAssetNamesFor(projectId, vm.sources);
    return ModelGrid<SoundFileSource>(
      items: vm.sources,
      cardHeight: SoundFileCard.height,
      hasMore: vm.hasNextPage,
      isLoadingMore: vm.isLoadingFiles,
      onLoadMore: vm.onLoadMoreSoundFiles,
      // Rebuilt as the waveforms arrive, so each card shows once its own is
      // there.
      itemBuilder: (context, source) => ListenableBuilder(
        key: ValueKey(source.id ?? source.name),
        listenable: _playback,
        builder: (context, _) => SoundFileCard(
          source: source,
          assetName: _assetNames[source.assetId],
          loading: projectId != null && _isLoading(projectId, source),
          onEdit: () => _openModal(create: false, source: source),
          onDelete: () => _confirmAndDelete(source),
          // Only an uploaded file has audio: an event names another sound
          // event, a file without asset e.g. a vanilla sound.
          player: projectId != null && _isPlayable(source)
              ? SoundFilePlayer(
                  controller: _playback,
                  projectId: projectId,
                  source: source,
                  onToggle: () => _togglePlay(source),
                )
              : null,
        ),
      ),
    );
  }

  /// Opens the dialog of a file. It stops what plays first: the sound would
  /// keep its old volume and pitch while they are edited.
  void _openModal({required bool create, SoundFileSource? source}) {
    _playback.stop();
    showSoundFileModal(context: context, create: create, source: source);
  }

  /// Whether the card of [source] still waits for its waveform or its asset
  /// name; it starts reading the waveform. A failed read lets the card show.
  bool _isLoading(String projectId, SoundFileSource source) {
    if (_isPlayable(source) && !_playback.isWaveformSettled(source)) {
      _playback.waveformOf(projectId, source).ignore();
      return true;
    }
    final assetId = source.assetId;
    if (assetId == null || _assetNames.containsKey(assetId)) return false;
    return _pendingAssetIds.contains(assetId) ||
        !_askedAssetIds.contains(assetId);
  }

  static bool _isPlayable(SoundFileSource source) =>
      source.type == 'file' && source.assetId != null;

  Future<void> _togglePlay(SoundFileSource source) async {
    final projectId = StoreProvider.state<AppState>(context)
        .selectedProject
        ?.id;
    if (projectId == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await _playback.toggle(projectId, source);
    } on SoundFileUnavailableException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.sound_play_unavailable(e.key))),
      );
    } catch (e) {
      debugPrint('Sound playback failed: $e');
      messenger.showSnackBar(SnackBar(content: Text(l10n.sound_play_failed)));
    }
  }

  Future<void> _confirmAndDelete(SoundFileSource source) async {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(context.l10n.sound_file_delete_title),
        content: Text(context.l10n.sound_file_delete_body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.button_cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              context.dispatch(SoundFileSourceDeleteAction(source));
            },
            child: Text(context.l10n.button_delete),
          ),
        ],
      ),
    );
  }
}
