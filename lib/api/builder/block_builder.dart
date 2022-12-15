import 'package:stelaris_ui/api/builder/base_builder.dart';
import 'package:stelaris_ui/api/model/block_model.dart';

import '../util/checks.dart';
import 'item_builder.dart';

class BlockBuilder extends BaseBuilder<BlockModel> {

  static const String _generatorKey = "BlockGenerator";

  late int modelData;
  late int amount = 1;

  BlockBuilder setModelData(int modelData) {
    Checks.argCondition(modelData < 0, "The id can't be negative");
    this.modelData = modelData;
    return this;
  }

  BlockBuilder setAmount(int amount) {
    Checks.argCondition(
        amount < negativeAmount, "The amount can't be negative");
    Checks.argCondition(
        amount > maximumAmount, "The maximum allowed value is $maximumAmount");
    this.amount = amount;
    return this;
  }

  @override
  BlockBuilder clear() {
    name = "";
    modelData = 0;
    amount = 1;
    return this;
  }

  @override
  BlockModel toDTO() {
    return BlockModel(
        name: name,
        generator: _generatorKey,
        modelData: modelData,
        amount: amount
    );
  }
}
