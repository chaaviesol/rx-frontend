import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Events_page extends StatefulWidget {
  const Events_page({Key? key}) : super(key: key);

  @override
  State<Events_page> createState() => _Events_pageState();
}

class _Events_pageState extends State<Events_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10,),
            Center(child: Text('Content for Eventsssssssssss')),
          ],
        ),
      ),
    );
  }
}
