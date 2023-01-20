import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';

/// Strings
const String appName = "Stelaris";
const String itemPage = "Items";
const String entityPage = "Entities";
const String unknownEntry = "Unknown";


/// EdgeInsets
const EdgeInsets eightEdgeInsets = EdgeInsets.all(8.0);

/// Deletedialog
const String firstLine = "Do you really want to delete ";
const String secondLine = " entry";

Text appText = const Text(appName);
Text appTitle = const Text("S T E L A R I S");
Text emptyText = const Text(empty);
Text addText = const Text("Add");
Text saveText = const Text("Save");
Text deleteTitle = const Text("Confirm deletion");

/// Card titles
Text nameText = const Text("Name");
Text descriptionText = const Text("Description");
Text materialText = const Text("Material");
Text modelDataText = const Text("Modeldata");

/// Tooltips
String materialTooltip = "Adjust the material";
String nameToolTip = "Adjust the name";
String modelDataToolTip = "Adjust the modeldata value";
String descriptionToolTip = "Adjust the description";
String displayNameToolTip = "Adjust the Displayname for the item";

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
const SizedBox spaceTenBox = SizedBox(width: 10);
const SizedBox fifteenBox = SizedBox(height: 15);
const SizedBox spaceTwentyFiveHeightBox = SizedBox(height: 25);
