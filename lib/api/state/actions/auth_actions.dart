import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/auth/auth_state.dart';

/// Mirrors the session into the state the interface reads.
///
/// The session is the source of truth; this is a copy kept current so widgets
/// can rebuild on it. It carries facts only - status, display name, roles - and
/// never a token: see [AuthState], and the exclusion from JSON in [AppState].
class UpdateAuthStateAction extends ReduxAction<AppState> {
  UpdateAuthStateAction(this.auth);

  final AuthState auth;

  @override
  AppState? reduce() {
    if (state.auth == auth) {
      return null;
    }
    return state.copyWith(auth: auth);
  }
}
