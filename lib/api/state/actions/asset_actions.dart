import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Saves [notes] as the internal notes of [asset]; `null` clears them.
///
/// Assets live outside the store, so the state stays as it is: the Models
/// page loads its list again once the notes dialog closes.
class AssetNotesUpdateAction extends ReduxAction<AppState> {
  AssetNotesUpdateAction(this.asset, this.notes);

  final AssetModel asset;
  final String? notes;

  @override
  Future<AppState?> reduce() async {
    await ApiService().assetApi.updateComment(asset, notes);
    return null;
  }
}
