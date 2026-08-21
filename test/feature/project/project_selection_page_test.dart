import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/project/project_selection_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('ProjectSelectionPage Widget Tests', () {
    testWidgets('renders empty state when no projects exist', (tester) async {
      final store = Store<AppState>(initialState: const AppState());

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProjectSelectionPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Welcome to Stelaris'), findsOneWidget);
      expect(find.text('Select Project'), findsOneWidget);
      expect(find.text('No projects found'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders dropdown with projects when available', (tester) async {
      const project = Project(
        id: 'test_id',
        displayName: 'Test Project',
        key: 'test_key',
        description: 'A test project description',
      );

      final store = Store<AppState>(
        initialState: const AppState(projects: [project]),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProjectSelectionPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Welcome to Stelaris'), findsOneWidget);
      expect(find.text('Select Project'), findsOneWidget);
      expect(find.textContaining('Test Project'), findsWidgets);
      expect(find.text('Open Project'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
