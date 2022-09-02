import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/routes.dart';
import 'package:stelaris_ui/util/themes.dart';

class StelarisApp extends StatelessWidget {
  const StelarisApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      title: "Stelaris",
      debugShowCheckedModeBanner: false,
      theme: darkMode,
    );
  }
}
