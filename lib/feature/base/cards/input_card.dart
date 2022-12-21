import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class InputCard<E, String> extends StatefulWidget {

  final Text title;
  final ValueUpdate<E> valueUpdate;
  final DefaultValue<E, String> defaultValue;
  final String currentValue;

  const InputCard({Key? key, required this.title, required this.valueUpdate, required this.defaultValue, required this.currentValue}) : super(key: key);

  @override
  State<InputCard> createState() => _InputCardState();
}

class _InputCardState extends State<InputCard> with BaseLayout {

  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: constructContainer(
        [
          widget.title,
          spaceBox,
          SizedBox(
            width: 300,
            child: TextFormField(
              autocorrect: false,
              controller: _editController,
            ),
          )
        ]
      ),
    );
  }
}
