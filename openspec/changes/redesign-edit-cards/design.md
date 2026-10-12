# Design

## Context

See proposal.md and specs/edit-cards/spec.md.

- The model card (`ModelGridCard`) is a `Card.filled` in `surfaceContainerLow` with the name and key
  on top, the first line of the notes, a divider and a "last edited" footer. A click opens the
  model's page, the corner holds the model menu and the delete button.
- The component card (`_ComponentCard` in `item_components_page.dart`) copies that look on purpose
  ("Same look as the model grid cards"), with the component name on top and a summary of the value
  below. A click opens the edit dialog.
- The first attempt on `feature/propertyDialogs` added `Property`, `PropertyCard`, `PropertyGrid`
  and text and choice dialogs. Its cards were model cards with the label in bold on top, the value
  small below and a minimum height of 104.
- Three pages still edit inline. Their fields are these.
  - **Font, General tab**: provider and texture path (text, with a hint), ascent and height
    (numbers, each with a help text).
  - **Sound, General tab**: key and subtitle (text).
  - **Advancement**: material (text with material suggestions, at most 64 characters), title and
    description (text components), frame (choice of task, goal and challenge), parent (choice,
    with "none" for a root), background (text, only for a root, at most 100 characters) and
    position X and Y (decimals, with a help text). The display flags above them (hidden, show
    toast, announce to chat) are segmented buttons and already edit in place.

## Goals / Non-Goals

**Goals:**

- A card shows by its look whether a click opens a page or a dialog.
- A field card reads at a glance, the value is what stands out.
- One way of editing plain fields across the app, and the input cards and form registry go.

**Non-Goals:**

- Changing the model card, the lore list or the item components dialog itself.
- Changing models, actions, the API or routes.
- Saving from a field's dialog straight to the backend. The header's save stays the one way to
  persist a page.
- The display flags of an advancement. They stay segmented buttons, a toggle needs no dialog.

## Decisions

### Two families, told apart by fill and outline

Navigation cards keep the filled look of today. Edit cards are outlined cards
(`Card.outlined`, an `outlineVariant` border and no fill), with the same corner radius from the
shape scale. On hover and focus an edit card shows a pencil icon in its corner, the same place the
model card has its menu, so the corner reads as "edit" there and as "more" on a model card.

*Alternative considered*: one look for both, with only the pencil telling them apart. Rejected,
the pencil appears only on hover, and the grid alone should tell a list of models from a set of
fields.

### Anatomy of an edit card

From top to bottom, with 16 on the sides and 12 at the top and bottom.

1. A row with the kind's icon (20, `onSurfaceVariant`) and the label (`labelMedium`,
   `onSurfaceVariant`). The pencil sits at the end of this row.
2. The value (`titleMedium`, one line, ellipsis). An empty value shows its placeholder in
   `onSurfaceVariant`.
3. Optionally the footer (`bodySmall`, `onSurfaceVariant`, at most two lines) with the rule or
   hint, e.g. "Key from the item registry" or "Decimal, may be negative". No divider, that one
   belongs to the model card's timestamp.

The card is as high as its content. With a footer it is about 96 high, without one about 72.

A field with a help text that is too long for the footer keeps the info button of the first
attempt, which opens the help in a dialog.

### Icons by kind

| Kind | Icon |
|---|---|
| Text | `short_text` |
| Key or path | `key` for keys, `image_outlined` for texture paths |
| Number | `tag` |
| Choice | `list` |
| Material | the material's own icon where the app has one, else `category` |
| Text component | `text_fields` |

### Text components

A text component card spans the full row of its section. Instead of the value line it shows the
text through `ComponentPreview`, in the `ComponentContext` of where it appears (white for a title,
green or dark purple for a description, by the frame). Its dialog is `ComponentDialog` with the
`MiniMessageEditor`. The value is stored as today, a vanilla JSON text component in a string,
converted with `MiniMessageJson`, and an emptied field stores null.

### Fields as data

A page describes its fields as a list of sections, each a heading and a list of fields. A field is
one of a small sealed set, `TextEdit`, `ChoiceEdit` and `TextComponentEdit`. Numbers are a
`TextEdit` with a number keyboard and formatter, materials one with `suggestsMaterials`. The suffix keeps them apart from Flutter's `TextField` and the existing
`TextComponentField`. Each carries its label, value, icon, footer, rules and what to dispatch on a
change. The page keeps reading its model and dispatching its own update action, as on the first
attempt. A shared `EditCardGrid` builds the sections, the cards and the dialogs.

The sections of the three pages are these.

- **Font**: "Source" (provider, texture path) and "Metrics" (ascent, height).
- **Sound**: "Event" (key, subtitle). Not "General", that is already the tab.
- **Advancement**: the display flags as today, then "Display" (material, frame, parent and, for a
  root, background), "Text" (title, description) and "Position" (X, Y).

### The component card joins the edit cards

The component card becomes an outlined edit card. Unlike a field card its main text is the
component's name, with the summary of today as the line below it, its icon the category's icon and
its footer the default hint ("Overrides the default" or the category). Removing a component stays in its corner next to the pencil. Its grid
keeps its own layout, it has no sections.

### Staging and saving

As on the first attempt, saving a dialog dispatches the page's update action and
`MarkUnsavedChangesAction`. With no form fields left on the page, the header's save and
`saveUnsavedChanges` no longer call `DetailForms.validateAll()`, the dialogs validate instead.

## Risks / Trade-offs

- **More clicks for quick edits.** Changing two numbers now takes two dialogs. The dialogs open
  with the value selected and save on Enter, so a change stays a click, a few keys and Enter.
- **Tests that typed into input cards** have to go through the dialogs. A shared test helper, as on
  the first attempt, keeps them short.
- **The component card changes its look** in a tab that otherwise stays the same. That is the
  point of the two families, but it is a visible change in a finished feature.

## Resolved Questions

- **The component card keeps the component's name as its main text.** On a field card one looks
  for the value, among components for the component, and a summary like "Nutrition: 6,
  Saturation: 2.4" is too long to lead. The summary is the line below it.
- **The density stays as in the font prototype.** Outlined cards of about 72 to 96 tell themselves
  apart from the filled model cards well enough.
