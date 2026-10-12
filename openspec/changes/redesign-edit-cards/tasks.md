# Tasks

## 1. Edit cards

- [x] 1.1 `EditCard`: outlined, icon and label above the value, optional footer, pencil on hover
      and focus, as high as its content.
- [x] 1.2 `EditField` with `TextEdit`, and `EditSection` for a heading and its fields.
- [x] 1.3 `EditCardGrid`: sections with headings, cards in as many columns as fit.
- [x] 1.4 The text dialog: value selected, Enter saves, the footer as helper text, invalid values
      keep it open.
- [x] 1.5 `ChoiceEdit` and its dialog, a list of the options with the current one marked.
- [x] 1.6 Material fields, a `TextEdit` with `suggestsMaterials`, its dialog a text field with the
      material suggestions.
- [x] 1.7 `TextComponentEdit`: a full row, its text shown with `ComponentPreview`, edited in
      `ComponentDialog`, stored as JSON with `MiniMessageJson`.

## 2. Pages

- [x] 2.1 Font, General tab: "Source" (provider, texture path) and "Metrics" (ascent, height).
- [x] 2.2 Sound, General tab: "Event" (key, subtitle).
- [x] 2.3 Advancement: the display flags as today, then "Display", "Text" and "Position".
- [x] 2.4 The component card as an edit card, the component's name as its main text.

## 3. Clean up

- [x] 3.1 Remove `TextInputCard`, `DropdownCard`, `BaseCard` and their tests.
- [x] 3.2 Remove `DetailForms` and `RegisterDetailForm`, and their call in
      `saveUnsavedChanges`.
- [x] 3.3 Remove the strings only the old cards used.
