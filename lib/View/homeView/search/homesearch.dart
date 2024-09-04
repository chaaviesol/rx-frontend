import 'package:flutter/material.dart';

import '../../../app_colors.dart';

class Homesearch extends StatefulWidget {
  const Homesearch({super.key});

  @override
  State<Homesearch> createState() => _HomesearchState();
}

class _HomesearchState extends State<Homesearch> {

  final List<Color> pastelColors = [
    Color(0xFFB39DDB), // Light Purple
    Color(0xFF81D4FA), // Light Blue
    Color(0xFFAED581), // Light Green
    Color(0xFFFFF176), // Light Yellow
    Color(0xFFFFAB91), // Light Orange
    Color(0xFFE57373), // Light Red
    Color(0xFFFFF9C4), // Light Cream
    Color(0xFFD1C4E9), // Light Lavender
    Color(0xFFFFCDD2), // Light Pink
  ];
  Color getPastelColor(String name) {
    final int hash = name.codeUnits.fold(0, (int sum, int char) => sum + char);
    return pastelColors[hash % pastelColors.length];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
        ],
      ),
    );
  }
}
