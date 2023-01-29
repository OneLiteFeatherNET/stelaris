import 'package:flutter/material.dart';

import '../../../util/constants.dart';

class SaveButton extends StatelessWidget {

  final Function callback;

  const SaveButton({Key? key, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Positioned(
        bottom: 25,
        right: 25,
        child: FloatingActionButton.extended(
          heroTag: UniqueKey(),
          onPressed: () {
            callback.call();
          },
          label: saveText,
          icon: saveIcon,
        )
    );
  }
}
