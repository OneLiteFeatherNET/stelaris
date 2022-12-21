import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/api/util/minecraft/enchantment.dart';

/// Defines all typedef function for the card which displays data from a model
typedef ValueUpdate<E> = void Function(E? value);
typedef DefaultValue<E,T> = E Function(T value);

/// Defines all typedef functions for the SetupStepper
typedef FinishStepper<E extends DataModel> = void Function(E model);
typedef BuildModel<E extends DataModel> = E Function(String name, String description);

/// DismissDialog functions
typedef MapToDeleteSuccessfully<E> = bool Function(E value);

/// Enchantmentdialog functions
typedef AddEnchantmentCallback = void Function(Enchantment selected, int level);