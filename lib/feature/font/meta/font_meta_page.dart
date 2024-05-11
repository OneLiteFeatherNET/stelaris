import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/factory/font/selected_font_state.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/font/meta/char_card.dart';

class FontMetaPage extends StatelessWidget {
  const FontMetaPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedFontView>(
      vm: () => SelectedFontFactory(),
      builder: (context, vm) {
        return Stack(
          children: [
            const SingleChildScrollView(
              child: Wrap(
                clipBehavior: Clip.hardEdge,
                children: [
                  CharCard(),
                ],
              ),
            ),
            SaveButton(
              callback: () => context.dispatch(FontDatabaseUpdate()),
            )
          ],
        );
      },
    );
  }
}
