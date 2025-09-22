import 'package:flutter/material.dart';
import 'package:stelaris/api/model/data_model.dart';
import 'package:stelaris/feature/base/model_content_tab_page.dart';
import 'package:stelaris/feature/base/paginated_model_list.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/typedefs.dart';

/// A paginated, non-breaking alternative to [BaseModelViewTabs] that supports lazy-loading.
///
/// This widget combines the [PaginatedModelList] with the tabbed content view from
/// [ModelContentTabPage], providing a consistent layout for screens that require
/// infinite scrolling for the model list.
class PaginatedBaseModelViewTabs<E extends DataModel> extends StatelessWidget {
  /// Properties for the PaginatedModelList
  final MapToDataModelItem<E> mapToDataModelItem;
  final VoidCallback openFunction;
  final E? selectedItem;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final Function(E) callFunction;
  final List<E> models;
  final bool Function(E) compareFunction;

  /// New pagination hooks required by PaginatedModelList
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  /// Properties for the ModelContentTabPage
  final TabMapFunction<E> page;
  final MapToTabPages tabPages;
  final List<Tab> tabs;

  const PaginatedBaseModelViewTabs({
    required this.mapToDataModelItem,
    required this.openFunction,
    required this.selectedItem,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.callFunction,
    required this.models,
    required this.compareFunction,
    required this.page,
    required this.tabPages,
    required this.tabs,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaginatedModelList<E>(
            mapToDataModelItem: mapToDataModelItem,
            selectedItem: selectedItem,
            openFunction: openFunction,
            mapToDeleteDialog: mapToDeleteDialog,
            mapToDeleteSuccessfully: mapToDeleteSuccessfully,
            callFunction: callFunction,
            models: models,
            compareFunction: compareFunction,
            onLoadMore: onLoadMore,
            hasMore: hasMore,
            isLoadingMore: isLoadingMore,
          ),

          verticalSpacing10,
          Expanded(
            child: ModelContentTabPage<E>(
              selectedItem: selectedItem,
              page: page,
              tabPages: tabPages,
              tabs: tabs,
            ),
          ),
        ],
      ),
    );
  }
}