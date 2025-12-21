import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/release/release_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/build/build_dialog.dart';

class BuildStateFactory extends VmFactory<AppState, BuildDialog, BuildViewModel> {

  BuildStateFactory();

  @override
  BuildViewModel fromStore() => BuildViewModel(
        releaseModel: state.releaseModel,
        branches: state.branches,
      );
}

class BuildViewModel extends Vm {
  BuildViewModel({
    required this.releaseModel,
    required this.branches,
  }) : super(equals: [releaseModel, branches]);

  final ReleaseModel? releaseModel;
  final List<String> branches;

  String get version => releaseModel == null ? '0.0.1' : releaseModel!.version;
}
