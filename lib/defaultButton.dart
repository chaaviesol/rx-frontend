import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Defaultbutton extends StatefulWidget {
  Color bgColor;
  TextStyle textstyle;
  String text;
  Border? bordervalues;
  bool? isICon;
  IconData? btnIcon;
  Color? btnIconColor;
  Defaultbutton({
    required this.bgColor,
    required this.textstyle,
    required this.text,
    this.bordervalues,
    this.isICon,
    this.btnIcon,
    this.btnIconColor,
    super.key});

  @override
  State<Defaultbutton> createState() => _DefaultbuttonState();
}

class _DefaultbuttonState extends State<Defaultbutton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(6),
          border:widget.bordervalues,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children:<Widget> [
                widget.isICon == true ? Icon(widget.btnIcon,color:widget.btnIconColor ,) : const Text(''),
                Text(widget.text,style:widget.textstyle,),
              ],
            )
          ],
        ),
      ),
    );
  }
}
