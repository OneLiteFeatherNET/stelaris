import 'package:flutter/material.dart';
import 'package:stelaris/api/model/data_model.dart';
import 'package:stelaris/api/util/minecraft/enchantment.dart';

/// Defines all typedef function for the card which displays data from a model
typedef ValueUpdate<E> = void Function(E value);
typedef DoubleValueUpdate<E, K> = void Function(E? value, K? key);
typedef DefaultValue<E,T> = E Function(T value);

/// DismissDialog functions
typedef MapToDeleteSuccessfully<E> = bool Function(E value);

/// Enchantmentdialog functions
typedef AddEnchantmentCallback = void Function(Enchantment selected, int level);

/// ModeList functions
typedef MapToDataModelItem<E extends DataModel> = Widget Function(E value);
typedef MapToDeleteDialog<E extends DataModel> = List<TextSpan> Function(E value);
typedef MapToTabPages = List<Tab> Function(List<Tab> pages);

/// ModelContainerList functions
typedef TabMapFunction<E extends DataModel> = Widget Function(String page, E? dataModel);
