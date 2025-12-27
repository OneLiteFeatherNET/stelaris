import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';

class BranchFetchAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    dispatchSync(_SetIsLoadingBranches(true));
    try {
      final branches = await ApiService().generateApi.branches();
      return state.copyWith(branches: branches, isLoadingBranches: false);
    } catch (e) {
      debugPrint('Error fetching branches: $e');
      return state.copyWith(branches: null, isLoadingBranches: false);
    } finally {
      if (state.isLoadingBranches) {
        dispatchSync(_SetIsLoadingBranches(false));
      }
    }
  }
}

class _SetIsLoadingBranches extends ReduxAction<AppState> {
  final bool value;
  _SetIsLoadingBranches(this.value);

  @override
  AppState reduce() => state.copyWith(isLoadingBranches: value);
}

class ReleaseFetchAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    dispatchSync(_SetIsLoadingRelease(true));
    try {
      final release = await ApiService().generateApi.buildInformation();
      return state.copyWith(releaseModel: release, isLoadingRelease: false);
    } catch (e) {
      return null;
    } finally {
      if (state.isLoadingRelease) {
        dispatchSync(_SetIsLoadingRelease(false));
      }
    }
  }
}

class _SetIsLoadingRelease extends ReduxAction<AppState> {
  final bool value;
  _SetIsLoadingRelease(this.value);

  @override
  AppState reduce() => state.copyWith(isLoadingRelease: value);
}
