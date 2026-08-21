import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/button/delete_model_button.dart';
import 'package:stelaris/util/typedefs.dart';

class ModelCard<E extends DataModel> extends StatefulWidget {
  const ModelCard({
    required this.selected,
    required this.selectedCardShape,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.mapToDataModelItem,
    required this.rawModel,
    super.key,
  });

  final bool selected;
  final RoundedRectangleBorder selectedCardShape;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final MapToDataModelItem<E> mapToDataModelItem;
  final E rawModel;

  @override
  State<ModelCard> createState() => _ModelCardState<E>();
}

class _ModelCardState<E extends DataModel> extends State<ModelCard<E>> {
  bool _isHovered = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _debouncedSetState(bool hoveredState) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _isHovered = hoveredState;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.90,
      child: Card(
        shape: widget.selected ? widget.selectedCardShape : null,
        color: _isHovered
            ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
            : null,
        child: MouseRegion(
          onEnter: (_) => _debouncedSetState(true),
          onExit: (_) => _debouncedSetState(false),
          child: ListTile(
            title: widget.mapToDataModelItem(widget.rawModel),
            trailing: DeleteModelButton<E>(
              value: widget.rawModel,
              mapToDeleteDialog: widget.mapToDeleteDialog,
              mapToDeleteSuccessfully: widget.mapToDeleteSuccessfully,
            ),
          ),
        ),
      ),
    );
  }
}
