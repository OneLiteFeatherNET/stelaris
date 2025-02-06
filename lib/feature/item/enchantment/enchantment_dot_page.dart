import 'package:flutter/material.dart';
import 'package:stelaris/api/state/factory/item/enchantment_view_state.dart';
import 'package:stelaris/api/util/minecraft/enchantment.dart';
import 'package:stelaris/feature/item/enchantment/enchantment_card.dart';
import 'package:stelaris/feature/item/enchantment/page_indicator.dart';

const int maxItemPerPage = 4;

class EnchantmentDotPage extends StatefulWidget {
  const EnchantmentDotPage({
    required this.enchantmentView,
    required this.rawEnchantments,
    super.key,
  });

  final EnchantmentView enchantmentView;
  final List<Enchantment> rawEnchantments;

  @override
  State<EnchantmentDotPage> createState() => _EnchantmentDotPageState();
}

class _EnchantmentDotPageState extends State<EnchantmentDotPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late TabController _tabController;
  late int _currentPageIndex = 0;
  late int _maxPage;

  @override
  void initState() {
    _maxPage = widget.rawEnchantments.length ~/ maxItemPerPage;
    _pageController = PageController(initialPage: 0);
    _tabController = TabController(length: _maxPage, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _maxPage,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (value) {
            debugPrint('Page changed: $value');
            setState(() {
              _currentPageIndex = value;
            });
          },
          itemBuilder: (context, index) {
            final int currentIndex = _currentPageIndex * maxItemPerPage;
            return ListView.builder(
              itemCount: maxItemPerPage,
              itemBuilder: (context, index) {
                final innerIndex =  currentIndex + index;
                final idxEnchantment = widget.rawEnchantments[innerIndex];
                return ListTile(
                  title: EnchantmentCard(
                    enchantment: idxEnchantment.name,
                    isEnchanted: true,
                  ),
                );
              },
            );
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: PageIndicator(
            tabController: _tabController,
            currentPageIndex: _currentPageIndex,
            maxIndex: _maxPage,
            onUpdateCurrentPageIndex: _updateCurrentPageIndex,
          ),
        )
      ],
    );
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
