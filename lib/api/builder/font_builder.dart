import 'package:stelaris_ui/api/builder/base_builder.dart';
import 'package:stelaris_ui/api/model/font_model.dart';

class FontBuilder extends BaseBuilder<FontModel> {

  static const String _generatorKey = "FontGenerator";

  @override
  FontModel toDTO() {
    return FontModel(name: name, generator: _generatorKey);
  }
}