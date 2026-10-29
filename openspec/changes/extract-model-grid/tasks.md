# Tasks

Branch `refactor/model-grid` from `develop`, committed locally only. Commits are conventional
one-liners under `refactor(model)`, without attribution, with a minimal diff.

## 1. Extract

- [x] 1.1 Add `ModelCardFrame` with the slots of the design and move the look of `ModelGridCard`
  into it. Verify with widget tests of the frame alone: content and trailing, summary, footer only
  with text, tap. The tests of `ModelGridCard` stay unchanged and pass.
- [x] 1.2 Add `ModelGrid<T>` with columns, card height, spacing, the load-more footer and the
  infinite scroll, and build `ModelPage` on it. Verify with widget tests of the grid alone: columns
  by width, at most four, footer while loading, `onLoadMore` near the end. The tests of `ModelPage`
  stay unchanged and pass.

## 2. Check

- [x] 2.1 Run `flutter analyze` and the full `flutter test`, and check that both pass.

## Workflow follow-up

- No push or pull request until the user asks. Afterwards rebase `poc/project-models` onto it and
  build the models grid and card on `ModelGrid` and `ModelCardFrame`.
