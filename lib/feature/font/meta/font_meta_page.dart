import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/font/meta/char_card.dart';

class FontMetaPage extends StatelessWidget {
  final FontModel model;

  const FontMetaPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Wrap(
            clipBehavior: Clip.hardEdge,
            children: [
              CharCard(model: model),
            ],
          ),
        ),
        SaveButton(
          callback: () {
            ApiService().fontAPI.update(model);
          },
        )
      ],
    );
  }
}
