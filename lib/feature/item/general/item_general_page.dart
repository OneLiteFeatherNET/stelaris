import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/selected_item_state.dart';
import 'package:stelaris/feature/base/button/positioned_save_button.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';
import 'package:stelaris/feature/item/general/item_group_card.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';

class ItemGeneralPage extends StatefulWidget {
  const ItemGeneralPage({super.key});

  @override
  State<ItemGeneralPage> createState() => _ItemGeneralPageState();
}

class _ItemGeneralPageState extends State<ItemGeneralPage> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedItemView>(
      vm: () => SelectedItemFactory<ItemGeneralPage>(),
      builder: (context, vm) {
        return Form(
          key: _formKey,
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
                                  display: context.l10n.card_name,
                                  tooltipMessage: context.l10n.tooltip_name,
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
                                      UpdateItemAction(newEntry),
                                    );
                                  },
                                  formValidator: (value) {
                                    final String input = value as String;
                                    return checkIfEmptyAndReturnErrorString(
                                      input,
                                      context,
                                    );
                                  },
                                  maxLength: 30,
                                  focusOrder: const NumericFocusOrder(1),
                                ),
                                TextInputCard<String>(
                                  display: context.l10n.card_description,
                                  currentValue:
                                      vm.selected.comment ?? emptyString,
                                  formatter: [
                                    FilteringTextInputFormatter.allow(
                                      stringWithSpacePattern,
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
                                      UpdateItemAction(newEntry),
                                    );
                                  },
                                  maxLength: 30,
                                  focusOrder: const NumericFocusOrder(2),
                                ),
                                ItemGroupCard(
                                  model: vm.selected,
                                  groupKey: GlobalKey<FormState>(),
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
                  if (_formKey.currentState?.validate() ?? false) {
                    context.dispatch(ItemDatabaseUpdate());
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
