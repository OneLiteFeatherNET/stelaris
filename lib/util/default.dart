import 'package:stelaris_ui/api/model/block_model.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/util/minecraft/font_type.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';

var defaultItem = const ItemModel(
    name: "Test1234",
    //group: "Test",
    material: "minecraft:air",
    customModelId: 1,
    amount: 1,
    flags: {"YOLO", "YOLO2", "YOLO3"},
    enchantments: {'yolo': 1, "yolo2": 2, "yolor3": 33},
    lore: ["Test", "This is another line"]);

var firstNotificationModel = NotificationModel(
    material: "Holz",
    name: "Test",
    title: "Test Title",
    description: "Lol",
    frameType: FrameType.challenge.name
);
var secondNotificationModel = NotificationModel(
    material: "Stein",
    name: "Second",
    title: "Test Title",
    description: "Hui",
    frameType: FrameType.goal.name
);

var blocKModel = const BlockModel(
    name: "Test",
    generator: "BlockGenerator",
    customModelId: 1,
);

var fontModel = FontModel(
    name: "Font",
    type: FontType.bitmap.displayName,
    ascent: 10,
    height: 100
);