# Replace the Input Cards with Dialogs: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The font and sound General tabs and the notification page show each field as a card and
edit it in a dialog. The input cards and the form registry are removed.

**Architecture:** A page describes its fields as `TextProperty`/`ChoiceProperty` objects and hands
them to a `PropertyGrid`. Each `PropertyCard` opens the property's dialog. On a changed value the
property calls the page's `onChanged`, which dispatches the page's existing update action. That
action marks the model unsaved, and the header's save button persists it as before.

**Tech Stack:** Flutter, async_redux, flutter_test.

**Spec:** `openspec/changes/replace-input-cards-with-dialogs/design.md`,
`openspec/changes/replace-input-cards-with-dialogs/specs/property-editing/spec.md`

## Global Constraints

- Branch `feature/propertyDialogs`. Commits: one short conventional subject line, no body, no
  co-author trailer.
- Run `git branch --show-current` right before every commit; the IDE may switch branches.
- Format only the files you touch (`dart format <file>`), never `dart format lib` or
  `dart format test`.
- Every text field keeps `maxLength: 30`.
- Verify each task with `flutter analyze` (the `backdoorInheritedWidget` warnings are pre-existing)
  and its tests on the VM and with `--platform chrome`.
- `lib/main.dart` and the untracked `smooth_wheel_binding`/`theme_fade` files are the user's work in
  progress: never stage them.

## Review Focus

- A value that is already invalid in the store (e.g. a stored texture path with spaces) opens in
  the dialog, and the dialog must still let the user cancel without an error. Pinned in Task 1.
- Enter in the text field must save like the button, and must not save an invalid value. Pinned in
  Task 1.
- Two cards with the same label on one page would make the tests ambiguous. No page has that, and
  the helper in Task 3 finds cards by label.
- The header "Save" and the dialog "Save" share a label. Tests must scope the dialog's button to
  `FormDialog`. Pinned in Task 3's helper.
- Empty number fields become `0` (font ascent and height). Pinned in Task 4.

---

### Task 1: Property descriptions, card and text dialog

**Files:**
- Create: `lib/feature/base/property/property.dart`
- Create: `lib/feature/base/property/property_card.dart`
- Create: `lib/feature/base/property/property_dialogs.dart`
- Test: `test/feature/base/property/text_property_test.dart`

