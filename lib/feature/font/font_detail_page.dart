import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/font/chars/font_char_page.dart';
import 'package:stelaris/feature/font/face/font_face_page.dart';
import 'package:stelaris/feature/font/font_general_page.dart';
import 'package:stelaris/feature/model/model_detail_actions.dart';
import 'package:stelaris/feature/model/model_detail_shell.dart';
import 'package:stelaris/feature/model/model_detail_tab_bar.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The detail view reached by tapping a font card in [FontPage].
///
/// Shows the shared [ModelDetailShell] header row with its actions, with a `TabBar`/
/// `TabBarView` (General/FontFace/Chars) below it as the body. Each tab
/// renders one of the existing, unchanged [FontGeneralPage]/[FontFacePage]/
/// [FontCharPage] widgets, which already read the selected font from Redux
/// themselves.
class FontDetailPage extends StatelessWidget {
  const FontDetailPage({super.key});

  static const List<Tab> _tabs = [
    Tab(text: 'General'),
    Tab(text: 'FontFace'),
    Tab(text: 'Chars'),
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _FontDetailView>(
      vm: () => _FontDetailFactory(),
      onDispose: (store) => store.dispatch(RemoveSelectedFont(), notify: false),
      builder: (context, vm) => ModelDetailShell(
        entry: NavigationEntry.font,
        title: vm.title,
        actions: [
          ModelDetailActions<FontModel>(
            entry: NavigationEntry.font,
            selectModel: (state) => state.selectedFont,
            nameSelector: (model) => model.uiName,
            keySelector: (model) => model.key ?? '',
            deleteTitle: context.l10n.dialog_font_delete_title,
            deleteWarning: context.l10n.delete_dialog_related_font,
            removeAction: FontRemoveAction.new,
          ),
        ],
        body: DefaultTabController(
          length: _tabs.length,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModelDetailTabBar(tabs: _tabs),
              Expanded(
                child: TabBarView(
                  children: [
                    FontGeneralPage(),
                    FontFacePage(),
                    FontCharPage(),
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

class _FontDetailView extends Vm {
  _FontDetailView({required this.title}) : super(equals: [title]);

  final String? title;
}

class _FontDetailFactory extends VmFactory<AppState, FontDetailPage, _FontDetailView> {
  @override
  _FontDetailView fromStore() => _FontDetailView(title: state.selectedFont?.uiName);
}
