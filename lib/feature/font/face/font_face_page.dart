import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/selected_font_char_state.dart';
import 'package:stelaris/api/state/factory/font/selected_font_state.dart';
import 'package:stelaris/feature/base/button/positioned_save_button.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/l10n_ext.dart';

class FontFacePage extends StatefulWidget {
  const FontFacePage({super.key});

  @override
  State<FontFacePage> createState() => _FontFacePageState();
}

class _FontFacePageState extends State<FontFacePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedFontView>(
      vm: () => SelectedFontFactory(),
      builder: (context, vm) {
        return Form(
          key: _key,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                TextInputCard<String>(
                                  display: 'Texture Path',
                                  currentValue:
                                      vm.selected.texturePath ?? emptyString,
                                  formatter: [stringPatternFormatter],
                                  valueUpdate: (value) {
                                    if (value == vm.selected.texturePath) {
                                      return;
                                    }
                                    final oldModel = vm.selected;
                                    final newEntry = oldModel.copyWith(
                                      texturePath: value,
                                    );
                                    context.dispatch(
                                      UpdateFontAction(newEntry),
                                    );
                                  },
                                  focusOrder: const NumericFocusOrder(1),
                                ),
                                TextInputCard<int>(
                                  tooltipMessage: context.l10n.tooltip_ascent,
                                  display: context.l10n.card_ascent,
                                  currentValue: vm.selected.ascent.toString(),
                                  valueUpdate: (value) {
                                    final parsedValue =
                                        int.tryParse(value) ?? 0;
                                    if (parsedValue == vm.selected.ascent) {
                                      return;
                                    }
                                    final oldModel = vm.selected;
                                    final newEntry = oldModel.copyWith(
                                      ascent: parsedValue,
                                    );
                                    context.dispatch(
                                      UpdateFontAction(newEntry),
                                    );
                                  },
                                  inputType: numberInput,
                                  formatter: [
                                    FilteringTextInputFormatter.allow(
                                      fontNumberPattern,
                                    ),
                                  ],
                                  focusOrder: const NumericFocusOrder(2),
                                ),
                                TextInputCard<int>(
                                  tooltipMessage: context.l10n.tooltip_height,
                                  display: context.l10n.card_height,
                                  currentValue: vm.selected.height.toString(),
                                  valueUpdate: (value) {
                                    final parsedValue =
                                        int.tryParse(value) ?? 0;
                                    if (parsedValue == vm.selected.height) {
                                      return;
                                    }
                                    final oldModel = vm.selected;
                                    final newEntry = oldModel.copyWith(
                                      height: parsedValue,
                                    );
                                    context.dispatch(
                                      UpdateFontAction(newEntry),
                                    );
                                  },
                                  inputType: numberInput,
                                  formatter: [
                                    FilteringTextInputFormatter.allow(
                                      fontNumberPattern,
                                    ),
                                  ],
                                  focusOrder: const NumericFocusOrder(3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              PositionedSaveButton.standard(
                callback: () {
                  if (_key.currentState?.validate() ?? false) {
                    context.dispatch(FontDatabaseUpdate());
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
