import 'package:flutter/widgets.dart' show LocalizationsDelegate;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;
import 'package:stelaris/l10n/app_localizations.dart';

/// The localization delegates of the app.
///
/// Replaces the generated [AppLocalizations.localizationsDelegates], which
/// still registers the deprecated delegates from `flutter_localizations`.
/// Their `MaterialLocalizations` is a different type than the one the
/// `material_ui` widgets look up, so those widgets would never see it.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];
