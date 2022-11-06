import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

class BaseLayout<E extends DataModel> extends StatefulWidget {
  final List<E> items;
  final EditItem<E> edit;

  const BaseLayout({Key? key, required this.items, required this.edit}) : super(key: key);

  @override
  State<BaseLayout> createState() => _BaseLayoutState<E>(items, edit);
}

class _BaseLayoutState<E> extends State<BaseLayout> {

  final List<E> items;
  final EditItem<E> edit;

  _BaseLayoutState(this.items, this.edit);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

typedef EditItem<E> = void Function(E item, int index);