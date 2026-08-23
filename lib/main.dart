import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:localstorage/localstorage.dart';
import 'package:stelaris/api/state/app_presistor.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/env/runtime_config.dart';
import 'package:stelaris/feature/home/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Before anything can reach for an API client: the backend URLs come from
  // the deployment, not from the bundle. Never throws - a missing or unusable
  // configuration leaves the compiled-in defaults in place.
  await RuntimeConfig.load();

  await initLocalStorage();

  final persistor = AppPersistor();
  final initialState = await persistor.readState();

  final store = Store<AppState>(
    persistor: persistor,
    initialState: initialState,
  );

  runApp(StoreProvider(store: store, child: const StelarisApp()));
}
