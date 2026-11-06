import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/generator/demo_generator_api.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/build/generator_page.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_generator_api.dart';
import '../../support/pump_in_app.dart';

const Project _project = Project(
  id: 'p1',
  displayName: 'Eldoria',
  key: 'eldoria',
);

void main() {
  late FakeGeneratorApi api;
  late List<String> saved;
  String? clipboard;

  setUp(() {
    api = FakeGeneratorApi(
      branchList: ['main', 'develop', 'release/2.x'],
      versions: [
        publishedVersion('0.1.0'),
        publishedVersion('0.2.12'),
        publishedVersion('0.3.0-SNAPSHOT'),
      ],
    );
    saved = [];
    clipboard = null;
  });

  Future<Store<AppState>> pump(
    WidgetTester tester, {
    Project? project = _project,
  }) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final store = Store<AppState>(
      initialState: AppState(selectedProject: project),
    );
    await pumpInApp(
      tester,
      store,
      GeneratorPage(
        api: api,
        saveFile: (Uint8List bytes, String name) => saved.add(name),
      ),
    );
    return store;
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(Tab, label));
    await tester.pumpAndSettle();
  }

  Finder branchField() => find.byType(DropdownButtonFormField<String>);

  testWidgets('shows the three tabs in order, without a title header', (
    tester,
  ) async {
    await pump(tester);

    final tabs = tester.widgetList<Tab>(find.byType(Tab)).toList();
    expect(tabs.map((tab) => tab.text), [
      'Test locally',
      'Publish',
      'Published versions',
    ]);
    expect(find.text('Build & Download Vulpes'), findsNothing);
    expect(find.textContaining('try it before publishing'), findsOneWidget);
  });

  testWidgets('selects develop and hides the branch on Published versions', (
    tester,
  ) async {
    await pump(tester);
    expect(branchField(), findsOneWidget);
    expect(
      tester
          .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
          .value,
      'develop',
    );

    await openTab(tester, 'Published versions');
    expect(branchField(), findsNothing);

    await openTab(tester, 'Publish');
    expect(branchField(), findsOneWidget);
  });

  testWidgets('the selected branch is shared and kept across tabs', (
    tester,
  ) async {
    await pump(tester);
    await openTab(tester, 'Publish');
    await tester.tap(branchField());
    await tester.pumpAndSettle();
    await tester.tap(find.text('release/2.x').last);
    await tester.pumpAndSettle();

    await openTab(tester, 'Published versions');
    await openTab(tester, 'Test locally');
    await tester.tap(find.text('Download eldoria-local.zip'));
    await tester.pumpAndSettle();

    expect(api.calls, contains('localBuild p1 release/2.x'));
    expect(saved, ['eldoria-local.zip']);
    expect(find.text('Saved eldoria-local.zip.'), findsOneWidget);
  });

  testWidgets('Test locally explains where the zip goes', (tester) async {
    await pump(tester);

    expect(find.textContaining('It creates vulpes/eldoria/'), findsOneWidget);
  });

  testWidgets('a failed download shows the error with a retry', (tester) async {
    api.localBuildFailure = const GeneratorFailure(
      GeneratorFailureKind.unavailable,
      statusCode: 502,
    );
    await pump(tester);

    await tester.tap(find.text('Download eldoria-local.zip'));
    await tester.pumpAndSettle();

    expect(saved, isEmpty);
    expect(
      find.text('The local build could not be downloaded.'),
      findsOneWidget,
    );
    expect(find.text('Status 502'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('without a project the actions say so', (tester) async {
    await pump(tester, project: null);

    expect(find.text('Select a project to use the generator.'), findsOneWidget);
    expect(find.text('Download eldoria-local.zip'), findsNothing);
  });

  testWidgets('an unreachable generator shows a short text, no exception', (
    tester,
  ) async {
    api.branchesFailure = const GeneratorFailure(GeneratorFailureKind.network);
    api.versionsFailure = const GeneratorFailure(GeneratorFailureKind.network);
    await pump(tester);

    expect(find.text('The generator could not be reached.'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('a raw error is not shown on the page', (tester) async {
    api.rawError = StateError('connection refused at 10.0.0.1:8080');
    await pump(tester);

    expect(
      find.text('The vulpes-base branches could not be loaded.'),
      findsOneWidget,
    );
    expect(find.textContaining('connection refused'), findsNothing);
    expect(find.textContaining('StateError'), findsNothing);
  });

  testWidgets('a failed branch list offers a retry and disables builds', (
    tester,
  ) async {
    api.branchesFailure = const GeneratorFailure(GeneratorFailureKind.network);
    await pump(tester);

    expect(
      find.text('The vulpes-base branches could not be loaded.'),
      findsOneWidget,
    );
    final download = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Download eldoria-local.zip'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      ),
    );
    expect(download.onPressed, isNull);

    api.branchesFailure = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(branchField(), findsOneWidget);
  });

  group('Publish', () {
    testWidgets('proposes from the latest release, per channel and bump', (
      tester,
    ) async {
      await pump(tester);
      await openTab(tester, 'Publish');

      expect(find.text('Version 0.2.13'), findsOneWidget);

      await tester.tap(find.text('Minor'));
      await tester.pumpAndSettle();
      expect(find.text('Version 0.3.0'), findsOneWidget);

      await tester.tap(find.text('Snapshot'));
      await tester.pumpAndSettle();
      expect(find.text('Version 0.3.0-SNAPSHOT'), findsOneWidget);
      expect(find.text('Version 0.3.0'), findsNothing);
    });

    testWidgets('cancelling the confirmation sends nothing', (tester) async {
      await pump(tester);
      await openTab(tester, 'Publish');

      await tester.tap(find.text('Publish 0.2.13'));
      await tester.pumpAndSettle();
      expect(find.text('Publish 0.2.13?'), findsOneWidget);
      expect(find.textContaining('develop'), findsWidgets);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(api.calls.where((call) => call.startsWith('publish ')), isEmpty);
    });

    testWidgets('a confirmed publish shows the result and reloads', (
      tester,
    ) async {
      await pump(tester);
      await openTab(tester, 'Publish');

      await tester.tap(find.text('Publish 0.2.13'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Publish 0.2.13').last);
      await tester.pumpAndSettle();

      expect(api.calls.where((call) => call.startsWith('publish ')), [
        'publish p1 0.2.13 develop',
      ]);
      expect(
        api.calls.where((call) => call.startsWith('publishedVersions')),
        hasLength(2),
      );
      expect(find.text('Published 0.2.13'), findsOneWidget);
      expect(find.text('develop @ 0123456789'), findsOneWidget);
      const line = 'vulpes("net.onelitefeather.vulpes.content:eldoria:0.2.13")';
      expect(find.text(line), findsOneWidget);

      await tester.tap(find.byTooltip('Copy the full commit'));
      await tester.pumpAndSettle();
      expect(clipboard, '0123456789abcdef0123456789abcdef01234567');

      await openTab(tester, 'Test locally');
      await openTab(tester, 'Publish');
      expect(find.text('Published 0.2.13'), findsOneWidget);
    });

    testWidgets('the confirmation says an existing snapshot is replaced', (
      tester,
    ) async {
      await pump(tester);
      await openTab(tester, 'Publish');
      await tester.tap(find.text('Minor'));
      await tester.tap(find.text('Snapshot'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Publish 0.3.0-SNAPSHOT'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          '0.3.0-SNAPSHOT is already published. Publishing replaces the '
          'existing 0.3.0-SNAPSHOT.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a rejected publish lists every diagnostic', (tester) async {
      api.publishFailure = const GeneratorFailure(
        GeneratorFailureKind.rejected,
        statusCode: 422,
        diagnostics: [
          Diagnostic(file: 'items/Sword.java', line: 12, message: 'boom'),
          Diagnostic(file: 'items/Bow.java', line: 3, message: 'bang'),
        ],
      );
      await pump(tester);
      await openTab(tester, 'Publish');

      await tester.tap(find.text('Publish 0.2.13'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Publish 0.2.13').last);
      await tester.pumpAndSettle();

      expect(find.text('items/Sword.java:12: boom'), findsOneWidget);
      expect(find.text('items/Bow.java:3: bang'), findsOneWidget);
      expect(find.text('Published 0.2.13'), findsNothing);
    });

    testWidgets('a conflict says the version exists and reloads', (
      tester,
    ) async {
      api.publishFailure = const GeneratorFailure(
        GeneratorFailureKind.versionExists,
        statusCode: 409,
      );
      await pump(tester);
      await openTab(tester, 'Publish');

      await tester.tap(find.text('Publish 0.2.13'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Publish 0.2.13').last);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('0.2.13 is already published.'),
        findsOneWidget,
      );
      expect(
        api.calls.where((call) => call.startsWith('publishedVersions')),
        hasLength(2),
      );
    });

    testWidgets('an unreadable version disables publishing', (tester) async {
      api.versions = [publishedVersion('0.1.0'), publishedVersion('1.0')];
      await pump(tester);
      await openTab(tester, 'Publish');

      expect(find.textContaining('"1.0" cannot be read'), findsOneWidget);
      expect(find.textContaining('Publish 0.'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Published versions', () {
    testWidgets('lists newest first with download and copy', (tester) async {
      await pump(tester);
      await openTab(tester, 'Published versions');

      final versions = ['0.3.0-SNAPSHOT', '0.2.12', '0.1.0'];
      final tops = [
        for (final version in versions)
          tester.getTopLeft(find.text(version)).dy,
      ];
      expect(tops, [...tops]..sort());
      expect(
        find.text('net.onelitefeather.vulpes.content:eldoria:0.2.12'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Download 0.2.12 as a local build'));
      await tester.pumpAndSettle();
      expect(saved, ['eldoria-0.2.12.zip']);

      await tester.tap(find.byTooltip('Copy the Gradle line').at(1));
      await tester.pumpAndSettle();
      expect(
        clipboard,
        'vulpes("net.onelitefeather.vulpes.content:eldoria:0.2.12")',
      );
    });

    testWidgets('an empty repository is not an error', (tester) async {
      api.versions = [];
      await pump(tester);
      await openTab(tester, 'Published versions');

      expect(
        find.text('This project has not published a version yet.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('an unavailable repository offers a retry', (tester) async {
      api.versionsFailure = const GeneratorFailure(
        GeneratorFailureKind.unavailable,
        statusCode: 502,
      );
      await pump(tester);
      await openTab(tester, 'Published versions');

      expect(
        find.text('The Maven repository cannot be read right now.'),
        findsOneWidget,
      );
      expect(
        find.text('This project has not published a version yet.'),
        findsNothing,
      );
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  testWidgets('the demo generator shows the demo banner', (tester) async {
    final store = Store<AppState>(
      initialState: const AppState(selectedProject: _project),
    );
    await pumpInApp(
      tester,
      store,
      GeneratorPage(api: DemoGeneratorApi(delay: Duration.zero)),
    );

    expect(find.textContaining('Demo data'), findsOneWidget);
  });

  testWidgets('the real generator shows no demo banner', (tester) async {
    await pump(tester);

    expect(find.textContaining('Demo data'), findsNothing);
  });
}
