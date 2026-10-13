import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/settings/rows/misc_settings_row.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Keeps the urls it is asked to open instead of opening them.
class _FakeUrlLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  final List<String> launched = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return true;
  }
}

void main() {
  group('MiscSettingsRow Widget Tests', () {
    late _FakeUrlLauncher launcher;
    late UrlLauncherPlatform original;

    setUp(() {
      original = UrlLauncherPlatform.instance;
      launcher = _FakeUrlLauncher();
      UrlLauncherPlatform.instance = launcher;
    });

    tearDown(() => UrlLauncherPlatform.instance = original);

    Future<void> pumpRow(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SingleChildScrollView(child: MiscSettingsRow())),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('displays the about heading', (tester) async {
      await pumpRow(tester);

      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('displays app version header, subtitle, and badge', (
      tester,
    ) async {
      await pumpRow(tester);

      expect(find.text('App Version'), findsOneWidget);
      expect(
        find.text('Currently installed version of Stelaris'),
        findsOneWidget,
      );
      expect(find.text(appVersion), findsOneWidget);
    });

    testWidgets('displays the licenses card', (tester) async {
      await pumpRow(tester);

      expect(find.text('Third-party software licenses'), findsOneWidget);
    });

    testWidgets('opens the license page from the licenses card', (
      tester,
    ) async {
      await pumpRow(tester);

      await tester.tap(find.text('Third-party software licenses'));
      await tester.pumpAndSettle();

      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets('displays one issues card for bugs and suggestions', (
      tester,
    ) async {
      await pumpRow(tester);

      expect(find.text('Issues'), findsOneWidget);
      expect(find.text('Report a bug or suggest a feature'), findsOneWidget);
    });

    testWidgets('opens the issue tracker from the issues card', (tester) async {
      await pumpRow(tester);

      await tester.tap(find.text('Issues'));
      await tester.pump();

      expect(launcher.launched, [gitUrl]);
    });

    testWidgets('opens the wiki from the help card', (tester) async {
      await pumpRow(tester);

      await tester.tap(find.text('Help'));
      await tester.pump();

      expect(launcher.launched, [conceptURL]);
    });

    testWidgets('displays one help card for the wiki', (tester) async {
      await pumpRow(tester);

      expect(find.text('Help'), findsOneWidget);
      expect(find.text('Explore the wiki for assistance'), findsOneWidget);
    });
  });
}
