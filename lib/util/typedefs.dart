import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/util/copy_model_result.dart';

/// Defines all typedef function for the card which displays data from a model
typedef ValueUpdate<E> = void Function(E value);
typedef DefaultValue<E, T> = E Function(T value);

/// DismissDialog functions
typedef MapToDeleteSuccessfully<E> = bool Function(E value);

/// ModeList functions
typedef MapToDataModelItem<E extends DataModel> = Widget Function(E value);
typedef MapToDeleteDialog<E extends DataModel> = List<TextSpan> Function(
  E value,
);

/// CopyDialog functions
///
/// Returns whether [value] has related/embedded data worth offering an
/// "include relationships" choice for (e.g. an item's enchantments or a
/// font's chars). Pages whose model type never has such data simply don't
/// pass this callback, so the option never appears.
typedef HasRelationshipData<E extends DataModel> = bool Function(E value);

/// Dispatches the copy of [value] described by [result] and reports whether
/// it was accepted, mirroring [MapToDeleteSuccessfully]'s fire-and-forget
/// style.
typedef MapToCopySuccessfully<E extends DataModel> = bool Function(
  E value,
  CopyModelResult result,
);
