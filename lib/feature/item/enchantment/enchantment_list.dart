import 'dart:async';

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

class _EnchantmentListState extends State<EnchantmentList> {

  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (!widget.view.hasEnchantments) {
      return const EmptyDataWidget(header: 'No enchantments added yet');
    }

    return Scrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
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

  void _onScroll() {
    if (widget.view.isLoadingMore) return;
    if (!_scrollController.hasClients) return;

    final enchantments = widget.view.selected.enchantments;
    if (!enchantments.hasNextPage) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final currentScroll = _scrollController.position.pixels;
    final triggerFetchMoreSize = maxScroll * 0.7;

    if (currentScroll >= triggerFetchMoreSize) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          context.dispatch(ItemEnchantmentLoadMoreAction());
        }
      });
    }
  }
}
