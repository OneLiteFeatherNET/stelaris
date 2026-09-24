# Tasks

## 1. Draw and review the motifs

- [x] 1.1 Draw the ten SVGs in `design/icons/navigation/` following the drawing rules in design.md:
      heart, pickaxe, advancement, letters and note_block, each outlined and filled. Also draw a
      sword pair as the Attributes fallback. Verify: each file has a 24×24 viewBox and holds a single
      filled path with no strokes.
- [x] 1.2 Build an HTML preview in the scratchpad, not in the repo. It shows each motif outlined and
      filled, in light and dark, at 18px and 24px, next to the current Material icon. Publish it and
      have the user approve the motifs, heart or sword included. Verify: the user's approval in the
      conversation.

## 2. Generate the icon font

- [x] 2.1 Add `tool/generate_icons.sh`. It runs `npx fantasticon` on `design/icons/navigation/` and
      writes `assets/fonts/StelarisIcons.ttf`, with the code points fixed in
      `tool/icons.fantasticonrc.json`. fantasticon has no Dart output, so the `static const IconData`
      constants in `lib/util/stelaris_icons.dart` are kept by hand (the fallback in design.md).
      Verify: running it twice gives identical output.
- [x] 2.2 Declare the `StelarisIcons` font family in `pubspec.yaml`. Verify: `flutter pub get`
      succeeds and `flutter analyze` is clean on the generated Dart file.

## 3. Wire up the navigation

- [x] 3.1 Point the five `NavigationEntry` values at the `StelarisIcons` constants: outline for
      `data`, filled for `selected`. Verify: `flutter analyze` is clean, and the existing
      `commands_test.dart` test "the marked entry uses the filled navigation icon" passes.
- [x] 3.2 Add a test to `test/api/util/navigation_test.dart`. It checks that each entry's `data` and
      `selected` differ, that no two entries share an icon, and that all of them use the
      `StelarisIcons` font family. Verify: `flutter test test/api/util/navigation_test.dart`
      passes.

## 4. Verify

- [x] 4.1 Run the app in light and dark mode. Check the collapsed and extended rail on list and
      detail pages, and check the Ctrl+K "go to" commands. The spec scenarios hold, and icons render
      at rail size with no cropping. Verify: screenshots or a check in the browser.
- [x] 4.2 Run the full test suite and `flutter build web --release --wasm --no-web-resources-cdn`.
      Verify: tests pass and the build succeeds with icon tree-shaking on.
