import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/model_detail_back_bar.dart';
import 'package:stelaris/feature/sound/sound_file_entries.dart';
import 'package:stelaris/feature/sound/sound_general_page.dart';

/// The detail view reached by tapping a sound event card in [SoundPage].
///
/// The back arrow and the tab bar (General/Entries) share a single row,
/// followed by the unchanged [SoundGeneralPage]/[SoundFileEntryPage] tab
/// content, which read the selected sound event from Redux themselves.
class SoundDetailPage extends StatelessWidget {
  const SoundDetailPage({super.key});

  static const List<Tab> _tabs = [
    Tab(text: 'General'),
    Tab(text: 'Entries'),
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _SoundDetailCleanupView>(
      vm: () => _SoundDetailCleanupFactory(),
      onDispose: (store) =>
          store.dispatch(RemoveSelectedSoundEvent(), notify: false),
      builder: (context, vm) => DefaultTabController(
        length: _tabs.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  ModelDetailBackBar(parentRoute: NavigationEntry.sound.route),
                  const Expanded(child: TabBar(tabs: _tabs)),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  SoundGeneralPage(),
                  SoundFileEntryPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundDetailCleanupView extends Vm {
  _SoundDetailCleanupView() : super(equals: const []);
}

class _SoundDetailCleanupFactory
    extends VmFactory<AppState, SoundDetailPage, _SoundDetailCleanupView> {
  @override
  _SoundDetailCleanupView fromStore() => _SoundDetailCleanupView();
}
