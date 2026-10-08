# Stelaris UI wireframes

Low-fidelity wireframes of every screen, dialog and major state of the
Flutter app, derived from the widget code in `lib/` (labels are the English
strings from `lib/l10n`). Desktop frames are 1440×900; `48` is a 420 px
compact frame.

Grey boxes with a cross are icons or images. Yellow dashed boxes are
designer notes, not UI. The only colour is the Material 3 primary from the
app's seed (`Colors.green[400]`).

## Import into Penpot

**Recommended:** `stelaris-wireframes.penpot` is a native Penpot file.
In the Penpot dashboard open *Projects → ⋯ → Import Penpot files* (or drag
the file onto the dashboard). You get:

- 5 pages (Auth & Projects · Lists & Model dialogs · Detail – Items,
  Notifications, Fonts · Detail – Sound & Unsaved guard · Settings, Build,
  Palette & more), one board per screen, named like the files below
- rectangles, circles and lines as native shapes, all labels as editable
  text (Work Sans / Roboto Mono, loaded from Google Fonts by Penpot)
- the wireframe palette as library colours (Primary, Primary container,
  Outline …)

Built with Penpot's own `@penpot/library` 1.1.0 (export format v1).

**Alternative:** drag `all-screens.svg` or single SVGs onto the canvas.
Shapes stay editable, but text may import as SVG content.

## Regenerate

The wireframes are code, so they can follow the UI:

```sh
python3 tool/wireframes/build.py               # SVGs
cd tool/wireframes/penpot && npm ci && npm run build   # .penpot
```

- `tool/wireframes/wf.py`: drawing kit (fields, buttons, chips, dialogs …)
- `tool/wireframes/screens_base.py`: app shell, page header, cards
- `tool/wireframes/screens_a.py`: auth, projects, list pages, model dialogs
- `tool/wireframes/screens_b.py`: detail pages and their dialogs
- `tool/wireframes/penpot/`: SVG shapes → JSON → `.penpot` via
  `@penpot/library`
- `tool/wireframes/screens_c.py`: settings, build, command palette, menus,
  snackbars, compact layout

## Screens

| # | File |
|---|---|
| 01 | [`01-splash-web-index-html.svg`](01-splash-web-index-html.svg) |
| 02 | [`02-sign-in.svg`](02-sign-in.svg) |
| 03 | [`03-project-selection-list.svg`](03-project-selection-list.svg) |
| 04 | [`04-project-selection-empty.svg`](04-project-selection-empty.svg) |
| 05 | [`05-dialog-create-project.svg`](05-dialog-create-project.svg) |
| 06 | [`06-dialog-edit-project.svg`](06-dialog-edit-project.svg) |
| 07 | [`07-dialog-switch-project.svg`](07-dialog-switch-project.svg) |
| 10 | [`10-items-list-rail-extended.svg`](10-items-list-rail-extended.svg) |
| 11 | [`11-attributes-list-rail-collapsed-filter-sort-menu.svg`](11-attributes-list-rail-collapsed-filter-sort-menu.svg) |
| 12 | [`12-list-empty-no-matches.svg`](12-list-empty-no-matches.svg) |
| 13 | [`13-dialog-edit-attribute.svg`](13-dialog-edit-attribute.svg) |
| 14 | [`14-dialog-create-model.svg`](14-dialog-create-model.svg) |
| 15 | [`15-dialog-copy-model.svg`](15-dialog-copy-model.svg) |
| 16 | [`16-dialog-delete-model-type-name.svg`](16-dialog-delete-model-type-name.svg) |
| 17 | [`17-dialog-model-info.svg`](17-dialog-model-info.svg) |
| 18 | [`18-dialogs-notes-edit-card-menu-notes-view-detail-header.svg`](18-dialogs-notes-edit-card-menu-notes-view-detail-header.svg) |
| 20 | [`20-item-detail-components-tab.svg`](20-item-detail-components-tab.svg) |
| 21 | [`21-dialog-add-component-picker.svg`](21-dialog-add-component-picker.svg) |
| 22 | [`22-dialog-edit-component-schema-form.svg`](22-dialog-edit-component-schema-form.svg) |
| 23 | [`23-item-detail-enchantments-tab-group-menu.svg`](23-item-detail-enchantments-tab-group-menu.svg) |
| 24 | [`24-dialogs-add-enchantment-update-level.svg`](24-dialogs-add-enchantment-update-level.svg) |
| 25 | [`25-item-detail-lore-tab.svg`](25-item-detail-lore-tab.svg) |
| 26 | [`26-dialogs-single-value-entry-add-character-simple-delete.svg`](26-dialogs-single-value-entry-add-character-simple-delete.svg) |
| 27 | [`27-notification-detail.svg`](27-notification-detail.svg) |
| 28 | [`28-font-detail-general-tab.svg`](28-font-detail-general-tab.svg) |
| 29 | [`29-font-detail-characters-tab.svg`](29-font-detail-characters-tab.svg) |
| 30 | [`30-sound-detail-general-tab.svg`](30-sound-detail-general-tab.svg) |
| 31 | [`31-sound-detail-entries-tab.svg`](31-sound-detail-entries-tab.svg) |
| 32 | [`32-dialog-edit-sound-file-modal.svg`](32-dialog-edit-sound-file-modal.svg) |
| 33 | [`33-dialog-unsaved-changes-guard.svg`](33-dialog-unsaved-changes-guard.svg) |
| 40 | [`40-dialog-settings.svg`](40-dialog-settings.svg) |
| 41 | [`41-dialog-build-download-download-tab.svg`](41-dialog-build-download-download-tab.svg) |
| 42 | [`42-dialog-build-download-build-tab.svg`](42-dialog-build-download-build-tab.svg) |
| 43 | [`43-command-palette-default-ctrl-k.svg`](43-command-palette-default-ctrl-k.svg) |
| 44 | [`44-command-palette-entity-mode-drilled-into-an-item.svg`](44-command-palette-entity-mode-drilled-into-an-item.svg) |
| 45 | [`45-command-palette-help-mode.svg`](45-command-palette-help-mode.svg) |
| 46 | [`46-menus-card-menu-account-menu.svg`](46-menus-card-menu-account-menu.svg) |
| 47 | [`47-snackbars-floating-550-wide.svg`](47-snackbars-floating-550-wide.svg) |
| 48 | [`48-compact-layout-600-px.svg`](48-compact-layout-600-px.svg) |
| 49 | [`49-oidc-redirect-page-web-redirect-html.svg`](49-oidc-redirect-page-web-redirect-html.svg) |
