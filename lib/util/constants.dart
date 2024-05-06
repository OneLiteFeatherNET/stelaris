import 'package:flutter/material.dart';

/// Strings
const String appName = "Stelaris";
const String itemPage = "Items";
const String entityPage = "Entities";
const String unknownEntry = "Unknown";

/// EdgeInsets
const EdgeInsets padding = EdgeInsets.only(top: 10, left: 10);

const loader = SizedBox(height: 25, width: 25, child: CircularProgressIndicator());
const divider = Divider();

Text appText = const Text(appName);
Text appTitle = const Text("S T E L A R I S");
Text emptyText = const Text(emptyString);

/// Regs
RegExp numberPattern = RegExp("[1-9]\\d*");
RegExp fontNumberPattern = RegExp("^(0|[1-9][0-9]*)");
RegExp doubleNumberPattern = RegExp("^(0|[1-9][0-9]*)(\\.[0-9]+)?");
RegExp letterPattern = RegExp("[a-zA-Z][a-z A-Z]*");
RegExp decimalPattern = RegExp(r'^\d*\.?\d*');
RegExp stringPattern = RegExp("[a-zA-Z]\\w*");
RegExp stringWithSpacePattern = RegExp("[a-zA-Z][a-zA-Z ]*");
RegExp dotPattern = RegExp("\\.");
RegExp minecraftPattern = RegExp("minecraft:");
RegExp namePattern = RegExp("^[a-zA-z]\\w*");
RegExp gitCommitPattern = RegExp("[0-9a-fA-F]{10}");
RegExp versionPattern = RegExp(r'^[0-9.]*$');

/// Formatter
const TextInputType numberInput = TextInputType.numberWithOptions(signed: true);
const TextInputType decimalInput = TextInputType.numberWithOptions(decimal: true, signed: true);

/// Lore page
const int maxLoreLines = 64;

/// Input field
const int twentyLength = 20;
const double fiftyLength = 50;

/// Minecraft related values
const String zeroString = "0";
const String emptyString = "";
const int maxItemSize = 64;
const String defaultMaterial = "minecraft:dirt";

// Text
// Button
Icon addModelIcon = const Icon(Icons.add);
Icon confirmIcon = const Icon(Icons.check);
Icon deleteIcon = const Icon(Icons.delete_forever, color: Colors.red);
Icon saveIcon = const Icon(Icons.save);
Icon editIcon = const Icon(Icons.edit);

/// Styles
TextStyle whiteStyle = const TextStyle(color: Colors.white);
TextStyle redStyle = const TextStyle(color: Colors.red);

// Boxes
const SizedBox heightTen = SizedBox(height: 10);
const SizedBox horizontalSpacing10 = SizedBox(width: 10);
const SizedBox verticalSpacing10 = SizedBox(height: 15);
const SizedBox verticalSpacing25 = SizedBox(height: 25);

const EdgeInsets dialogPadding = EdgeInsets.all(20);
const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: 8);

const double sizeFifty = 50.0;

const borderRadius12 = BorderRadius.all(Radius.circular(12.0));

const String conceptURL = 'https://docs.onelitefeather.network/doc/stelaris-S1nldMzySr#h-43-build-page';
const String gitUrl = 'https://gitlab.themeinerlp.dev/dungeon/frontend/stelaris-ui/-/issues/new';
