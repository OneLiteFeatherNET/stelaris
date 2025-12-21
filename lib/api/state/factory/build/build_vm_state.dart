import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/release/release_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/build/build_drawer.dart';

class BuildStateFactory extends VmFactory<AppState, BuildDrawer, BuildViewModel> {

  BuildStateFactory();

  @override
  BuildViewModel fromStore() => BuildViewModel(releaseModel: state.releaseModel!);
}

class BuildViewModel extends Vm {

  BuildViewModel({required this.releaseModel}) : super(equals: [releaseModel]);

  final ReleaseModel releaseModel;

}
