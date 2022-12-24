import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/routes.dart';
import 'package:stelaris_ui/util/themes.dart';

final ValueNotifier<ThemeMode> notifier = ValueNotifier(ThemeMode.dark);

class StelarisApp extends StatelessWidget {

  const StelarisApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // notifier.value = MediaQuery.of(context).platformBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    return ValueListenableBuilder<ThemeMode>(valueListenable: notifier, builder: (_, mode, __) {
      return  MaterialApp.router(
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        routeInformationProvider: router.routeInformationProvider,
        title: appName,
        debugShowCheckedModeBanner: false,
        darkTheme: darkMode,
        theme: lightMode,
        themeMode: mode,
      );
    });
  }
}
