import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/search/search_delegate.dart';
import 'package:stelaris_ui/util/constants.dart';

const Icon searchIcon = Icon(Icons.search, size: 20, color: Colors.red,);

class SearchWidget extends StatefulWidget {

  final String searchHintText;

  const SearchWidget({Key? key, required this.searchHintText}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SearchWidgetState();
}

class SearchWidgetState extends State<SearchWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      width: 200,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: widget.searchHintText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: searchIcon,
          enabledBorder: searchBorder,
          focusedBorder: searchBorder
        ),
        onChanged: (value) {
          //TODO: Yet that popup
          showSearch(context: context, delegate: ItemSearchDelegate());
        },
      ),
    );
  }
}
