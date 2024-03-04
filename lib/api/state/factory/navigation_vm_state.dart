import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/base/navigation_side_bar.dart';

class NavigationStateFactory extends VmFactory<AppState, NavigationSideBar, NavigationViewModel> {

  NavigationStateFactory();

  @override
  NavigationViewModel fromStore() {
    return NavigationViewModel(openNavigation: state.openNavigation);
  }
}

/// The NavigationViewModel is a simple class that holds the state of the navigation bar.
/// It is used to determine if the navigation bar is open or closed.
class NavigationViewModel extends Vm {

  NavigationViewModel({required this.openNavigation}) : super(equals: [openNavigation]);

  final bool openNavigation;
}