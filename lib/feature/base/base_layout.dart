import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/util/constants.dart';

EdgeInsets padding = const EdgeInsets.only(top: 10, left: 10);

const Radius radius = Radius.circular(10);
const BorderRadius borderRadius = BorderRadius.only(
    topLeft: radius,
    topRight: radius,
    bottomLeft: radius,
    bottomRight: radius
);

const SizedBox spaceBox = SizedBox(height: 10);
const EdgeInsets top = EdgeInsets.only(top: 10);
const EdgeInsets all = EdgeInsets.all(20);

mixin BaseLayout {

  Widget createDropDownContainer<E>(E type, String title, E value, E defaultValue, List<DropdownMenuItem<E>> items) {
    return Padding(
      padding: padding,
      child: _constructContainer(
        [
          Text(title, textAlign: TextAlign.left),
          spaceBox,
          SizedBox(
            width: 300,
            child: DropdownButtonFormField<E>(
              value: value ?? defaultValue,
              items: items,
              onChanged: (E? value) {}),
            )
        ]
      ),
    );
  }

  Widget createInputContainer(String title, String? value) {
    return Padding(
      padding: padding,
      child: _constructContainer(
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

  Widget createExpansionContainer(String title, List<Widget> value) {
    return Padding(
      padding: padding,
      child: _constructContainer(
          [
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 300,
                minHeight: 100,
                maxWidth: 300
              ),
              child: ExpansionTile(
                controlAffinity: ListTileControlAffinity.leading, title: Text(title),
                children: value,
              ),
            )
          ]
      ),
    );
  }

  Widget createTypedInputContainer(String title, String? value, TextInputType type, List<TextInputFormatter>? formatter) {
    return Padding(
      padding: padding,
      child: _constructContainer(
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
    return _constructContainer(
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
    return _constructContainer(
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

  Widget _constructContainer(List<Widget> children) {
    return Card(
        // decoration: boxDecoration,
        child: Column(
          children: [
            Container(
              padding: all,
              // decoration: boxDecoration,
              child: Column(children: children),
            ),
          ]
        )
    );
  }
}