**Interfaces:**
- Produces:
  - `abstract class Property` with `String get label`, `String? get tooltip`,
    `String get displayValue`, `bool get showsPlaceholder` and `Future<void> edit(BuildContext context)`.
  - `TextProperty({required String label, required String value, required ValueChanged<String> onChanged, String? tooltip, String? hintText, FormFieldValidator<String>? validator, List<TextInputFormatter> formatters = const [], TextInputType? keyboardType, int maxLength = 30})`.
  - `PropertyCard({required Property property})`.
  - `Future<String?> showTextPropertyDialog(BuildContext context, TextProperty property)`.

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_card.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  String? changed;

  Future<void> pumpCard(WidgetTester tester, TextProperty property) async {
    changed = null;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PropertyCard(property: property)),
      ),
    );
  }

  TextProperty provider({String value = 'bitmap', String? hint}) =>
      TextProperty(
        label: 'Provider',
        value: value,
        hintText: hint,
        tooltip: 'The font provider',
        validator: (value) =>
            value != null && value.contains(' ') ? 'No spaces' : null,
        onChanged: (value) => changed = value,
      );

  Finder dialogSave() => find.descendant(
    of: find.byType(FormDialog),
    matching: find.text('Save'),
  );

  testWidgets('shows the label, the value and the tooltip', (tester) async {
    await pumpCard(tester, provider());

    expect(find.text('Provider'), findsOneWidget);
    expect(find.text('bitmap'), findsOneWidget);
    expect(find.byTooltip('The font provider'), findsOneWidget);
  });

  testWidgets('shows the hint, or a dash, for an empty value', (tester) async {
    await pumpCard(tester, provider(value: '', hint: 'minecraft:default'));
    expect(find.text('minecraft:default'), findsOneWidget);

    await pumpCard(tester, provider(value: ''));
    expect(find.text('–'), findsOneWidget);
  });

  testWidgets('a click opens the dialog with the value filled in', (
    tester,
  ) async {
    await pumpCard(tester, provider());

    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    expect(find.byType(FormDialog), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'bitmap');
    expect(field.focusNode!.hasFocus, isTrue);
  });

  testWidgets('save reports a changed value', (tester) async {
    await pumpCard(tester, provider());
    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ttf');
    await tester.tap(dialogSave());
    await tester.pumpAndSettle();

    expect(changed, 'ttf');
    expect(find.byType(FormDialog), findsNothing);
  });

  testWidgets('enter saves like the button', (tester) async {
    await pumpCard(tester, provider());
    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ttf');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(changed, 'ttf');
  });

  testWidgets('an invalid value keeps the dialog open', (tester) async {
    await pumpCard(tester, provider());
    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'a b');
    await tester.tap(dialogSave());
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(FormDialog), findsOneWidget);
    expect(find.text('No spaces'), findsOneWidget);
    expect(changed, isNull);
  });

  testWidgets('an unchanged value and cancel report nothing', (tester) async {
    await pumpCard(tester, provider());
    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();
    await tester.tap(dialogSave());
    await tester.pumpAndSettle();
    expect(changed, isNull);

    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ttf');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(changed, isNull);
  });

  testWidgets('a stored invalid value can still be cancelled', (tester) async {
    await pumpCard(tester, provider(value: 'a b'));
    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(FormDialog), findsNothing);
    expect(changed, isNull);
  });
}
```

- [ ] **Step 2: Run the tests and check they fail**

Run: `flutter test test/feature/base/property/text_property_test.dart`
Expected: FAIL, because `property.dart` and `property_card.dart` don't exist.

- [ ] **Step 3: Write `property.dart`**

```dart
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/property/property_dialogs.dart';

/// A plain field of a detail page, shown as a [PropertyCard] and edited in
/// a dialog of its own.
///
/// A page describes its fields as properties and hands them to a
/// [PropertyGrid]. The page stays in charge of its model: [edit] only calls
/// back with a changed value, and the page decides what to dispatch.
abstract class Property {
  const Property();

  String get label;
  String? get tooltip;

  /// What the card shows for the current value.
  String get displayValue;

  /// Whether [displayValue] stands in for an empty value.
  bool get showsPlaceholder;

  /// Opens the dialog and reports a changed value.
  Future<void> edit(BuildContext context);
}

/// A text field, edited in a text dialog.
class TextProperty extends Property {
  const TextProperty({
    required this.label,
    required this.value,
    required this.onChanged,
    this.tooltip,
    this.hintText,
    this.validator,
    this.formatters = const [],
    this.keyboardType,
    this.maxLength = 30,
  });

  @override
  final String label;
  final String value;

  /// Called with the new value when the dialog saved a changed one.
  final ValueChanged<String> onChanged;
  @override
  final String? tooltip;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter> formatters;
  final TextInputType? keyboardType;
  final int maxLength;

  @override
  String get displayValue => value.isEmpty ? (hintText ?? '–') : value;

  @override
  bool get showsPlaceholder => value.isEmpty;

  @override
  Future<void> edit(BuildContext context) async {
    final result = await showTextPropertyDialog(context, this);
    if (result != null && result != value) onChanged(result);
  }
}
```

- [ ] **Step 4: Write `property_dialogs.dart` with the text dialog**

```dart
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Edits [property] in a dialog. Resolves to the saved value, or null when
/// the dialog was cancelled.
Future<String?> showTextPropertyDialog(
  BuildContext context,
  TextProperty property,
) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextPropertyDialog(property: property),
  );
}

