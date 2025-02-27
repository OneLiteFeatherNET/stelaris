import 'package:flutter/material.dart';
import 'package:stelaris/api/model/data_model.dart';
import 'package:stelaris/feature/base/button/add_button.dart';
import 'package:stelaris/feature/base/model_card.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/typedefs.dart';

/// A generic list widget that displays a collection of data models.
///
/// [E] represents the type of data model being displayed.
/// The list supports selection, deletion, and adding new items.
class ModelList<E extends DataModel> extends StatefulWidget {
  static const double _listWidth = 250.0;
  static const double _bottomPadding = 25.0;
  static const double _borderRadius = 12.0;

  final MapToDataModelItem<E> mapToDataModelItem;
  final E? selectedItem;
  final VoidCallback openFunction;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final Function(E) callFunction;
  final List<E> models;
  final bool Function(E) compareFunction;

  const ModelList({
    required this.mapToDataModelItem,
    required this.selectedItem,
    required this.openFunction,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.callFunction,
    required this.models,
    required this.compareFunction,
    super.key,
  });

  @override
  State<ModelList<E>> createState() => _ModelListState<E>();
}

class _ModelListState<E extends DataModel> extends State<ModelList<E>> {
  final ScrollController _scrollController = ScrollController();
  late RoundedRectangleBorder _defaultCardShape;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _defaultCardShape = RoundedRectangleBorder(
      side: BorderSide(color: Theme.of(context).colorScheme.secondary),
      borderRadius: BorderRadius.circular(ModelList._borderRadius),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Combine Column and SizedBox to reduce nesting
    return SizedBox(
      width: ModelList._listWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _buildListView(),
          ),
          verticalSpacing10,
          Padding(
            padding: const EdgeInsets.only(bottom: ModelList._bottomPadding),
            child: AddButton(openFunction: widget.openFunction),
          )
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.models.length,
      clipBehavior: Clip.none,
      itemBuilder: _buildListItem,
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
}