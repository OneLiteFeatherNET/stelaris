import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/selected_font_state.dart';
import 'package:stelaris/feature/base/button/positioned_save_button.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';

class FontGeneralPage extends StatefulWidget {
  const FontGeneralPage({super.key});

  @override
  State<FontGeneralPage> createState() => _FontGeneralPageState();
}

class _FontGeneralPageState extends State<FontGeneralPage> {
  /// Scroll controller for the scrollable content
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
                                  display: 'Variable Name',
                                  currentValue:
                                      vm.selected.variableName ?? emptyString,
                                  formatter: [
                                    FilteringTextInputFormatter.allow(
                                      stringPattern,
                                    ),
                                  ],
                                  valueUpdate: (value) {
                                    if (value == vm.selected.variableName) {
                                      return;
                                    }
                                    final oldModel = vm.selected;
                                    final newEntry = oldModel.copyWith(
                                      variableName: value,
                                    );
                                    context.dispatch(
                                      UpdateFontAction(newEntry),
                                    );
                                  },
                                  formValidator: (value) {
                                    final input = value as String;
                                    return checkIfEmptyAndReturnErrorString(
                                      input,
                                      context,
                                    );
                                  },
                                  focusOrder: const NumericFocusOrder(1),
                                ),
                                TextInputCard<String>(
                                  display: 'Provider',
                                  currentValue:
                                      vm.selected.provider ?? emptyString,
                                  formatter: [
                                    FilteringTextInputFormatter.allow(
                                      stringPattern,
                                    ),
                                  ],
                                  valueUpdate: (value) {
                                    if (value == vm.selected.provider) {
                                      return;
                                    }
                                    final oldModel = vm.selected;
                                    final newEntry = oldModel.copyWith(
                                      provider: value,
                                    );
                                    context.dispatch(
                                      UpdateFontAction(newEntry),
                                    );
                                  },
                                  focusOrder: const NumericFocusOrder(2),
                                ),
                                TextInputCard<String>(
                                  display: 'Comment',
                                  currentValue:
                                  vm.selected.comment ?? emptyString,
                                  formatter: [
                                    FilteringTextInputFormatter.allow(
                                      stringPattern,
                                    ),
                                  ],
                                  valueUpdate: (value) {
                                    if (value == vm.selected.comment) {
                                      return;
                                    }
                                    final oldModel = vm.selected;
                                    final newEntry = oldModel.copyWith(
                                      comment: value,
                                    );
                                    context.dispatch(
                                      UpdateFontAction(newEntry),
                                    );
                                  },
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
