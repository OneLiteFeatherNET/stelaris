import 'package:async_redux/async_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/app_theme.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/routes.dart';

/// The root application widget for Stelaris.
class StelarisApp extends StatelessWidget {
  const StelarisApp({this.routerConfig, super.key});

  /// Optional router configuration override, primarily useful in tests.
  final GoRouter? routerConfig;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ThemeSettings>(
      converter: (store) => store.state.themeSettings,
      builder: (context, settings) {
        return MaterialApp.router(
          title: appName,
          debugShowCheckedModeBanner: false,
          routerConfig: routerConfig ?? router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.buildLight(settings),
          darkTheme: AppTheme.buildDark(settings),
          themeMode: settings.useSystemTheme
              ? ThemeMode.system
              : (settings.isDarkMode ? ThemeMode.dark : ThemeMode.light),
        );
      },
    );
  }
}
