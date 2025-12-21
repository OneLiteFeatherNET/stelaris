import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';

class BranchFetchAction extends ReduxAction<AppState> {

  @override
  Future<AppState> reduce() async {
    final branches = await ApiService().generateApi.branches();
    return state.copyWith(branches: branches);
  }
}

class ReleaseFetchAction extends ReduxAction<AppState> {

  @override
  Future<AppState> reduce() async {
    final release = await ApiService().generateApi.buildInformation();
    return state.copyWith(releaseModel: release);
  }
}
