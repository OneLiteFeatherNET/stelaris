import 'package:stelaris/api/model/font/font_model_dto.dart';
import 'package:stelaris/api/model/font_model.dart';

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
