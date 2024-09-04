import 'package:flutter/cupertino.dart';


class Customchip extends StatelessWidget {
  String label;
  TextStyle txtstyle;
  Color bgcolor;
  Customchip({required this.label,required this.txtstyle,required this.bgcolor,super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:bgcolor,
        borderRadius: BorderRadius.circular(53)
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(label,style: txtstyle,),
      ),
    );
  }
}
