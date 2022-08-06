import 'dart:ui';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatefulWidget {

  final String title;
  final String description;
  final String text;

  const ConfirmDialog({Key? key, required this.title, required this.description, required this.text}) : super(key: key);

  @override
  _ConfirmDialogState createState() => _ConfirmDialogState();

}

class _ConfirmDialogState extends State<ConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }
  contentBox(context) {
    return Stack(
      children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 12, top: 12 + 1, right: 10, bottom: 10),
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.black, offset: Offset(0, 10),
                  blurRadius: 10
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(widget.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                SizedBox(height: 15,),
                Text(widget.description, style: TextStyle(fontSize: 14), textAlign: TextAlign.center,),
                SizedBox(height: 22,),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    onPressed: () => {},
                    child: Text("Hallo", style: const TextStyle(fontSize: 18),)
                  ),
                ),
              ],
            )
          ),
      ],
    );
  }
}