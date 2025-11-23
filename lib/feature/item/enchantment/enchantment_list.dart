import 'package:stelaris/feature/base/mixins/infinite_scroll_mixin.dart';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/item/item_enchantment_dto.dart';
import 'package:stelaris/api/state/actions/item/item_enchantment_actions.dart';
import 'package:stelaris/api/state/factory/item/enchantment_view_state.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_item.dart';

class EnchantmentList extends StatefulWidget {
  const EnchantmentList({
    required this.view,
    required this.selectedEnchantmentMap,
    super.key,
  });

  final EnchantmentView view;
  final Map<String, ItemEnchantmentDto> selectedEnchantmentMap;

  @override
  State<EnchantmentList> createState() => _EnchantmentListState();
}

class _EnchantmentListState extends State<EnchantmentList> with InfiniteScrollMixin<EnchantmentList> {

  @override
  Widget build(BuildContext context) {
    if (!widget.view.hasEnchantments) {
      return const EmptyDataWidget(header: 'No enchantments added yet');
    }

    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.view.activeEnchantments.length,
        itemBuilder: (context, index) {
          final enchantment = widget.view[index];
          return EnchantmentItem(
            dto: widget.view.selectedEnchantmentMap[enchantment.minecraftValue]!,
            enchantment: enchantment,
          );
        },
      ),
    );
  }

  @override
  bool canLoadMore() {
    final enchantments = widget.view.selected.enchantments;
    return enchantments.hasNextPage;
  }

  @override
  bool isLoadingMore() => widget.view.isLoadingMore;

  @override
  void onLoadMore() {
    context.dispatch(ItemEnchantmentLoadMoreAction());
  }
}
