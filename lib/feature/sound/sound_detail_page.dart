import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/feature/model/model_detail_tab_bar.dart';
import 'package:stelaris/feature/sound/sound_file_entries.dart';
import 'package:stelaris/feature/sound/sound_general_page.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The detail view reached by tapping a sound event card in [SoundPage].
///
/// Shows the shared [ModelDetailShell] header row with its actions, with a `TabBar`/
/// `TabBarView` (General/Entries) below it as the body. Each tab renders
/// one of the existing, unchanged [SoundGeneralPage]/[SoundFileEntryPage]
/// widgets, which already read the selected sound event from Redux
/// themselves.
class SoundDetailPage extends StatelessWidget {
  const SoundDetailPage({super.key});

  /// The tabs in order. Also what `?tab=` and the command palette name them by.
  static const List<String> tabs = [
    'General',
    'Entries',
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _SoundDetailView>(
      vm: () => _SoundDetailFactory(),
      onDispose: (store) =>
          store.dispatch(RemoveSelectedSoundEvent(), notify: false),
      builder: (context, vm) => ModelDetailShell(
        entry: NavigationEntry.sound,
        title: vm.title,
        actions: [
          ModelDetailActions<SoundEventModel>(
            entry: NavigationEntry.sound,
            selectModel: (state) => state.selectedSoundEvent,
            nameSelector: (model) => model.uiName,
            keySelector: (model) => model.key ?? '',
            deleteTitle: context.l10n.dialog_sound_delete_title,
            deleteWarning: context.l10n.delete_dialog_related_sound,
            removeAction: SoundRemoveAction.new,
          ),
        ],
        body: DefaultTabController(
          // Keyed by the requested tab: a new ?tab= on the same route has to
          // start a new controller, or the old tab would stay selected.
          key: ValueKey(requestedTab(context)),
          initialIndex: initialTabIndex(context, tabs),
          length: tabs.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModelDetailTabBar(
                tabs: [for (final tab in tabs) Tab(text: tab)],
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
