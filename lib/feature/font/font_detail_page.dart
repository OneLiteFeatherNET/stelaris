import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/font/chars/font_char_page.dart';
import 'package:stelaris/feature/font/face/font_face_page.dart';
import 'package:stelaris/feature/font/font_general_page.dart';
import 'package:stelaris/feature/model/model_detail_back_bar.dart';

/// The detail view reached by tapping a font card in [FontPage].
///
/// The back arrow and the tab bar (General/FontFace/Chars) share a single
/// row instead of stacking a separate title row above the tabs, to keep the
/// header compact. Each tab renders one of the existing, unchanged
/// [FontGeneralPage]/[FontFacePage]/[FontCharPage] widgets, which already
/// read the selected font from Redux themselves.
class FontDetailPage extends StatelessWidget {
  const FontDetailPage({super.key});

  static const List<Tab> _tabs = [
    Tab(text: 'General'),
    Tab(text: 'FontFace'),
    Tab(text: 'Chars'),
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _FontDetailCleanupView>(
      vm: () => _FontDetailCleanupFactory(),
      onDispose: (store) => store.dispatch(RemoveSelectedFont(), notify: false),
      builder: (context, vm) => DefaultTabController(
        length: _tabs.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  ModelDetailBackBar(parentRoute: NavigationEntry.font.route),
                  const Expanded(child: TabBar(tabs: _tabs)),
                ],
              ),
            ),
            const Expanded(
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
    );
  }
}

class _FontDetailCleanupView extends Vm {
  _FontDetailCleanupView() : super(equals: const []);
}

class _FontDetailCleanupFactory
    extends VmFactory<AppState, FontDetailPage, _FontDetailCleanupView> {
  @override
  _FontDetailCleanupView fromStore() => _FontDetailCleanupView();
}
