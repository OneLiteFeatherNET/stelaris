import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StelarisApp extends StatelessWidget {
  const StelarisApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ThemeSettings>(
      converter: (store) => store.state.themeSettings,
      builder: (context, themeSettings) {
        final systemDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        final effectiveDarkMode = themeSettings.useSystemTheme ? systemDarkMode : themeSettings.isDarkMode;

        final baseTextTheme = Typography.material2021();
        final scaledTextTheme = TextTheme(
          displayLarge: baseTextTheme.black.displayLarge!.copyWith(fontSize: 96 * themeSettings.fontScale),
          displayMedium: baseTextTheme.black.displayMedium!.copyWith(fontSize: 60 * themeSettings.fontScale),
          displaySmall: baseTextTheme.black.displaySmall!.copyWith(fontSize: 48 * themeSettings.fontScale),
          headlineLarge: baseTextTheme.black.headlineLarge!.copyWith(fontSize: 40 * themeSettings.fontScale),
          headlineMedium: baseTextTheme.black.headlineMedium!.copyWith(fontSize: 34 * themeSettings.fontScale),
          headlineSmall: baseTextTheme.black.headlineSmall!.copyWith(fontSize: 24 * themeSettings.fontScale),
          titleLarge: baseTextTheme.black.titleLarge!.copyWith(fontSize: 20 * themeSettings.fontScale),
          titleMedium: baseTextTheme.black.titleMedium!.copyWith(fontSize: 16 * themeSettings.fontScale),
          titleSmall: baseTextTheme.black.titleSmall!.copyWith(fontSize: 14 * themeSettings.fontScale),
          bodyLarge: baseTextTheme.black.bodyLarge!.copyWith(fontSize: 16 * themeSettings.fontScale),
          bodyMedium: baseTextTheme.black.bodyMedium!.copyWith(fontSize: 14 * themeSettings.fontScale),
          bodySmall: baseTextTheme.black.bodySmall!.copyWith(fontSize: 12 * themeSettings.fontScale),
          labelLarge: baseTextTheme.black.labelLarge!.copyWith(fontSize: 14 * themeSettings.fontScale),
          labelMedium: baseTextTheme.black.labelMedium!.copyWith(fontSize: 12 * themeSettings.fontScale),
          labelSmall: baseTextTheme.black.labelSmall!.copyWith(fontSize: 11 * themeSettings.fontScale),
        );

        return MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
          title: appName,
          debugShowCheckedModeBanner: false,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: themeSettings.primaryColor,
            secondaryHeaderColor: themeSettings.accentColor,
            textTheme: scaledTextTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          theme: ThemeData(
            brightness: Brightness.light,
            colorSchemeSeed: themeSettings.primaryColor,
            secondaryHeaderColor: themeSettings.accentColor,
            textTheme: scaledTextTheme,
          ),
          themeMode: effectiveDarkMode ? ThemeMode.dark : ThemeMode.light,
        );
      }
    );
  }
}
