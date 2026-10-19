import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('EmptyDataWidget', () {
    testWidgets('renders default empty widget', (tester) async {
      const widget = EmptyDataWidget();

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('No data available'), findsOneWidget);
      expect(find.text('Use the add button to add new data!'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('renders standard with custom header', (tester) async {
      const widget = EmptyDataWidget.standard(header: 'Wonderful Header');

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Wonderful Header'), findsOneWidget);
      expect(find.text('Use the add button to add new data!'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('renders standard with header and subheader', (tester) async {
      const widget = EmptyDataWidget.standard(
        header: 'Wonderful Header',
        subHeader: 'Sub header',
      );

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: widget),
        ),
      );

      expect(find.text('Wonderful Header'), findsOneWidget);
      expect(find.text('Sub header'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });
}
