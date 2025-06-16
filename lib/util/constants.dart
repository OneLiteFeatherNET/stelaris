import 'package:flutter/material.dart';

/// Strings
const String appName = 'Stelaris';
const String unknownEntry = 'Unknown';

/// EdgeInsets
const EdgeInsets generalPadding = EdgeInsets.only(top: 10, left: 10);

const loader = SizedBox(height: 25, width: 25, child: CircularProgressIndicator());
const divider = Divider();

Text appTitle = const Text('S T E L A R I S');

/// Regs
RegExp numberPattern = RegExp('[1-9]\\d*');
RegExp fontNumberPattern = RegExp('^(0|[1-9][0-9]*)');
RegExp stringPattern = RegExp('[a-zA-Z]\\w*');
RegExp stringWithSpacePattern = RegExp('[a-zA-Z][a-zA-Z ]*');
RegExp dotPattern = RegExp('\\.');
RegExp minecraftPattern = RegExp('minecraft:');
RegExp gitCommitPattern = RegExp('[0-9a-fA-F]{10}');
RegExp versionPattern = RegExp(r'^[0-9.]*$');

/// Formatter
const TextInputType numberInput = TextInputType.numberWithOptions(signed: true);
const TextInputType decimalInput = TextInputType.numberWithOptions(decimal: true, signed: true);

/// Lore page
const int maxLoreLines = 64;

/// Input field
const double fiftyLength = 50;

/// Minecraft related values
const String zeroString = '0';
const String emptyString = '';
const int maxItemSize = 64;
const String defaultMaterial = 'minecraft:dirt';

// Text
// Button
Icon addModelIcon = const Icon(Icons.add);
Icon confirmIcon = const Icon(Icons.check);
Icon deleteIcon = const Icon(Icons.delete_forever, color: Colors.red);
Icon saveIcon = const Icon(Icons.save);
Icon editIcon = const Icon(Icons.edit);

/// Styles
TextStyle redStyle = const TextStyle(color: Colors.red);

// Boxes
const SizedBox heightTen = SizedBox(height: 10);
const SizedBox horizontalSpacing10 = SizedBox(width: 10);
const SizedBox verticalSpacing10 = SizedBox(height: 15);
const SizedBox verticalSpacing25 = SizedBox(height: 25);

const EdgeInsets dialogPadding = EdgeInsets.all(20);

const double sizeFifty = 50;

const borderRadius12 = BorderRadius.all(Radius.circular(12));

const String conceptURL = 'https://docs.onelitefeather.network/doc/stelaris-S1nldMzySr#h-43-build-page';
const String gitUrl = 'https://gitlab.onelitefeather.dev/dungeon/frontend/stelaris-ui/-/issues/new';
