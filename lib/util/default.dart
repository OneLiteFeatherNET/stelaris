import 'package:stelaris_ui/api/model/item_model.dart';

var defaultItem = const ItemModel(
    name: "Test1234",
    generator: "ItemGenerator",
    group: "Test",
    material: "minecraft:air",
    modelData: 1,
    amount: 1,
    flags: {"YOLO", "YOLO2", "YOLO3"},
    enchantments: {'yolo': 1, "yolo2": 2, "yolor3": 33},
    lore: ["Test", "This is another line"]);