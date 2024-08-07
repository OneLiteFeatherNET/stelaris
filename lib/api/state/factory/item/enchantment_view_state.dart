import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/util/minecraft/enchantment.dart';
import 'package:stelaris_ui/feature/item/enchantment/enchantment_page.dart';
import 'package:stelaris_ui/feature/item/enchantment_reducer.dart';

class EnchantmentViewFactory
    extends VmFactory<AppState, EnchantmentPage, EnchantmentView> {
  EnchantmentViewFactory();


  @override
  EnchantmentView fromStore() {
    return EnchantmentView(
        selected: state.selectedItem!,
      );
  }
}

class EnchantmentView extends Vm with EnchantmentReducer {
  EnchantmentView({required this.selected}) : super(equals: [selected]);

  final ItemModel selected;

  Map<String, int> get enchantments => selected.enchantments ?? {};

  List<Enchantment> getEnchantmentsViaGroup(ItemModel model) => getEnchantments(model);

  bool hasSelectedEnchantment(String enchantment) {
    return enchantments.containsKey(enchantment);
  }

  String getEnchantmentLevel(String enchantment) => enchantments[enchantment].toString();

}