import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_page.dart';
import 'package:stelaris/feature/item/enchantment_reducer.dart';
import 'package:vulpes_data/api/enchantment.dart';

class EnchantmentViewFactory
    extends VmFactory<AppState, ItemEnchantmentPage, EnchantmentView> {
  EnchantmentViewFactory();

  @override
  EnchantmentView fromStore() {
    return EnchantmentView(selected: state.selectedItem!);
  }
}

class EnchantmentView extends Vm with EnchantmentReducer {
  EnchantmentView({required this.selected}) : super(equals: [selected]);

  final ItemModel selected;

  // General cache of the root enchantments which are available
  List<Enchantment> get enchantments => getEnchantments(selected);

  /// A lookup map of selected enchantments for efficient access.
  Map<String, ItemEnchantmentDto> get selectedEnchantmentMap => {
    for (var e in selected.enchantments.items) e.name: e,
  };

  /// A filtered list of active enchantments based on what's been selected.
  List<Enchantment> get activeEnchantments {
    return enchantments
        .where(
          (ench) => selectedEnchantmentMap.containsKey(ench.minecraftValue),
        )
        .toList();
  }

  List<Enchantment> get selectableEnchantments =>
      getEnchantments(selected, true);

  /// Overwrites the default index operator to access the active enchantments
  /// [index] the index to access the data
  /// Returns the [Enchantment] that matches the given [index]
  Enchantment operator [](int index) => activeEnchantments[index];

  /// Returns true if there are any active enchantments
  bool get hasEnchantments => activeEnchantments.isNotEmpty;

  /// Returns true if there are more enchantments to load
  bool get isLoadingMore => selected.isLoadingMoreEnchantments;
}
