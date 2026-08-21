import 'package:stelaris_models/stelaris_models.dart';

extension FontModelMapping on FontModel {
  FontModelDto toDto() {
    return FontModelDto(
      id: id,
      uiName: uiName,
      variableName: variableName,
      provider: provider,
      mapper: mapper,
      texturePath: texturePath,
      comment: comment,
      ascent: ascent,
      height: height,
    );
  }
}

extension FontDtoMapping on FontModelDto {
  FontModel toModel() {
    return FontModel(
      id: id,
      uiName: uiName,
      variableName: variableName,
      provider: provider,
      mapper: mapper,
      texturePath: texturePath,
      comment: comment,
      ascent: ascent,
      height: height,
    );
  }
}