class _TextPropertyDialog extends StatefulWidget {
  const _TextPropertyDialog({required this.property});

  final TextProperty property;

  @override
  State<_TextPropertyDialog> createState() => _TextPropertyDialogState();
}

class _TextPropertyDialogState extends State<_TextPropertyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.property.value,
  );
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Closes with the value, unless it is invalid.
  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    return FormDialog(
      title: property.label,
      actionIcon: Icons.check,
      actionLabel: context.l10n.button_save,
      onSubmit: _save,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          maxLength: property.maxLength,
          keyboardType: property.keyboardType,
          inputFormatters: property.formatters,
          validator: property.validator,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _save(),
          decoration: InputDecoration(
            hintText: property.hintText,
            helperText: property.tooltip,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Write `property_card.dart`**

```dart
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/property/property.dart';

/// Shows a [Property]'s name and value; a click (or enter and space when
/// focused) opens its dialog. Looks like the cards of the components tab.
class PropertyCard extends StatelessWidget {
  const PropertyCard({required this.property, super.key});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final card = Card.filled(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => property.edit(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      property.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.displayValue,
                      style: property.showsPlaceholder
                          ? theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            )
                          : theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
    final tooltip = property.tooltip;
    return tooltip == null ? card : Tooltip(message: tooltip, child: card);
  }
}
```

- [ ] **Step 6: Run the tests and check they pass**

Run: `flutter test test/feature/base/property/text_property_test.dart`, then the same with
`--platform chrome`.
Expected: all PASS. If the focus check in "a click opens the dialog" fails because `TextField`
doesn't expose the node, look the node up with `Focus.of` or compare
`FocusManager.instance.primaryFocus` with the field's context instead of dropping the check.

- [ ] **Step 7: Commit**

```bash
git add lib/feature/base/property test/feature/base/property/text_property_test.dart
git commit -m "feat(base): add property cards with a text dialog"
```

### Task 2: Choice property and the property grid

**Files:**
- Modify: `lib/feature/base/property/property.dart` (add `ChoiceProperty`)
- Modify: `lib/feature/base/property/property_dialogs.dart` (add the choice dialog)
- Create: `lib/feature/base/property/property_grid.dart`
- Test: `test/feature/base/property/choice_property_test.dart`

**Interfaces:**
- Consumes: `Property`, `PropertyCard` from Task 1.
- Produces:
  - `ChoiceProperty<T>({required String label, required T value, required List<T> options, required String Function(T) display, required ValueChanged<T> onChanged, String? tooltip})`.
  - `Future<T?> showChoicePropertyDialog<T>(BuildContext context, ChoiceProperty<T> property)`.
  - `PropertyGrid({required List<Property> properties})`.

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_card.dart';
import 'package:stelaris/feature/base/property/property_grid.dart';
import 'package:stelaris/l10n/app_localizations.dart';

enum Frame { task, goal, challenge }

void main() {
  Frame? changed;

  Future<void> pumpGrid(WidgetTester tester, List<Property> properties) async {
    changed = null;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PropertyGrid(properties: properties)),
      ),
    );
  }

  ChoiceProperty<Frame> frame() => ChoiceProperty<Frame>(
    label: 'Frame',
    value: Frame.goal,
    options: Frame.values,
    display: (frame) => frame.name.toUpperCase(),
    onChanged: (frame) => changed = frame,
  );

  testWidgets('the grid shows one card per property', (tester) async {
    await pumpGrid(tester, [
      frame(),
      TextProperty(label: 'Title', value: 'Hi', onChanged: (_) {}),
    ]);

    expect(find.byType(PropertyCard), findsNWidgets(2));
    expect(find.text('GOAL'), findsOneWidget);
    expect(find.text('Hi'), findsOneWidget);
  });

  testWidgets('the dialog marks the current option', (tester) async {
    await pumpGrid(tester, [frame()]);

    await tester.tap(find.text('Frame'));
    await tester.pumpAndSettle();

    expect(find.byType(FormDialog), findsOneWidget);
    final current = find.ancestor(
      of: find.text('GOAL').last,
      matching: find.byType(ListTile),
    );
    expect(tester.widget<ListTile>(current).selected, isTrue);
  });

  testWidgets('picking another option reports it', (tester) async {
    await pumpGrid(tester, [frame()]);
    await tester.tap(find.text('Frame'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CHALLENGE'));
    await tester.pumpAndSettle();

    expect(changed, Frame.challenge);
    expect(find.byType(FormDialog), findsNothing);
  });

  testWidgets('picking the current option reports nothing', (tester) async {
    await pumpGrid(tester, [frame()]);
    await tester.tap(find.text('Frame'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('GOAL').last);
    await tester.pumpAndSettle();

    expect(changed, isNull);
  });
}
```

- [ ] **Step 2: Run the tests and check they fail**

Run: `flutter test test/feature/base/property/choice_property_test.dart`
Expected: FAIL, because `ChoiceProperty` and `PropertyGrid` don't exist.

- [ ] **Step 3: Add `ChoiceProperty` to `property.dart`**

```dart
/// A choice between [options], edited in a dialog that lists them.
class ChoiceProperty<T> extends Property {
  const ChoiceProperty({
    required this.label,
    required this.value,
    required this.options,
    required this.display,
    required this.onChanged,
    this.tooltip,
  });

  @override
  final String label;
  final T value;
  final List<T> options;

  /// The name an option shows on the card and in the dialog.
  final String Function(T option) display;

  /// Called with the picked option when it differs from [value].
  final ValueChanged<T> onChanged;
  @override
  final String? tooltip;

  @override
  String get displayValue => display(value);

  @override
  bool get showsPlaceholder => false;

  @override
  Future<void> edit(BuildContext context) async {
    final picked = await showChoicePropertyDialog<T>(context, this);
    if (picked != null && picked != value) onChanged(picked);
  }
}
```

- [ ] **Step 4: Add the choice dialog to `property_dialogs.dart`**

```dart
/// Lets the user pick one of [property]'s options. Resolves to the picked
/// option, or null when the dialog was closed.
Future<T?> showChoicePropertyDialog<T>(
  BuildContext context,
  ChoiceProperty<T> property,
) {
  return showDialog<T>(
    context: context,
    builder: (context) => FormDialog(
      title: property.label,
      actionLabel: context.l10n.button_save,
      onSubmit: null,
      showActions: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in property.options)
            ListTile(
              selected: option == property.value,
              leading: option == property.value
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              title: Text(property.display(option)),
              onTap: () => Navigator.of(context).pop(option),
            ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 5: Write `property_grid.dart`**

```dart
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_card.dart';

/// Lays out one [PropertyCard] per property, with as many columns as fit,
/// like the components tab's grid.
class PropertyGrid extends StatelessWidget {
  const PropertyGrid({required this.properties, super.key});

  static const double _maxCardExtent = 320;
  static const double _cardHeight = 80;
  static const double _spacing = 12;

  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            ((constraints.maxWidth + _spacing) / (_maxCardExtent + _spacing))
                .floor()
                .clamp(1, 4);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: _cardHeight,
            crossAxisSpacing: _spacing,
            mainAxisSpacing: _spacing,
          ),
          itemCount: properties.length,
          itemBuilder: (context, index) =>
              PropertyCard(property: properties[index]),
        );
      },
    );
  }
}
```

- [ ] **Step 6: Run the tests of Tasks 1 and 2 and check they pass**

Run: `flutter test test/feature/base/property`, then the same with `--platform chrome`.
Expected: all PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/feature/base/property test/feature/base/property/choice_property_test.dart
git commit -m "feat(base): add choice properties and the property grid"
```

### Task 3: Test helper for editing a property

**Files:**
- Create: `test/support/property_editing.dart`

**Interfaces:**
- Consumes: `PropertyCard`, `FormDialog`.
- Produces:
  - `Future<void> editTextProperty(WidgetTester tester, String label, String text)`
  - `Future<void> pickChoice(WidgetTester tester, String label, String option)`

- [ ] **Step 1: Write the helper**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/property/property_card.dart';

/// Opens the card labelled [label], enters [text] and saves the dialog.
///
/// The dialog's save button is looked up inside the dialog: a detail page's
/// header has a "Save" button of its own.
Future<void> editTextProperty(
  WidgetTester tester,
  String label,
  String text,
) async {
  await tester.tap(find.widgetWithText(PropertyCard, label));
  await tester.pumpAndSettle();
  final dialog = find.byType(FormDialog);
  await tester.enterText(
    find.descendant(of: dialog, matching: find.byType(TextField)),
    text,
  );
  await tester.tap(find.descendant(of: dialog, matching: find.text('Save')));
  await tester.pumpAndSettle();
}

/// Opens the card labelled [label] and picks [option] in its dialog.
Future<void> pickChoice(
  WidgetTester tester,
  String label,
  String option,
) async {
  await tester.tap(find.widgetWithText(PropertyCard, label));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(FormDialog), matching: find.text(option)),
  );
  await tester.pumpAndSettle();
}
```

- [ ] **Step 2: Check it compiles**

Run: `flutter analyze test/support/property_editing.dart`
Expected: no issues. The helper is exercised by Tasks 4 to 6.

- [ ] **Step 3: Commit**

```bash
git add test/support/property_editing.dart
git commit -m "test: add helpers to edit property cards"
```

### Task 4: Font General tab

**Files:**
- Modify: `lib/feature/font/font_general_page.dart` (whole file)
- Modify: `test/feature/font/font_detail_page_test.dart:141-182`

**Interfaces:**
- Consumes: `TextProperty`, `PropertyGrid`, `editTextProperty`.

- [ ] **Step 1: Move the font tests onto the dialogs**

Replace the `fieldOf`/`enterAndBlur` helpers and the two tests after them with:

```dart
    testWidgets('the texture path keeps its namespace, slashes and dots', (
      tester,
    ) async {
      await pumpPage(tester);

      await editTextProperty(tester, 'Texture path', 'minecraft:font/ascii.png');

      expect(store.state.selectedFont?.texturePath, 'minecraft:font/ascii.png');
      expect(store.state.unsavedChanges, NavigationEntry.font);
    });

    testWidgets('an invalid texture path keeps the dialog open', (
      tester,
    ) async {
      await pumpPage(tester);

      await editTextProperty(tester, 'Texture path', 'Not A Path');

      expect(
        find.text('Invalid texture path (e.g. "minecraft:font/ascii.png")'),
        findsOneWidget,
      );
      expect(store.state.selectedFont?.texturePath, isNot('Not A Path'));
    });

    testWidgets('an emptied height becomes 0', (tester) async {
      await pumpPage(tester);

      await editTextProperty(tester, 'Height', '');

      expect(store.state.selectedFont?.height, 0);
    });
```

Add the imports `../../support/property_editing.dart` and
`package:stelaris/api/util/navigation.dart` (if missing), and remove the `text_input_card.dart`
import. If the font in `pumpPage` already has height 0, set it to 8 there, so the last test sees a
change.

- [ ] **Step 2: Run the tests and check they fail**

Run: `flutter test test/feature/font/font_detail_page_test.dart`
Expected: the three tests FAIL, because no `PropertyCard` with these labels exists.

- [ ] **Step 3: Rewrite `font_general_page.dart`**

```dart
import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/selected_font_state.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_grid.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';

/// The font's General tab: its provider and the face it renders with
/// (texture path, ascent, height).
class FontGeneralPage extends StatelessWidget {
  const FontGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedFontView>(
      vm: () => SelectedFontFactory(),
      builder: (context, vm) {
        final font = vm.selected;
        void update(FontModel changed) =>
            context.dispatch(UpdateFontAction(changed));
        final numberFormatters = [
          FilteringTextInputFormatter.allow(fontNumberPattern),
        ];
        return PropertyGrid(
          properties: [
            TextProperty(
              label: context.l10n.card_font_provider,
              value: font.provider ?? emptyString,
              formatters: [stringPatternFormatter],
              onChanged: (value) => update(font.copyWith(provider: value)),
            ),
            TextProperty(
              label: context.l10n.card_font_texture_path,
              value: font.texturePath ?? emptyString,
              hintText: 'minecraft:font/ascii.png',
              validator: Validators.pattern(
                adventureKeyPattern,
                context.l10n.validation_texture_path_invalid,
              ),
              onChanged: (value) => update(font.copyWith(texturePath: value)),
            ),
            TextProperty(
              label: context.l10n.card_ascent,
              tooltip: context.l10n.tooltip_ascent,
              value: font.ascent.toString(),
              keyboardType: numberInput,
              formatters: numberFormatters,
              onChanged: (value) =>
                  update(font.copyWith(ascent: int.tryParse(value) ?? 0)),
            ),
            TextProperty(
              label: context.l10n.card_height,
              tooltip: context.l10n.tooltip_height,
              value: font.height.toString(),
              keyboardType: numberInput,
              formatters: numberFormatters,
              onChanged: (value) =>
                  update(font.copyWith(height: int.tryParse(value) ?? 0)),
            ),
          ],
        );
      },
    );
  }
}
```

Check the model's type name (`FontModel`) and the factory's view type in
`selected_font_state.dart`, and keep whatever they are.

- [ ] **Step 4: Run the tests and check they pass**

Run: `flutter analyze`, then `flutter test test/feature/font` and the same with
`--platform chrome`.
Expected: no new issues, all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/feature/font/font_general_page.dart test/feature/font/font_detail_page_test.dart
git commit -m "feat(font): edit the general fields in dialogs"
```

### Task 5: Sound General tab

**Files:**
- Modify: `lib/feature/sound/sound_general_page.dart` (whole file)
- Modify: `test/feature/sound/sound_detail_page_test.dart:94-125`

**Interfaces:**
- Consumes: `TextProperty`, `PropertyGrid`, `editTextProperty`.

- [ ] **Step 1: Move the sound tests onto the dialogs**

Replace the `fieldOf`/`enterAndBlur` helpers and the test after them with:

```dart
    testWidgets('the key keeps its dots and the subtitle its spaces', (
      tester,
    ) async {
      await pumpPage(tester);

      await editTextProperty(tester, 'Key', 'entity.player.hurt');
      await editTextProperty(tester, 'Subtitle', 'Player hurt');

      expect(store.state.selectedSoundEvent?.keyName, 'entity.player.hurt');
      expect(store.state.selectedSoundEvent?.subTitle, 'Player hurt');
    });

    testWidgets('an invalid key keeps the dialog open', (tester) async {
      await pumpPage(tester);
      final before = store.state.selectedSoundEvent?.keyName;

      await editTextProperty(tester, 'Key', 'Not A Key');

      expect(find.byType(FormDialog), findsOneWidget);
      expect(store.state.selectedSoundEvent?.keyName, before);
    });
```

Keep the assertions the old test had if they differ from the above. Add the imports
`../../support/property_editing.dart` and `package:stelaris/feature/base/dialog/form_dialog.dart`,
and remove `text_input_card.dart`.

- [ ] **Step 2: Run the tests and check they fail**

Run: `flutter test test/feature/sound/sound_detail_page_test.dart`
Expected: the two tests FAIL.

- [ ] **Step 3: Rewrite `sound_general_page.dart`**

```dart
import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_grid.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';

/// The sound's General tab: its key and subtitle.
class SoundGeneralPage extends StatelessWidget {
  const SoundGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SoundEventModel>(
      converter: (store) => store.state.selectedSoundEvent!,
      builder: (context, sound) {
        String? required(String? value) =>
            checkIfEmptyAndReturnErrorString(value ?? emptyString, context);
        return PropertyGrid(
          properties: [
            TextProperty(
              label: context.l10n.sound_key,
              value: sound.keyName,
              // A resource location, e.g. `entity.player.hurt` or
              // `custom:ui/click`.
              validator: (value) =>
                  required(value) ??
                  Validators.pattern(
                    adventureKeyPattern,
                    context.l10n.validation_sound_key_invalid,
                  )(value),
              onChanged: (value) => context.dispatch(
                UpdateSoundAction(sound.copyWith(keyName: value)),
              ),
            ),
            TextProperty(
              label: context.l10n.sound_subtitle,
              value: sound.subTitle,
              validator: required,
              onChanged: (value) => context.dispatch(
                UpdateSoundAction(sound.copyWith(subTitle: value)),
              ),
            ),
          ],
        );
      },
    );
  }
}
```

Read the current file first and keep its way of reading the sound (factory, view model or
converter) and the exact field types; the code above assumes `keyName` and `subTitle` are non-null
strings.

- [ ] **Step 4: Run the tests and check they pass**

Run: `flutter analyze`, then `flutter test test/feature/sound` and the same with
`--platform chrome`.
Expected: no new issues, all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/feature/sound/sound_general_page.dart test/feature/sound/sound_detail_page_test.dart
git commit -m "feat(sound): edit the general fields in dialogs"
```

### Task 6: Notification page

**Files:**
- Modify: `lib/feature/notification/notification_page_general.dart` (whole file)
- Modify: `test/feature/notification/notification_detail_page_test.dart:78-109`

**Interfaces:**
- Consumes: `TextProperty`, `ChoiceProperty`, `PropertyGrid`, `editTextProperty`, `pickChoice`.

- [ ] **Step 1: Move the notification tests onto the dialogs**

Replace the `fieldOf`/`enterAndBlur` helpers and the test after them with:

```dart
    testWidgets('the title keeps digits, punctuation and umlauts', (
      tester,
    ) async {
      await pumpPage(tester);

      await editTextProperty(tester, 'Title', 'Level 5 – Glückwunsch!');

      expect(store.state.selectedNotification?.title, 'Level 5 – Glückwunsch!');
    });

    testWidgets('the frame type is picked in a dialog', (tester) async {
      await pumpPage(tester);
      final other = FrameType.values.firstWhere(
        (type) => type != store.state.selectedNotification?.frameType,
      );

      await pickChoice(tester, 'FrameType', other.displayName);

      expect(store.state.selectedNotification?.frameType, other);
      expect(store.state.unsavedChanges, NavigationEntry.notifications);
    });
```

Add the imports `../../support/property_editing.dart`, `package:stelaris/api/util/navigation.dart`
and `package:stelaris_models/stelaris_models.dart` (if missing), and remove
`text_input_card.dart`. The test "shows the notification edit form below the back bar" checks for
the page and must keep passing.

- [ ] **Step 2: Run the tests and check they fail**

Run: `flutter test test/feature/notification/notification_detail_page_test.dart`
Expected: the two tests FAIL.

- [ ] **Step 3: Rewrite `notification_page_general.dart`**

```dart
import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/notification/selected_notification_state.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_grid.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The notification's page: its material, title and frame type.
class NotificationGeneralPage extends StatelessWidget {
  const NotificationGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedNotificationView>(
      vm: () => SelectedNotificationFactory(),
      builder: (context, vm) {
        final notification = vm.selected;
        void update(NotificationModel changed) =>
            context.dispatch(UpdateNotificationAction(changed));
        return PropertyGrid(
          properties: [
            TextProperty(
              label: context.l10n.card_material,
              value: notification.material ?? emptyString,
              hintText: defaultMaterial,
              validator: (value) {
                if (value == null) return null;
                if (!minecraftPattern.hasMatch(value)) {
                  return context.l10n.input_validation_material;
                }
                return null;
              },
              onChanged: (value) =>
                  update(notification.copyWith(material: value)),
            ),
            TextProperty(
              label: context.l10n.card_title,
              value: notification.title ?? emptyString,
              onChanged: (value) => update(notification.copyWith(title: value)),
            ),
            ChoiceProperty<FrameType>(
              label: context.l10n.card_frame_type,
              value: notification.frameType,
              options: FrameType.values,
              display: (type) => type.displayName,
              onChanged: (type) =>
                  update(notification.copyWith(frameType: type)),
            ),
          ],
        );
      },
    );
  }
}
```

Read the current imports first and take `SelectedNotificationFactory`'s import path and
`defaultMaterial`'s location from them. If `frameType` is nullable in the model, give the
`ChoiceProperty` the model's default frame type for null.

- [ ] **Step 4: Run the tests and check they pass**

Run: `flutter analyze`, then `flutter test test/feature/notification` and the same with
`--platform chrome`.
Expected: no new issues, all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/feature/notification/notification_page_general.dart test/feature/notification/notification_detail_page_test.dart
git commit -m "feat(notification): edit the fields in dialogs"
```

### Task 7: Remove the input cards and the form registry

**Files:**
- Delete: `lib/feature/base/base_card.dart`, `lib/feature/base/cards/text_input_card.dart`,
  `lib/feature/base/cards/dropdown_card.dart`, `lib/feature/base/unsaved/detail_forms.dart`
- Delete: `test/feature/base/cards/text_input_card_test.dart`,
  `test/feature/base/cards/text_input_card_focus_test.dart`
- Modify: `lib/feature/base/unsaved/unsaved_changes_guard.dart:38-43`
- Modify: `test/feature/base/unsaved/unsaved_changes_guard_test.dart` (the `DetailForms` test
  around lines 120-140)

- [ ] **Step 1: Find the leftovers**

Run: `grep -rn "BaseCard\|TextInputCard\|DropdownCard\|DetailForms\|RegisterDetailForm\|MarkUnsavedChangesAction" lib test`
Expected: only the files listed above, `unsaved_actions.dart` (the action's definition) and its
tests. If `MarkUnsavedChangesAction` has no user left in `lib`, delete it and its tests too.

- [ ] **Step 2: Drop the registry from the save**

In `saveUnsavedChanges` remove the `DetailForms.validateAll()` line, the unfocus with the "fields
commit their value on blur" comment, and the `endOfFrame` wait before it. Nothing commits on blur
any more. Remove the `detail_forms.dart` import. In `unsaved_changes_guard_test.dart` delete the
test that registers a form and checks `DetailForms.validateAll()`, and its import.

- [ ] **Step 3: Delete the cards and their tests**

```bash
git rm lib/feature/base/base_card.dart lib/feature/base/cards/text_input_card.dart \
  lib/feature/base/cards/dropdown_card.dart lib/feature/base/unsaved/detail_forms.dart \
  test/feature/base/cards/text_input_card_test.dart \
  test/feature/base/cards/text_input_card_focus_test.dart
```

- [ ] **Step 4: Check for unused translations and constants**

Look for l10n keys and constants that only the deleted cards used (for example `error_card_empty`
is still used by `checkIfEmptyAndReturnErrorString`; keep it). Remove only the ones with no user
left in `lib` or `test`, then run `flutter gen-l10n`.

- [ ] **Step 5: Run everything**

Run: `flutter analyze`, `flutter test` and `flutter test --platform chrome`.
Expected: no new issues, all PASS.

- [ ] **Step 6: Commit**

```bash
git add -A lib/feature/base lib/l10n test/feature/base
git status --short   # check that lib/main.dart is not staged
git commit -m "chore(base): remove the input cards and the form registry"
```
