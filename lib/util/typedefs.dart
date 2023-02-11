import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/api/tabs/tab_pages.dart';
import 'package:stelaris_ui/api/util/minecraft/enchantment.dart';

/// Defines all typedef function for the card which displays data from a model
typedef ValueUpdate<E> = void Function(E? value);
typedef DoubleValueUpdate<E, K> = void Function(E? value, K? key);
typedef DefaultValue<E,T> = E Function(T value);

typedef Validator<String> = bool Function(String?)?;

/// Defines all typedef functions for the SetupStepper
typedef FinishStepper<E extends DataModel> = void Function(E model);
typedef BuildModel<E extends DataModel> = E Function(String name, String description);

/// DismissDialog functions
typedef MapToDeleteSuccessfully<E> = bool Function(E value);

/// Enchantmentdialog functions
typedef AddEnchantmentCallback = void Function(Enchantment selected, int level);

/// ModeList functions
typedef MapToDataModelItem<E extends DataModel> = Widget Function(E value);
typedef MapToDeleteDialog<E extends DataModel> = List<TextSpan> Function(E value);

/// ModelContainerList functions
typedef TabPageMapFunction<E extends DataModel> = Widget Function(
    TabPages page, ValueNotifier<E?> notification);