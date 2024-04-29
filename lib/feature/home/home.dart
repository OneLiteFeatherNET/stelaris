import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/routes.dart';
import 'package:stelaris_ui/util/themes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StelarisApp extends StatelessWidget {

  const StelarisApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
        converter: (store) => store.state.nightMode,
        builder: (context, theme) {
          return MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
            routeInformationProvider: router.routeInformationProvider,
            title: appName,
            debugShowCheckedModeBanner: false,
            darkTheme: darkMode,
            theme: lightMode,
            themeMode: theme ? ThemeMode.dark : ThemeMode.light,
          );
        }
    );
  }
}
