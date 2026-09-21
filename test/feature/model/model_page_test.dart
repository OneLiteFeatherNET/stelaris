import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/model/filter_option.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../test_model.dart';

const _testProject = Project(id: 'proj-1', displayName: 'Project', key: 'proj');

void main() {
  group('ModelPage filtering', () {
    const evenFilter = FilterOption('even', 'Even');

    final models = List.generate(
      5,
      (i) => TestModel(internalId: i, name: 'Model $i'),
    );

    Widget createWidget({
      required bool Function(TestModel, FilterOption) matchesFilter,
      List<FilterOption> filterOptions = const [evenFilter],
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ModelPage<TestModel>(
            models: models,
            mapToDataModelItem: (m) => Text(m.name),
            mapToDeleteDialog: (m) => [TextSpan(text: m.name)],
            mapToDeleteSuccessfully: (_) => true,
            matchesSearch: (m, q) =>
                m.name.toLowerCase().contains(q.toLowerCase()),
            matchesFilter: matchesFilter,
            nameSelector: (m) => m.name,
            keySelector: (m) => m.internalId.toString(),
            copyDialogTitle: 'Copy',
            mapToCopySuccessfully: (_, _) => true,
            projects: const [_testProject],
            currentProject: _testProject,
            filterOptions: filterOptions,
            onAdd: () {},
            onModelTap: (_) {},
            onRefresh: () {},
          ),
        ),
      );
    }

    testWidgets('typing a search query narrows the visible list', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(matchesFilter: (_, _) => true));

      expect(find.text('Model 0'), findsOneWidget);
      expect(find.text('Model 4'), findsOneWidget);

      // The search field is always visible (M3 SearchBar), no toggle needed.
      await tester.enterText(find.byType(TextField), 'Model 2');
      // ModelPage debounces search input by 300ms before applying it.
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // 'Model 2' now matches both the typed query in the TextField and the
      // remaining list item.
      expect(find.text('Model 2'), findsNWidgets(2));
      expect(find.text('Model 0'), findsNothing);
      expect(find.text('Model 4'), findsNothing);
    });

    testWidgets('debounces search input instead of filtering per keystroke', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(matchesFilter: (_, _) => true));

      await tester.enterText(find.byType(TextField), 'Model 2');

      // Right up to (but not past) the debounce window, the list must be
      // unchanged — a shorter debounce than 300ms would break this.
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Model 0'), findsOneWidget);
      expect(find.text('Model 4'), findsOneWidget);

      // Past the debounce window, the filter is finally applied.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Model 0'), findsNothing);
      expect(find.text('Model 4'), findsNothing);
    });

    testWidgets('selecting a filter option narrows the visible list', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          matchesFilter: (model, filter) =>
              filter.id != 'even' || model.internalId.isEven,
        ),
      );

      expect(find.text('Model 0'), findsOneWidget);
      expect(find.text('Model 1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Even'));
      await tester.pumpAndSettle();

      expect(find.text('Model 0'), findsOneWidget);
      expect(find.text('Model 2'), findsOneWidget);
      expect(find.text('Model 4'), findsOneWidget);
      expect(find.text('Model 1'), findsNothing);
      expect(find.text('Model 3'), findsNothing);
    });
  });

  group('ModelPage empty states', () {
    // Same empty-state copy (empty_data_header/empty_data_subHeader) the
    // other, not-yet-migrated pages already use for their "nothing to
    // show" case — reused here rather than inventing new strings.
    const emptyHeader = 'No data selected';

    Widget createWidget({required List<TestModel> models}) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ModelPage<TestModel>(
            models: models,
            mapToDataModelItem: (m) => Text(m.name),
            mapToDeleteDialog: (m) => [TextSpan(text: m.name)],
            mapToDeleteSuccessfully: (_) => true,
            matchesSearch: (m, q) =>
                m.name.toLowerCase().contains(q.toLowerCase()),
            matchesFilter: (_, _) => true,
            nameSelector: (m) => m.name,
            keySelector: (m) => m.internalId.toString(),
            copyDialogTitle: 'Copy',
            mapToCopySuccessfully: (_, _) => true,
            projects: const [_testProject],
            currentProject: _testProject,
            onAdd: () {},
            onModelTap: (_) {},
            onRefresh: () {},
          ),
        ),
      );
    }

    testWidgets(
      'shows the shared empty-data hint when there are no models at all',
      (tester) async {
        await tester.pumpWidget(createWidget(models: const []));

        expect(find.text(emptyHeader), findsOneWidget);
      },
    );

    testWidgets('shows the same hint when a search yields no results', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(models: [TestModel(internalId: 1, name: 'Model 1')]),
      );

      await tester.enterText(find.byType(TextField), 'nope');
      // ModelPage debounces search input by 300ms before applying it.
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text(emptyHeader), findsOneWidget);
      expect(find.text('Model 1'), findsNothing);
    });
  });

  group('ModelPage sorting', () {
    // Dates deliberately don't align with alphabetical order, so a
    // date-based sort is distinguishable from the name-based default.
    final models = [
      TestModel(
        internalId: 1,
        name: 'Alpha',
        creationDate: DateTime(2024, 2, 1),
      ),
      TestModel(
        internalId: 2,
        name: 'Bravo',
        creationDate: DateTime(2024, 3, 1),
      ),
      TestModel(
        internalId: 3,
        name: 'Charlie',
        creationDate: DateTime(2024, 1, 1),
      ),
    ];

    Widget createWidget() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ModelPage<TestModel>(
            models: models,
            mapToDataModelItem: (m) => Text(m.name),
            mapToDeleteDialog: (m) => [TextSpan(text: m.name)],
            mapToDeleteSuccessfully: (_) => true,
            matchesSearch: (m, q) =>
                m.name.toLowerCase().contains(q.toLowerCase()),
            matchesFilter: (_, _) => true,
            nameSelector: (m) => m.name,
            keySelector: (m) => m.internalId.toString(),
            copyDialogTitle: 'Copy',
            mapToCopySuccessfully: (_, _) => true,
            projects: const [_testProject],
            currentProject: _testProject,
            onAdd: () {},
            onModelTap: (_) {},
            onRefresh: () {},
          ),
        ),
      );
    }

    List<String> visibleNameOrder(WidgetTester tester) {
      return tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .whereType<String>()
          .where(['Alpha', 'Bravo', 'Charlie'].contains)
          .toList();
    }

    testWidgets('defaults to name ascending', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(visibleNameOrder(tester), ['Alpha', 'Bravo', 'Charlie']);
    });

    testWidgets('name descending reverses the default order', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Name (Z–A)'));
      await tester.pumpAndSettle();

      expect(visibleNameOrder(tester), ['Charlie', 'Bravo', 'Alpha']);
    });

    testWidgets('sorts by creation date, oldest first', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Created (oldest first)'));
      await tester.pumpAndSettle();

      expect(visibleNameOrder(tester), ['Charlie', 'Alpha', 'Bravo']);
    });

    testWidgets('sorts by creation date, newest first', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Created (newest first)'));
      await tester.pumpAndSettle();

      expect(visibleNameOrder(tester), ['Bravo', 'Alpha', 'Charlie']);
    });

    testWidgets('keeps undated models last in both creation-date directions', (
      tester,
    ) async {
      final withUndated = [
        TestModel(
          internalId: 1,
          name: 'Alpha',
          creationDate: DateTime(2024, 2, 1),
        ),
        TestModel(internalId: 2, name: 'Bravo'), // no creationDate
        TestModel(
          internalId: 3,
          name: 'Charlie',
          creationDate: DateTime(2024, 1, 1),
        ),
      ];

      Widget createWithUndated() {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ModelPage<TestModel>(
              models: withUndated,
              mapToDataModelItem: (m) => Text(m.name),
              mapToDeleteDialog: (m) => [TextSpan(text: m.name)],
              mapToDeleteSuccessfully: (_) => true,
              matchesSearch: (m, q) =>
                  m.name.toLowerCase().contains(q.toLowerCase()),
              matchesFilter: (_, _) => true,
              nameSelector: (m) => m.name,
              keySelector: (m) => m.internalId.toString(),
              copyDialogTitle: 'Copy',
              mapToCopySuccessfully: (_, _) => true,
              projects: const [_testProject],
              currentProject: _testProject,
              onAdd: () {},
              onModelTap: (_) {},
              onRefresh: () {},
            ),
          ),
        );
      }

      // Oldest first: Bravo (no date) must stay last, not first.
      await tester.pumpWidget(createWithUndated());
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Created (oldest first)'));
      await tester.pumpAndSettle();
      expect(visibleNameOrder(tester), ['Charlie', 'Alpha', 'Bravo']);

      // Newest first: Bravo (no date) must still stay last.
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Created (newest first)'));
      await tester.pumpAndSettle();
      expect(visibleNameOrder(tester), ['Alpha', 'Charlie', 'Bravo']);
    });
  });

  group('ModelPage refresh', () {
    final models = [TestModel(internalId: 1, name: 'Model 1')];

    Widget createWidget({VoidCallback? onRefresh, bool isRefreshing = false}) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ModelPage<TestModel>(
            models: models,
            mapToDataModelItem: (m) => Text(m.name),
            mapToDeleteDialog: (m) => [TextSpan(text: m.name)],
            mapToDeleteSuccessfully: (_) => true,
            matchesSearch: (m, q) =>
                m.name.toLowerCase().contains(q.toLowerCase()),
            matchesFilter: (_, _) => true,
            nameSelector: (m) => m.name,
            keySelector: (m) => m.internalId.toString(),
            copyDialogTitle: 'Copy',
            mapToCopySuccessfully: (_, _) => true,
            projects: const [_testProject],
            currentProject: _testProject,
            onAdd: () {},
            onModelTap: (_) {},
            onRefresh: onRefresh ?? () {},
            isRefreshing: isRefreshing,
          ),
        ),
      );
    }

    testWidgets('forwards a tap on the refresh button to onRefresh', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(createWidget(onRefresh: () => tapped = true));

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('forwards isRefreshing to the CommandBar', (tester) async {
      await tester.pumpWidget(createWidget(isRefreshing: true));

      expect(find.byIcon(Icons.refresh), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
