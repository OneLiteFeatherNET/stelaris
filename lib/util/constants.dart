import '../api/util/minecraft/frame_type.dart';
import 'package:flutter/material.dart';

//Strings
const String appName = "Stelaris";
const String itemPage = "Items";
const String entityPage = "Entities";

const String unknownEntry = "Unknown";

//// Deletedialog
const String firstLine = "Do you really want to delete ";
const String secondLine = " entry";

Text appText = const Text(appName);
Text appTitle = const Text("S T E L A R I S");
Text emptyText = const Text(empty);
Text addText = const Text("Add");
Text saveText = const Text("Save");
Text deleteTitle = const Text("Confirm deletion");

/// Regs
RegExp numberPattern = RegExp("[1-9]\\d*");
RegExp stringPattern = RegExp("[a-zA-Z]\\w*");

/// Formatter
const TextInputType numberInput = TextInputType.numberWithOptions(signed: true);

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
const FrameType defaultFrameType = FrameType.task;

// Text
// Button
Icon addModelIcon = const Icon(Icons.add);
Icon deleteIcon = const Icon(Icons.delete_forever, color: Colors.red);
Icon saveIcon = const Icon(Icons.save);

// Boxes
const SizedBox spaceFiveBox = SizedBox(width: 5);
const SizedBox spaceTenAndTenBox = SizedBox(width: 10, height: 10);
const SizedBox spaceTenBox = SizedBox(width: 10,);
const SizedBox spaceTwentyFiveHeightBox = SizedBox(height: 25);
