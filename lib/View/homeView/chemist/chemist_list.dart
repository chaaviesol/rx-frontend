import 'package:flutter/material.dart';


import '../../../app_colors.dart';

class ChimistList extends StatefulWidget {
  const ChimistList({super.key});

  @override
  State<ChimistList> createState() => _ChimistListState();
}

class _ChimistListState extends State<ChimistList> {
  // Define a list to hold the state of each checkbox
  List<bool> isCheckedList = [];

  List<String> chemistList = [
    'Chemist 1',
    'Chemist 2',
    'Chemist 3',
    // Add more products as needed
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the state of each checkbox to false
    isCheckedList = List<bool>.filled(chemistList.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color:AppColors.primaryColor, // Replace with your desired color
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(onTap: (){
              Navigator.pop(context);
            },
                child: const Icon(Icons.arrow_back, color: Colors.white)), // Adjust icon color
          ),
        ),
        centerTitle: true,
        title: const Text(
          'List of chemist',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: chemistList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Checkbox(
                value: isCheckedList[index],
                onChanged: (bool? value) {
                  setState(() {
                    isCheckedList[index] = value ?? false;
                  });
                },
              ),
              title: Text(chemistList[index]),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Update',
                    child: Text('Update'),
                  ),
                  // Add more options as needed
                ],
                onSelected: (String value) {
                  // Implement your option selection logic here
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
