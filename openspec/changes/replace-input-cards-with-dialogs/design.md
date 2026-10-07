# Design

## Context

Three pages still edit their fields inline:

| Page                                  | Fields                                                    |
|---------------------------------------|-----------------------------------------------------------|
| Font, General tab                     | provider, texture path (text); ascent, height (number)    |
| Sound, General tab                    | key, subtitle (text, both required)                       |
| Notification (the only page)          | material, title (text); frame type (choice)               |

Each wraps its cards in a `Form` with `FocusScope` and `FocusTraversalGroup`. On every change it
dispatches `MarkUnsavedChangesAction`, and it registers the form with `DetailForms` through
`RegisterDetailForm`. The header's save button calls `DetailForms.validateAll()` before saving
(`unsaved_changes_guard.dart`). Each field's `valueUpdate` compares the new value with the model and
dispatches the page's update action (`UpdateFontAction`, `UpdateSoundAction` or
`UpdateNotificationAction`). Those actions already set `unsavedChanges`.

These three pages are the only users of `TextInputCard`, `DropdownCard`, `BaseCard` and the form
registry.

The rest of the app edits in dialogs built on `FormDialog` (`lib/feature/base/dialog/form_dialog.dart`):
a title, content, a submit action and cancel. The components tab shows each component as a card
with its name, its category and a one-line summary, and opens the component's dialog on click.

## Goals / Non-Goals

**Goals:**
- One way of editing: the three pages show cards and edit each field in a dialog.
- Keep every field's current rules, and stage the change for the header's save.
- Remove the input cards and the form registry.

**Non-Goals:**
- Saving straight from the dialog. The header's save button stays the only way to persist these
  models.
- Changing any field's rules, including the 30-character limit on the texture path and the sound
  key, which looks accidental. That is a separate change.
- Moving the components tab's `_ComponentCard` onto `PropertyCard`. That can follow later.
- New fields, models, actions or API calls.

## Decisions

### Fields are described as data, the page stays in charge

A page builds a list of properties and hands it to a `PropertyGrid`. There are two kinds:

```dart
sealed class Property {
  String get label;
  String? get tooltip;
}

class TextProperty extends Property {
  final String label;
  final String value;              // what the field holds now
  final ValueChanged<String> onChanged;
  final String? tooltip;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter> formatters;
  final TextInputType? keyboardType;
  final int maxLength;             // defaults to 30, today's limit
}

class ChoiceProperty<T> extends Property {
  final String label;
  final T value;
  final List<T> options;
  final String Function(T option) display;
  final ValueChanged<T> onChanged;
  final String? tooltip;
}
```

- **The page keeps**:
  - reading its model through its own `StoreConnector`,
  - converting values, like `int.tryParse(value) ?? 0` for a font's ascent,
  - dispatching its update action in `onChanged`.
- **The shared code keeps**: layout, cards, dialogs, validation in the dialog, and skipping
  `onChanged` when the value didn't change.
- **Rejected: a generic property page** that reads the store and saves. Store access and saving
  differ per model. A generic page would need hooks for all of that, and its special cases would
  end up in the descriptions. The loading rework showed that this kind of indirection costs more
  than it saves.
- **Rejected: explicit widgets per field without descriptions**. Each page would repeat the card,
  the dialog call and the change check for every field.

### Shared pieces in `lib/feature/base/property/`

- `property.dart`: the `Property`, `TextProperty` and `ChoiceProperty` descriptions.
- `property_grid.dart`: `PropertyGrid(properties: [...])` lays out one `PropertyCard` per property,
  as many columns as fit, like the components grid.
- `property_card.dart`: `PropertyCard` shows the label, the current value (the hint text when the
  value is empty, otherwise "–"), the tooltip and an edit icon. A click opens the dialog for its
  property.
- `property_dialogs.dart`:
  - `showTextPropertyDialog` and `showChoicePropertyDialog` build on `FormDialog`, return the new
    value, and return `null` on cancel.
  - The text dialog has its field filled in and focused. It validates on save, and enter saves.
  - The choice dialog lists the options and marks the current one.

### Validation moves into the dialog

The text dialog runs the property's validator on save and stays open with the error while the value
is invalid. Invalid values never reach the store. That makes the header's
`DetailForms.validateAll()` check redundant, so it is removed together with `DetailForms` and
`RegisterDetailForm`. The pages also drop their `Form`, `FocusScope`, `FocusTraversalGroup` and
`MarkUnsavedChangesAction` wrapping. The update actions already mark the model unsaved.

### Rules carried over per field

| Field                     | Rules                                                                       |
|---------------------------|-----------------------------------------------------------------------------|
| Font provider             | `stringPatternFormatter`                                                    |
| Font texture path         | hint `minecraft:font/ascii.png`; `adventureKeyPattern` validator            |
| Font ascent, height       | tooltip; number keyboard; `fontNumberPattern` formatter; empty becomes `0`  |
| Sound key                 | required; `adventureKeyPattern` validator                                   |
| Sound subtitle            | required                                                                    |
| Notification material     | hint `defaultMaterial`; `minecraftPattern` validator                        |
| Notification title        | none                                                                        |
| Notification frame type   | choice of `FrameType.values`                                                |

All text fields keep `maxLength: 30`, which `TextInputCard` applies to every field today.

## Risks / Trade-offs

- **An invalid value saved before this change** stays in the model. Today it blocks the header's
  save button until fixed. After this change, saving goes through, because nothing validates the
  untouched fields any more. The backend still validates. Accepted, because the dialogs keep new
  invalid values out.
- **One click more** for a quick change: open the dialog, then type. This is the same trade the
  rest of the app already made.
- **Keyboard flow**: tabbing through all fields of a page goes away. Each card is focusable and
  opens its dialog with enter or space.

## Testing

- **Shared widgets**:
  - A card shows its value, its hint text when empty, and its tooltip.
  - A click opens the dialog with the value filled in.
  - An invalid value keeps the dialog open with the error.
  - Save calls `onChanged` with the new value. An unchanged value or cancel doesn't call it.
  - The choice dialog marks the current option and returns the picked one.
- **Pages**: the font, sound and notification detail page tests edit a field through its card and
  dialog. They check the store's model, the unsaved marker and the active header save button. One
  validation case per page, for example an invalid sound key.
- `text_input_card_test.dart` and `text_input_card_focus_test.dart` are deleted with the card.
- Run on the VM and with `--platform chrome`, as CI does.
