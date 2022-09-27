import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/search/search_delegate.dart';

class SearchWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchWidgetState();
}

class SearchWidgetState extends State<SearchWidget> {

  OutlineInputBorder border = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Colors.red, width: 2)
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      width: 200,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "Search...",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.red,),
          enabledBorder: border,
          focusedBorder: border
        ),
        onChanged: (value) {
          showSearch(context: context, delegate: ItemSearchDelegate());
        },
      ),
    );
  }
}
