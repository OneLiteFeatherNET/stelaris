import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/project/badge/project_app_bar_badge.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('ProjectAppBarBadge Widget Tests', () {
    testWidgets('renders nothing when no project is selected', (tester) async {
      final store = Store<AppState>(initialState: const AppState());

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            home: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(56),
                child: ProjectAppBarBadge(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsNothing);
      expect(find.byIcon(Icons.folder_outlined), findsNothing);
    });

    testWidgets('renders project name and labor badge when selected', (tester) async {
      const project = Project(
        id: 'test_id',
        displayName: 'My Project',
        key: 'my_project',
        labor: true,
      );

      final store = Store<AppState>(
        initialState: const AppState(selectedProject: project),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            home: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(56),
                child: ProjectAppBarBadge(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('My Project'), findsOneWidget);
      expect(find.text('Labor'), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    });
  });
}
