import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';

extension SectionNavigation on BuildContext {
  /// Goes to the list of [entry], below the selected project when the
  /// section is project-scoped (see [sectionLocation]).
  void goToSection(NavigationEntry entry) {
    final String? projectId = StoreProvider.state<AppState>(
      this,
      notify: false,
    ).selectedProject?.id;
    go(sectionLocation(entry, projectId));
  }
}
