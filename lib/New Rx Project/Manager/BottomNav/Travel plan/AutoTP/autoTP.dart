import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rx_route_new/Util/Utils.dart';
import 'package:rx_route_new/app_colors.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Autotp extends StatefulWidget {
  var data; // The data containing doctors by date
  Autotp({required this.data, super.key});

  @override
  State<Autotp> createState() => _AutotpState();
}

class _AutotpState extends State<Autotp> {
  DateTime _selectedDate = DateTime.now(); // Store the selected date
  List<dynamic> _selectedDoctors = []; // List of doctors for the selected day
  Map<DateTime, List<dynamic>> _events = {};

  Future<void> submitAutoTp() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? userID = int.parse(preferences.getString('userID').toString());
    String url = AppUrl.submitAutoTP;

    var data = {
      "user_id": userID,
      "data": "${widget.data}"
    };

    try {
      print('auto tp submit try...');
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Add any other headers as needed
        },
        body: jsonEncode(data),
      );
      print('st code is:${response.statusCode}');
      print('passing body:${data}');
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
      } else {
        // Error in API call
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        print('Failed to post data: ${response.statusCode}');
        throw Exception('Failed to post data');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    print('widget data is:${widget.data}');
    _populateEvents(); // Populate events
    _updateSelectedDoctors(_selectedDate); // Initialize with current date's doctors
  }

  // Convert the data from the backend to events for the calendar
  void _populateEvents() {
    print('populate called..');
    final DateFormat formatter = DateFormat('dd-MM-yyyy'); // Define the date format
    widget.data["data"].forEach((dateString, doctorsList) {
      try {
        DateTime date = formatter.parse(dateString); // Parse the date using the specified format
        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date] = doctorsList;
      } catch (e) {
        print('Error parsing date: $e');
      }
    });
  }

  // Update the list of doctors for the selected date
  void _updateSelectedDoctors(DateTime date) {
    setState(() {
      _selectedDoctors = _events[date] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor),
            onPressed: () {
              submitAutoTp();
            },
            child: Text('Continue', style: TextStyle(color: AppColors.whiteColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor),
            onPressed: () {},
            child: Text('Cancel', style: TextStyle(color: AppColors.whiteColor)),
          )
        ],
      ),
      appBar: AppBar(
        title: const Text('Auto Generated TP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: () {
              // Add functionality to import events
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Display the selected date
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selected Date: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // Display list of doctors for the selected date
          Expanded(
            child: _selectedDoctors.isNotEmpty
                ? ListView.builder(
              itemCount: _selectedDoctors.length,
              itemBuilder: (context, index) {
                var doctor = _selectedDoctors[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(doctor['doctor'][0]), // First letter of doctor name
                    ),
                    title: Text(doctor['doctor']),
                    subtitle: Text(doctor['address']['address']),
                    trailing: Text(doctor['category']),
                  ),
                );
              },
            )
                : const Center(child: Text('No doctors for the selected date')),
          ),
        ],
      ),
    );
  }
}
