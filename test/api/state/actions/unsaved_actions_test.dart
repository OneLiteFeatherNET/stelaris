import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  const item = ItemModel(id: 'item-1', uiName: 'Ruby Sword');

  late Store<AppState> store;

  setUp(() => store = Store<AppState>(initialState: const AppState()));

  test('is clean by default', () {
    expect(store.state.unsavedChanges, isNull);
  });

  test('selecting an item is clean, editing it marks items as unsaved',
      () async {
    await store.dispatchAndWait(SelectedItemAction(item));
    expect(store.state.unsavedChanges, isNull);

    await store.dispatchAndWait(
      UpdateItemAction(item.copyWith(uiName: 'Emerald Sword')),
    );
    expect(store.state.unsavedChanges, NavigationEntry.items);
  });

  test('each form update action marks its own section', () async {
    await store.dispatchAndWait(
      UpdateNotificationAction(const NotificationModel(uiName: 'n')),
    );
    expect(store.state.unsavedChanges, NavigationEntry.notifications);

    await store.dispatchAndWait(UpdateFontAction(const FontModel(uiName: 'f')));
    expect(store.state.unsavedChanges, NavigationEntry.font);

    await store.dispatchAndWait(
      UpdateSoundAction(SoundEventModel(uiName: 's')),
    );
    expect(store.state.unsavedChanges, NavigationEntry.sound);
  });

  test('changes to the selection outside the form actions stay clean '
      '(e.g. paginated chars, lore or loading flags)', () async {
    const font = FontModel(id: 'font-1', uiName: 'Default');
    await store.dispatchAndWait(SelectFontAction(font));

    // Mirrors what the chars/lore/sound-file actions do: they write the
    // selection directly, without going through UpdateFontAction.
    store.dispatchSync(_ReplaceSelectedFont(font.copyWith(uiName: 'Loaded')));

    expect(store.state.unsavedChanges, isNull);
  });

  test('removing the selection clears its own section only', () async {
    await store.dispatchAndWait(SelectedItemAction(item));
    await store.dispatchAndWait(UpdateItemAction(item));
    await store.dispatchAndWait(RemoveSelectedFont());
    expect(store.state.unsavedChanges, NavigationEntry.items);

    await store.dispatchAndWait(RemoveSelectItemAction());
    expect(store.state.unsavedChanges, isNull);
  });

  test('clearUnsavedChanges only clears the matching section', () {
    const dirty = AppState(unsavedChanges: NavigationEntry.items);
    expect(
      dirty.clearUnsavedChanges(NavigationEntry.font).unsavedChanges,
      NavigationEntry.items,
    );
    expect(dirty.clearUnsavedChanges(NavigationEntry.items).unsavedChanges, isNull);
  });

  test('DiscardUnsavedChangesAction clears the flag', () async {
    await store.dispatchAndWait(UpdateItemAction(item));
    await store.dispatchAndWait(DiscardUnsavedChangesAction());
    expect(store.state.unsavedChanges, isNull);
  });
}

class _ReplaceSelectedFont extends ReduxAction<AppState> {
  _ReplaceSelectedFont(this.font);

  final FontModel font;

  @override
  AppState reduce() => state.copyWith(selectedFont: font);
}
