# Stelaris UI wireframes

Low-fidelity wireframes of every screen, dialog and major state of the
Flutter app, derived from the widget code in `lib/` (labels are the English
strings from `lib/l10n`). Desktop frames are 1440×900; `48` is a 420 px
compact frame.

Boxes with a cross are icons or images. Yellow dashed boxes are designer
notes, not UI. All other colours are the app's real Material 3 light
scheme: `ColorScheme.fromSeed(seedColor: Colors.green[400], secondary:
Colors.green[200])`, computed with material-color-utilities (tonal spot),
the same algorithm Flutter uses.

## Click dummy in Penpot

`stelaris-click-dummy.penpot` is a native Penpot file. Import it in the
Penpot dashboard via *Projects → ⋯ → Import Penpot files* (or drag the file
onto the dashboard).

- One page *Click-Dummy*, boards grouped in rows: Auth & Projects · Lists ·
  Detail pages · Settings, Build, Palette & more · Model dialogs.
- Press *Play* (view mode) to click through it. Two flows are set up:
  **Sign in → Projects → App** (starts at the splash) and **App: Items**.
- About 450 hotspots: navigation rail, app-bar actions (search opens the
  command palette, project badge/settings, build, account), cards → detail
  pages, Add/Delete/Info/Notes → dialogs, tabs, palette entries. Dialog
  buttons and the × go back to the previous screen. Leaving a detail page
  with unsaved edits (Items, Fonts, Sound) goes through the guard dialog.
- Hotspots are invisible rectangles named `hotspot → 20` / `hotspot ← back`
  on top of each board; select one to edit its interaction.
- The M3 roles are library colours (`M3 Light/primary`, `…/surface`, …);
  fills and strokes reference them, so changing a library colour recolours
  the screens.
- Rectangles, circles and lines are native shapes, labels are editable text
  (Work Sans / Roboto Mono, loaded by Penpot from Google Fonts).

Built with Penpot's own `@penpot/library` 1.1.0. The library cannot create
flows, so `patch_flows.py` adds them to the page afterwards.

**Alternative:** drag `all-screens.svg` or single SVGs onto the canvas.
Shapes stay editable, but text may import as SVG content and there are no
interactions.

## Regenerate

The wireframes are code, so they can follow the UI:

```sh
python3 tool/wireframes/build.py               # SVGs
cd tool/wireframes/penpot && npm ci && npm run build   # click dummy
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
