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
  const ItemGeneralPage({
    super.key,
  });

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
                                  currentValue: vm.selected.variableName ?? emptyString,
                                  formatter: [
                                    FilteringTextInputFormatter.allow(
                                        stringPattern)
                                  ],
                                  valueUpdate: (value) {
                                    if (value == vm.selected.variableName) return;
                                    final oldModel = vm.selected;
                                    final newEntry =
                                        oldModel.copyWith(variableName: value);
                                    context
                                        .dispatch(UpdateItemAction(newEntry));
                                  },
                                  formValidator: (value) {
                                    final String input = value as String;
                                    return checkIfEmptyAndReturnErrorString(
                                        input, context);
                                  },
                                  maxLength: 30,
                                ),
                                TextInputCard<String>(
                                  display: context.l10n.card_description,
                                  currentValue:
                                      vm.selected.comment ?? emptyString,
                                  formatter: [
                                    FilteringTextInputFormatter.allow(
                                        stringWithSpacePattern
                                    ),
                                  ],
                                  valueUpdate: (value) {
                                    if (value == vm.selected.comment) {
                                      return;
                                    }
                                    final oldModel = vm.selected;
                                    final newEntry =
                                        oldModel.copyWith(comment: value);
                                    context
                                        .dispatch(UpdateItemAction(newEntry));
                                  },
                                  maxLength: 30,
                                ),
                                ItemGroupCard(
                                  model: vm.selected,
                                  groupKey: GlobalKey<FormState>(),
                                ),
                                TextInputCard<String>(
                                  display: context.l10n.card_material,
                                  hintText: defaultMaterial,
                                  currentValue:
                                      vm.selected.material ?? emptyString,
                                  valueUpdate: (value) {
                                    if (value == vm.selected.material) return;
                                    final oldModel = vm.selected;
                                    final newEntry =
                                        oldModel.copyWith(material: value);
                                    context
                                        .dispatch(UpdateItemAction(newEntry));
                                  },
                                  formValidator: (value) {
                                    if (value == null) return null;
                                    if (!minecraftPattern.hasMatch(value)) {
                                      return context
                                          .l10n.input_validation_material;
                                    }
                                    return null;
                                  },
                                  maxLength: 30,
                                ),
                                TextInputCard<String>(
                                  tooltipMessage:
                                      context.l10n.tooltip_displayname,
                                  display: context.l10n.card_display_name,
                                  currentValue:
                                      vm.selected.displayName ?? emptyString,
                                  valueUpdate: (value) {
                                    if (value == vm.selected.displayName) {
                                      return;
                                    }
                                    final oldModel = vm.selected;
                                    final newEntry =
                                        oldModel.copyWith(displayName: value);
                                    context
                                        .dispatch(UpdateItemAction(newEntry));
                                  },
                                  maxLength: 30,
                                ),
                                TextInputCard<int>(
                                  tooltipMessage:
                                      context.l10n.tooltip_model_data,
                                  display: context.l10n.card_model_data,
                                  currentValue:
                                      vm.selected.customModelId?.toString() ??
                                          zeroString,
                                  valueUpdate: (value) {
                                    final newValue = int.tryParse(value) ?? 0;
                                    if (newValue == vm.selected.customModelId) {
                                      return;
                                    }
                                    final oldModel = vm.selected;
                                    final newEntry = oldModel.copyWith(
                                        customModelId: newValue);
                                    context
                                        .dispatch(UpdateItemAction(newEntry));
                                  },
                                  maxLength: 30,
                                  inputType: numberInput,
                                  formatter: [
                                    FilteringTextInputFormatter.allow(
                                        numberPattern)
                                  ],
                                ),
                                TextInputCard<int>(
                                  display: context.l10n.card_amount,
                                  currentValue:
                                      vm.selected.amount?.toString() ??
                                          zeroString,
                                  valueUpdate: (value) {
                                    final updatedValue =
                                        int.tryParse(value) ?? 0;
                                    if (updatedValue == vm.selected.amount) {
                                      return;
                                    }
                                    final oldModel = vm.selected;
                                    final newEntry =
                                        oldModel.copyWith(amount: updatedValue);
                                    context
                                        .dispatch(UpdateItemAction(newEntry));
                                  },
                                  inputType: numberInput,
                                  formatter: [
                                    FilteringTextInputFormatter.allow(
                                        numberPattern)
                                  ],
                                  formValidator: (value) {
                                    if (value == null) return null;
                                    final String input = value as String;
                                    if (input.trim().isEmpty) {
                                      return context.l10n.error_card_empty;
                                    }

                                    if (int.parse(input) > maxItemSize) {
                                      return context.l10n.card_amount_to_high;
                                    }
                                    return null;
                                  },
                                  maxLength: 30,
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
              )
            ],
          ),
        );
      },
    );
  }
}
