import 'package:async_redux/async_redux.dart';
import 'package:web/web.dart' as web;
import 'package:material_ui/material_ui.dart';
import 'package:localstorage/localstorage.dart';
import 'package:stelaris/api/state/app_persistor.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/actions/auth_actions.dart';
import 'package:stelaris/auth/auth_session.dart';
import 'package:stelaris/auth/auth_sessions.dart';
import 'package:stelaris/env/runtime_config.dart';
import 'package:stelaris/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Before anything can reach for an API client: the backend URLs come from
  // the deployment, not from the bundle. Never throws - a missing or unusable
  // configuration leaves the compiled-in defaults in place.
  await RuntimeConfig.load();

  // After the configuration and before the store, because the first frame may
  // already depend on whether somebody is signed in - and because the guard
  // must never see a session that has not been asked about yet. Does nothing
  // at all when no provider is configured.
  //
  // The base href, not the current page: the redirect URI is registered with
  // the provider and has to be the same whichever route was deep-linked into.
  await AuthSessions.start(baseHref: Uri.parse(web.document.baseURI));

  await initLocalStorage();

  final persistor = AppPersistor();
  final initialState = await persistor.readState();

  final store = Store<AppState>(
    persistor: persistor,
    initialState: initialState,
  );

  // The session is the source of truth; the store keeps a copy so widgets can
  // rebuild on it. Seeded once, then followed - a session that is restored or
  // expires after startup has to reach the interface too.
  final AuthSession? session = AuthSessions.current;
  if (session != null) {
    store.dispatch(UpdateAuthStateAction(session.state));
    session.states.listen(
      (auth) => store.dispatch(UpdateAuthStateAction(auth)),
    );
  }

  runApp(StoreProvider(store: store, child: const StelarisApp()));
}
