import 'dart:ui';

import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/build/build_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/build/build_dialog.dart';

class BuildStateFactory
    extends VmFactory<AppState, BuildDialog, BuildViewModel> {
  BuildStateFactory();

  @override
  BuildViewModel fromStore() => BuildViewModel(
    releaseModel: state.releaseModel,
    branches: state.branches,
    isLoadingRelease: state.isLoadingRelease,
    isLoadingBranches: state.isLoadingBranches,
    projectId: state.selectedProject?.id,
    onRefreshBranches: () => dispatch(BranchFetchAction()),
  );
}

class BuildViewModel extends Vm {
  BuildViewModel({
    required this.releaseModel,
    required this.branches,
    required this.isLoadingRelease,
    required this.isLoadingBranches,
    required this.projectId,
    required this.onRefreshBranches,
  }) : super(
         equals: [
           releaseModel,
           branches,
           isLoadingRelease,
           isLoadingBranches,
           projectId,
         ],
       );

  final ReleaseModel? releaseModel;
  final List<String>? branches;
  final bool isLoadingRelease;
  final bool isLoadingBranches;
  final String? projectId;
  final VoidCallback onRefreshBranches;

  String get version => releaseModel == null ? '0.0.1' : releaseModel!.version;
}
