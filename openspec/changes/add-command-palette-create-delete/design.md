# Design

## Context

See proposal.md and specs/command-palette-create-delete/spec.md.

- Every list page builds its create dialog in a private `_openCreationDialog` or `_openDialog`: a
  `ModelCreateDialog(title, projectNamespace, onSubmit)` whose `onSubmit` builds the model and
  dispatches the kind's add action. The five copies differ only in title, model type and action.
- `ModelDetailActions._openDelete` is the detail page's delete flow:
  1. Show `ModelDeleteDialog`, which asks for the name.
  2. On success, dispatch `DiscardUnsavedChangesAction` and the kind's remove action.
  3. Go to the list.

  The grid card uses `DeleteModelButton`, with the same dialog.
- `Roles.admin` is documented as "may delete models" and `Roles.editor` as "may create and change
  models". Today only `EntryActions` (sub-entries) is role-gated. The model delete buttons from the
  search overhaul are not.

## Goals / Non-Goals

**Goals:**

- One create dialog per kind and one delete flow, shared by pages and palette, so they cannot
  drift.
- Deleting from the palette is at least as guarded as deleting on the page.

**Non-Goals:**

- Gating the existing delete buttons. That is a separate fix, noted in the proposal.
- An Info entry in the drill-down, bulk actions, or undo.

## Decisions

### Shared create dialog

```
lib/feature/model/model_create.dart
  Future<bool> openModelCreateDialog(BuildContext context, NavigationEntry entry, String projectKey)
```

It holds the five `(title, build model, add action)` variants in one `switch`, shows
`ModelCreateDialog`, and returns whether a model was submitted. The pages' `onAdd` call it, and
their private copies are removed. Notifications and attributes keep `dispatchAndWait`, as before.

### Shared delete flow

```
lib/feature/model/model_delete.dart
  Future<bool> confirmAndDeleteModel<E>(BuildContext context, {
    required NavigationEntry entry, required String title, String? warning,
    required String name, required String namespacedKey, required E model,
    required ReduxAction<AppState> Function(E) removeAction, bool returnToList = false })
```

The body of `_openDelete` moves here unchanged. `ModelDetailActions` calls it with
`returnToList: true`. The palette's drill-down entry calls it with `returnToList` set when the user
is on that entity's detail page, so deleting the open model from the palette doesn't leave a stale
detail page behind.

### Palette side

- **Create commands**: five registry commands in a new `CommandGroup.create`, which sits after
  Navigation in group order. They require `Roles.editor`. `run` reads the project key from the
  store, awaits `openModelCreateDialog`, and on `true` goes to the kind's list unless already
  there.
- **Delete children**:
  - `EntityProvider` appends a "Delete…" child to every entity, after the tab children where
    there are tabs.
  - Attributes and notifications get `children` holding only that entry.
  - The child is added only when `context.state.auth.hasRole(Roles.admin)`. Drill-down children are
    not filtered through the registry, so the provider checks the role itself.
- **"Delete this …" commands**: registry commands per kind with a detail page. They require
  `Roles.admin` and are available when the location is that kind's detail route and the selection
  is set. They call `confirmAndDeleteModel` with `returnToList: true`.
- Per-kind delete parameters (title, warning, remove action, key) sit in one table on the palette
  side. They mirror the detail pages' `ModelDetailActions` arguments. A test pins both to the same
  l10n keys and actions.

## Risks / Trade-offs

- [Now every entity shows `›`] → That is accurate: every entity can be stepped into now. The
  drill-down hint reads "Tabs", which fits attributes poorly. The footer hint becomes "More",
  neutral for tabs and actions alike.
- [Delete is one Enter away inside the drill-down] → It is the last entry, never the first, and it
  opens the confirmation that needs the typed name. An accidental Enter cannot delete.
- [The model delete buttons outside the palette stay ungated] → Noted in the proposal as a
  follow-up. Changing it here would change pages this change is not about.

## Migration Plan

Additive for users. The page refactor keeps each page's create and delete behavior; the existing
page and card tests cover that. Rollback means reverting the change.
