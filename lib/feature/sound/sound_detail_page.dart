import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/feature/sound/sound_file_entries.dart';
import 'package:stelaris/feature/sound/sound_general_page.dart';

/// The detail view reached by tapping a sound event card in [SoundPage].
///
/// Shows the shared [ModelDetailShell] back row, with a `TabBar`/
/// `TabBarView` (General/Entries) below it as the body. Each tab renders
/// one of the existing, unchanged [SoundGeneralPage]/[SoundFileEntryPage]
/// widgets, which already read the selected sound event from Redux
/// themselves.
class SoundDetailPage extends StatelessWidget {
  const SoundDetailPage({super.key});

  static const List<Tab> _tabs = [
    Tab(text: 'General'),
    Tab(text: 'Entries'),
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _SoundDetailView>(
      vm: () => _SoundDetailFactory(),
      onDispose: (store) =>
          store.dispatch(RemoveSelectedSoundEvent(), notify: false),
      builder: (context, vm) => ModelDetailShell(
        parentRoute: NavigationEntry.sound.route,
        title: vm.title,
        body: DefaultTabController(
          length: _tabs.length,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBar(tabs: _tabs),
              Expanded(
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
      ),
    );
  }
}

class _SoundDetailView extends Vm {
  _SoundDetailView({required this.title}) : super(equals: [title]);

  final String? title;
}

class _SoundDetailFactory
    extends VmFactory<AppState, SoundDetailPage, _SoundDetailView> {
  @override
  _SoundDetailView fromStore() =>
      _SoundDetailView(title: state.selectedSoundEvent?.uiName);
}
