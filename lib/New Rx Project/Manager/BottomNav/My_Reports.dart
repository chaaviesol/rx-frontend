import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Myreports extends StatefulWidget {
  const Myreports({Key? key}) : super(key: key);

  @override
  State<Myreports> createState() => _MyreportsState();
}

class _MyreportsState extends State<Myreports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(' My reports'), automaticallyImplyLeading: false, ),
    );
  }
}
