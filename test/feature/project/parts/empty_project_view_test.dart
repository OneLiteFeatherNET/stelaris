import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/project/parts/empty_project_view.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('EmptyProjectView Widget Tests', () {
    testWidgets('renders empty state text, icon and create button', (
      tester,
    ) async {
      var createClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: EmptyProjectView(
              onCreateProject: () => createClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('No projects found'), findsOneWidget);
      expect(
        find.text('Get started by creating your first project.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.create_new_folder_outlined), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(createClicked, isTrue);
    });

    testWidgets('the create button keeps the pill shape of the theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: EmptyProjectView(onCreateProject: () {})),
        ),
      );

      final button = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('Create'),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
      expect(button.style?.shape, isNull);
    });
  });
}
