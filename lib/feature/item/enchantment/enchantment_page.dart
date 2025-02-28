import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/item/enchantment_view_state.dart';
import 'package:stelaris/feature/dialogs/item_enchantments_dialog.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_actions.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_list.dart';
import 'package:stelaris/util/constants.dart';

class EnchantmentPage extends StatefulWidget {
  const EnchantmentPage({super.key});

  @override
  State<EnchantmentPage> createState() => _EnchantmentPageState();
}

class _EnchantmentPageState extends State<EnchantmentPage> {
  bool _isDeleteMode = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, EnchantmentView>(
      vm: () => EnchantmentViewFactory(),
      builder: (context, vm) {
        final enchantments = vm.getEnchantmentsViaGroup(vm.selected);
        final hasEnchantments = vm.enchantments.isNotEmpty;
        final canAddMoreEnchantments = vm.canAdd(vm.selected);

        // Automatically disable delete mode if no enchantments are present
        if (_isDeleteMode && !hasEnchantments) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _isDeleteMode = false;
            });
          });
        }
        
        return Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            children: [
              verticalSpacing10,
              EnchantmentActions(
                resetFunction: () => _resetFunction(context, vm),
                saveFunction: () => _saveFunction(context, vm),
                isDeleteMode: _isDeleteMode,
                onDeleteModeChanged: (isDeleteMode) {
                  setState(() {
                    _isDeleteMode = isDeleteMode;
                  });
                },
                onAddPressed: () => _showAddEnchantmentDialog(context, vm),
                hasEnchantments: hasEnchantments,
                canAddMoreEnchantments: canAddMoreEnchantments,
              ),
              verticalSpacing10,
              Expanded(
                child: EnchantmentList(
                  enchantments: enchantments,
                  selectedEnchantments: vm.enchantments,
                  isDeleteMode: _isDeleteMode,
                  onLevelChanged: (enchantment, level) {
                    // Update enchantment level
                    StoreProvider.dispatch(
                      context,
                      UpdateEnchantmentLevelAction(
                        enchantment: enchantment,
                        level: level,
                      ),
                    );
                  },
                  onEnchantmentDeleted: (enchantment) {
                    // Delete enchantment
                    StoreProvider.dispatch(
                      context,
                      DeleteEnchantmentAction(
                        enchantment: enchantment,
                        onComplete: () {
                          // Check if we need to disable delete mode after deletion
                          if (vm.enchantments.length <= 1) {
                            setState(() {
                              _isDeleteMode = false;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetFunction(BuildContext context, EnchantmentView vm) {
    context.dispatch(ResetEnchantmentsAction(onComplete: _resetDeleteMode));
  }

  void _resetDeleteMode() {
    setState(() {
        _isDeleteMode = false;
    });
}

  void _saveFunction(BuildContext context, EnchantmentView vm) {
    // Exit delete mode if active
    if (_isDeleteMode) {
      setState(() {
        _isDeleteMode = false;
      });
    }

    // Save enchantments
    context.dispatch(
      SaveEnchantmentsAction(
        onSuccess: () {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enchantments saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onError: (error) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save enchantments: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }

  void _showAddEnchantmentDialog(BuildContext context, EnchantmentView vm) {
    showDialog(
      context: context,
      builder: (context) => ItemEnchantmentAddDialog(
        addEnchantmentCallback: (enchantment, level) {
          context.dispatch(
            AddEnchantmentAction(
              enchantment: enchantment,
              level: level,
            ),
          );
          Navigator.of(context).pop();
        },
        model: vm.selected,
        formFieldValidator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a level';
          }
          final level = int.tryParse(value);
          if (level == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}

