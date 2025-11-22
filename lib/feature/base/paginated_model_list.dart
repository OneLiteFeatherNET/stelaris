import 'package:flutter/material.dart';
import 'package:stelaris/feature/base/mixins/infinite_scroll_mixin.dart';
import 'package:stelaris/api/model/data_model.dart';
import 'package:stelaris/feature/base/button/add_button.dart';
import 'package:stelaris/feature/base/model_card.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/typedefs.dart';

/// A non-breaking, paginated alternative to [ModelList] that supports lazy-loading.
///
/// Use this to progressively migrate screens that need infinite scroll/pagination
/// while keeping existing [ModelList] usages untouched.
class PaginatedModelList<E extends DataModel> extends StatefulWidget {
  static const double _listWidth = 250;
  static const double _bottomPadding = 25;
  static const double _borderRadius = 12;

  final MapToDataModelItem<E> mapToDataModelItem;
  final E? selectedItem;
  final VoidCallback openFunction;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final Function(E) callFunction;
  final List<E> models;
  final bool Function(E) compareFunction;

  /// Pagination hooks
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  const PaginatedModelList({
    required this.mapToDataModelItem,
    required this.selectedItem,
    required this.openFunction,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.callFunction,
    required this.models,
    required this.compareFunction,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    super.key,
  });

  @override
  State<PaginatedModelList<E>> createState() => _PaginatedModelListState<E>();
}

class _PaginatedModelListState<E extends DataModel>
    extends State<PaginatedModelList<E>> with InfiniteScrollMixin<PaginatedModelList<E>> {
  late RoundedRectangleBorder _defaultCardShape;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _defaultCardShape = RoundedRectangleBorder(
      side: BorderSide(color: Theme.of(context).colorScheme.secondary),
      borderRadius: BorderRadius.circular(PaginatedModelList._borderRadius),
    );
  }

  @override
  bool canLoadMore() {
    return widget.hasMore;
  }

  @override
  bool isLoadingMore() {
    return widget.isLoadingMore;
  }

  @override
  void onLoadMore() {
    widget.onLoadMore?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: PaginatedModelList._listWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: _buildListView(),
            ),
            verticalSpacing10,
            Padding(
              padding: const EdgeInsets.only(
                  bottom: PaginatedModelList._bottomPadding),
              child: AddButton(openFunction: widget.openFunction),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    final hasFooter =
        widget.onLoadMore != null && (widget.isLoadingMore || widget.hasMore);
    final itemCount = widget.models.length + (hasFooter ? 1 : 0);

    return ListView.builder(
      controller: scrollController,
      itemCount: itemCount,
      clipBehavior: Clip.none,
      itemBuilder: (context, index) {
        if (index >= widget.models.length) {
          return _buildFooter();
        }
        return _buildListItem(context, index);
      },
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    final E model = widget.models[index];
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => widget.callFunction(model),
        child: ModelCard<E>(
          selected: widget.compareFunction(model),
          selectedCardShape: _defaultCardShape,
          mapToDeleteDialog: widget.mapToDeleteDialog,
          mapToDeleteSuccessfully: widget.mapToDeleteSuccessfully,
          mapToDataModelItem: widget.mapToDataModelItem,
          rawModel: model,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: widget.isLoadingMore
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}
