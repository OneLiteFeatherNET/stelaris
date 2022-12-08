import '../api/util/minecraft/frame_type.dart';
import 'package:flutter/material.dart';

//Strings
const String appName = "Stelaris";
const String itemPage = "Items";
const String entityPage = "Entities";

Text appText = const Text(appName);
Text appTitle = const Text("S T E L A R I S");
Text emptyText = const Text(empty);

//Minecraft related values
const String zero = "0";
const String empty = "";
const int maxItemSize = 64;
const String defaultMaterial = "minecraft:dirt";

// Dialog elements
RoundedRectangleBorder stepperBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));

//Template Stepper
const String templateStepperTitle = "Create a server template";

// Font dialog
const String fontStepperTitle = "Create a new font entry";

const FrameType defaultFrameType = FrameType.task;

// Text
const Text notificationStepperTitle = Text("Create a new notification", textAlign: TextAlign.center);

// Button
Icon addModelIcon = const Icon(Icons.add);

// Boxes
const SizedBox spaceFiveBox = SizedBox(width: 5);
const SizedBox spaceTenAndTenBox = SizedBox(width: 10, height: 10);
const SizedBox spaceTenBox = SizedBox(width: 10,);

// Borders
OutlineInputBorder searchBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: Colors.red, width: 2)
);
