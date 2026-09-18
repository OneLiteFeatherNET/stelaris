import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/model/command_bar.dart';
import 'package:stelaris/feature/model/filter_option.dart';
import 'package:stelaris/feature/model/model_sort_option.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('CommandBar Widget Tests', () {
    const filterA = FilterOption('a', 'Filter A');
    const filterB = FilterOption('b', 'Filter B');

    Widget createWidget({
      VoidCallback? onAdd,
      ValueChanged<String>? onSearchChanged,
      List<FilterOption> filterOptions = const [filterA, filterB],
      ValueChanged<Set<FilterOption>>? onFiltersChanged,
      SortChanged? onSortChanged,
    }) {
      return MaterialApp(
        // Regression guard: CommandBar must resolve TextField/Material from
        // `material_ui` (the package the rest of the app uses), not stock
        // `flutter/material.dart` — otherwise its TextField can't find a
        // matching Material ancestor and throws when the app's real Scaffold
        // (also from `material_ui`) is used.
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CommandBar(
            onAdd: onAdd ?? () {},
            onSearchChanged: onSearchChanged ?? (_) {},
            filterOptions: filterOptions,
            onFiltersChanged: onFiltersChanged ?? (_) {},
            onSortChanged: onSortChanged ?? (_, _) {},
          ),
        ),
      );
    }

    testWidgets('tapping add triggers onAdd callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(createWidget(onAdd: () => tapped = true));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets(
      'entering text into the persistent search field reports the query',
      (tester) async {
        String? lastQuery;
        await tester.pumpWidget(
          createWidget(onSearchChanged: (value) => lastQuery = value),
        );

        // The search field is always visible (M3 SearchBar), no toggle needed.
        await tester.enterText(find.byType(TextField), 'hello world');
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(lastQuery, equals('hello world'));
      },
    );

    testWidgets('selecting a filter option reports active filters', (
      tester,
    ) async {
      Set<FilterOption>? lastFilters;
      await tester.pumpWidget(
        createWidget(onFiltersChanged: (value) => lastFilters = value),
      );

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Filter A'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(lastFilters, equals({filterA}));
    });

    testWidgets(
      'omits filter checkboxes but keeps sorting when there are no filter options',
      (tester) async {
        await tester.pumpWidget(createWidget(filterOptions: const []));

        // Sorting always applies, so the shared menu icon stays.
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();

        expect(find.text('Name (A–Z)'), findsOneWidget);
        expect(find.byType(Divider), findsNothing);
      },
    );

    testWidgets('selecting a sort option reports field and direction', (
      tester,
    ) async {
      SortField? lastField;
      SortDirection? lastDirection;
      await tester.pumpWidget(
        createWidget(
          onSortChanged: (field, direction) {
            lastField = field;
            lastDirection = direction;
          },
        ),
      );

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Created (newest first)'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(lastField, SortField.createdAt);
      expect(lastDirection, SortDirection.descending);
    });
  });
}
