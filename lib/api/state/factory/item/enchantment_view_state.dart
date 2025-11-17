import 'package:async_redux/async_redux.dart';
import 'package:stelaris/api/model/item/item_enchantment_dto.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_page.dart';
import 'package:stelaris/feature/item/enchantment_reducer.dart';
import 'package:vulpes_data/api/enchantment.dart';

class EnchantmentViewFactory
    extends VmFactory<AppState, ItemEnchantmentPage, EnchantmentView> {
  EnchantmentViewFactory();

  @override
  EnchantmentView fromStore() {
    return EnchantmentView(
      selected: state.selectedItem!,
    );
  }
}

class EnchantmentView extends Vm with EnchantmentReducer {
  EnchantmentView({
    required this.selected,
  }) : super(equals: [selected]);

  final ItemModel selected;

  /// A lookup map of selected enchantments for efficient access.
  Map<String, ItemEnchantmentDto> get selectedEnchantmentMap =>
      {for (var e in selected.enchantments.items) e.name: e};

  /// A filtered list of active enchantments based on what's been selected.
  List<Enchantment> get activeEnchantments {
    final allEnchantments = getEnchantments(selected);
    return allEnchantments
        .where((ench) => selectedEnchantmentMap.containsKey(ench.minecraftValue))
        .toList();
  }
}