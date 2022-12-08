import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/search/search.dart';

import '../../util/constants.dart';

const EdgeInsets searchPadding = EdgeInsets.only(bottom: 10, top: 10);

class ModelSearchAddControl extends StatefulWidget {
  const ModelSearchAddControl({Key? key}) : super(key: key);

  @override
  State<ModelSearchAddControl> createState() => _ModelSearchAddControl();
}

class _ModelSearchAddControl extends State<ModelSearchAddControl> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        spaceFiveBox,
        Form(
          key: _formKey,
          child: Padding(
            padding: searchPadding,
            child: SearchWidget(searchHintText: 'Search..',),
          ),
        ),
        spaceTenAndTenBox,
        SizedBox(
          height: 50,
          width: 50,
          child: FloatingActionButton(
            autofocus: false,
            tooltip: "Add a new model",
            onPressed: () {  },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: addModelIcon,
          ),
        ),
        SizedBox(
          width: 5,
        )
      ],
    );
  }
}
