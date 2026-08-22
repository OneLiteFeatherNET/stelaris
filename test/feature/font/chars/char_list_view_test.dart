import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/factory/font/selected_font_char_state.dart';
import 'package:stelaris/feature/font/chars/char_list_view.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('CharListView Widget Tests', () {
    SelectedFontCharView buildView(List<FontStringDTO> chars) {
      return SelectedFontCharView(
        selected: FontModel(
          uiName: 'font',
          chars: PaginatedResult<FontStringDTO>(
            items: chars,
            totalItems: chars.length,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );
    }

    testWidgets('renders a list item for every char', (tester) async {
      final view = buildView([
        const FontStringDTO(id: '1', line: 'A'),
        const FontStringDTO(id: '2', line: 'B'),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CharListView(fontModel: view)),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets(
      'uses scrollCacheExtent instead of the deprecated cacheExtent',
      (tester) async {
        final view = buildView([const FontStringDTO(id: '1', line: 'A')]);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CharListView(fontModel: view)),
          ),
        );

        final listView = tester.widget<ListView>(find.byType(ListView));

        expect(listView.scrollCacheExtent, const ScrollCacheExtent.pixels(100));
        // ignore: deprecated_member_use
        expect(listView.cacheExtent, isNull);
      },
    );
  });
}
