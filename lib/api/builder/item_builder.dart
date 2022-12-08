import 'dart:ffi';

import 'package:stelaris_ui/api/builder/base_builder.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/util/checks.dart';
import 'package:stelaris_ui/api/util/minecraft/enchantment.dart';

import '../util/minecraft/item_flag.dart';

const int negativeAmount = 0;
const int maximumAmount = 64;

class ItemBuilder extends BaseBuilder<ItemModel> {

  static const String _generatorKey = "ItemGenerator";

  late String group;
  late String material;
  late int modelData;
  late int amount;

  final Set<ItemFlag> flags = {};
  final Map<Enchantment, int> enchantmens = {};
  List<String> lore = [];

  ItemBuilder setGroup(String group) {
    Checks.argCondition(group.trim().isEmpty, "The group can't be empty");
    this.group = group;
    return this;
  }

  ItemBuilder addFlag(ItemFlag flag) {
    flags.add(flag);
    return this;
  }

  ItemBuilder addLore(List<String> lines) {
    lore = lines;
    return this;
  }

  ItemBuilder addLine(String line) {
    lore.add(line);
    return this;
  }

  ItemBuilder addEnchantment(Enchantment enchantment, int level) {
    Checks.argCondition(level > enchantment.maxLevel, "The level is to high");
    enchantmens[enchantment] = level;
    return this;
  }


  ItemBuilder setMaterial(String material) {
    Checks.argCondition(material.trim().isEmpty, "The material can't be empty");
    this.material = material;
    return this;
  }

  ItemBuilder setModelData(int modelData) {
    Checks.argCondition(modelData < 0, "The id can't be negative");
    this.modelData = modelData;
    return this;
  }

  ItemBuilder setAmount(int amount) {
    Checks.argCondition(amount < negativeAmount, "The amount can't be negative");
    Checks.argCondition(amount > maximumAmount, "The maximum allowed value is $maximumAmount");
    this.amount = amount;
    return this;
  }

  @override
  ItemModel toDTO() {
    return ItemModel(
      name: name,
      group: group,
      generator: _generatorKey,
      material: material,
      modelData: modelData,
      amount: amount
    );
  }
}