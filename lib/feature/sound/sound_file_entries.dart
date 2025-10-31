import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/sound/sound_file_source.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_file_actions.dart';
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
  final ScrollController _scrollController = ScrollController();
  SelectedSoundView? _vm;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedSoundView>(
      vm: () => SelectedSoundState(),
      onInit: (store) => store.dispatch(InitSoundFileAction()),
      onDidChange: (context, store, viewModel) {
        _vm = viewModel;
      },
      builder: (context, vm) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            verticalSpacing25,
            _getActionWidget(context),
            const SizedBox(height: 16),
            vm.hasNoFiles
                ? const Flexible(flex: 1, child: EmptyDataWidget())
                : Expanded(
              child: _buildListView(vm),
            ),
          ]
          ,
        );
      },
    );
  }

  Widget _getActionWidget(BuildContext context) {
    return ActionChips(
      addCallback: () => _openAddDialog(),
      saveCallback: () => context.dispatch(SoundDatabaseUpdate()),
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
              required name,
              required volume,
              required pitch,
              required weight,
              required stream,
              required attenuationDistance,
              required preload,
              required type,
            }) {
              final SoundFileSource fileSource = SoundFileSource(
                name: 'Test',
                volume: volume,
                pitch: pitch,
                attenuationDistance: attenuationDistance,
                preload: preload,
                type: type,
                weight: weight,
              );
              context.dispatch(SoundFileLinkAction(fileSource));
              // Handle save logic here
            },
          ),
    );
  }

  Widget _buildListView(SelectedSoundView state) {
    final PaginatedResult<SoundFileSource> files = state.selected.files;
    final hasFooter = state.isLoadingFiles || state.hasNextPage;
    final itemCount = files.items.length + (hasFooter ? 1 : 0);
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: itemCount,
      clipBehavior: Clip.none,
      itemBuilder: (context, index) {
        if (index >= files.items.length) {
          return _buildFooter(state.isLoadingFiles);
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 220,
            maxWidth: 400,
          ),
          child: SoundFileCard(eventModel: files.items[index]),
        );
      },
    );
  }

  void _onScroll() {
    if (_vm == null) return;

    final SelectedSoundView view = _vm!;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        view.hasNextPage &&
        !view.isLoadingFiles) {
      view.onLoadMoreSoundFiles();
    }
  }

  Widget _buildFooter(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}