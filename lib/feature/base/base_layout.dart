import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/util/constants.dart';

EdgeInsets padding = const EdgeInsets.only(top: 10, left: 10);

const SizedBox spaceBox = SizedBox(height: 10);
const EdgeInsets all = EdgeInsets.all(20);

mixin BaseLayout {

  Widget createInputContainer(String title, String? value) {
    return Padding(
      padding: padding,
      child: constructContainer(
        [
          Text(title, textAlign: TextAlign.left),
          spaceBox,
          SizedBox(
            width: 300,
            height: 100,
            child: TextField(
              controller: TextEditingController(
                  text: value ?? empty
              ),
              maxLength: 30,
            ),
          )
        ]
      ),
    );
  }

  Widget createTypedInputContainer(String title, String? value, TextInputType type, List<TextInputFormatter>? formatter) {
    return Padding(
      padding: padding,
      child: constructContainer(
          [
            Text(title, textAlign: TextAlign.left),
            spaceBox,
            SizedBox(
              width: 300,
              height: 100,
              child: TextField(
                controller: TextEditingController(
                  text: value ?? empty,
                ),
                keyboardType: type,
                autocorrect: false,
                inputFormatters: formatter,
                maxLength: 30,
              ),
            )
          ]
      ),
    );
  }

  Widget createFormattedInputContainer(String title, String? value, List<TextInputFormatter> formatter) {
    return constructContainer(
        [
          Text(title, textAlign: TextAlign.left),
          spaceBox,
          SizedBox(
            width: 300,
            height: 100,
            child: TextField(
              controller: TextEditingController(
                  text: value ?? empty,
              ),
              autocorrect: false,
              inputFormatters: formatter,
              maxLength: 30,
            ),
          )
        ]
    );
  }

  Widget createNumberContainer(String title, String? value) {
    return constructContainer(
      [
        Text(title, textAlign: TextAlign.left),
        spaceBox,
        _constructSizedBox(
          TextField(
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: value ?? zero),
            maxLength: 2,
          )
        )
      ]
    );
  }

  Widget _constructSizedBox(Widget child) {
    return SizedBox(
      width: 400,
      height: 100,
      child: child,
    );
  }

  Widget constructContainer(List<Widget> children) {
    return Card(
        margin: eightEdgeInsets,
        child: Column(
          children: [
            Container(
              padding: all,
              child: Column(children: children),
            ),
          ]
        )
    );
  }
}
