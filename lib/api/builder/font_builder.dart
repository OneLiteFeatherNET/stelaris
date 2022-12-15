import 'package:stelaris_ui/api/builder/base_builder.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/util/checks.dart';
import 'package:stelaris_ui/api/util/minecraft/font_type.dart';

class FontBuilder extends BaseBuilder<FontModel> {

  static const String _generatorKey = "FontGenerator";

  late FontType fontType = FontType.legacyUnicode;
  late List<String> chars = [];
  late int ascent = 0;
  late int height = 0;

  FontBuilder setType(FontType type) {
    fontType = type;
    return this;
  }

  FontBuilder setChars(List<String> chars) {
    this.chars = chars;
    return this;
  }

  FontBuilder addChar(String char) {
    Checks.argCondition(char.trim().isEmpty, "No empty value allowed");
    chars.add(char);
    return this;
  }

  FontBuilder setAscent(int ascent) {
    this.ascent = ascent;
    return this;
  }

  FontBuilder setHeight(int height) {
    this.height = height;
    return this;
  }

  @override
  FontBuilder clear() {
    name = "";
    fontType = FontType.bitmap;
    chars.clear();
    ascent = 0;
    height = 0;
    return this;
  }

  @override
  FontModel toDTO() {
    return FontModel(
        name: name,
        generator: _generatorKey,
        type: fontType.name,
        chars: chars,
        ascent: ascent,
        height: height
    );
  }
}