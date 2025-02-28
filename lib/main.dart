import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:stelaris/api/state/app_presistor.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/home/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  
  final persistor = AppPersistor();
  final initialState = await persistor.readState();

  final store = Store<AppState>(
    persistor: persistor,
    initialState: initialState,
  );

  runApp(StoreProvider(store: store, child: const StelarisApp()));
}
