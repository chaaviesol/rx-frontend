import 'dart:async';
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:rx_route_new/constants/styles.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import '../../../../../Util/Utils.dart';
import '../../../../../app_colors.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  List doctors = [];
  Map<String, List<int>> selectedDoctorsMap = {}; // Store selected doctors by date
  bool isCalendarVisible = true;
  bool _isLoading = false; // Loader state variable

  // Function to fetch doctors for a selected day
  Future<void> fetchDoctors(String day) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');

    setState(() {
      _isLoading = true; // Start loader
    });

    final response = await http.post(
      Uri.parse(AppUrl.listDoctors), // Replace with your API URL
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "areas": [""],
        "userId": uniqueID, // Replace with dynamic userId if needed
        "day": day,
      }),
    );

    setState(() {
      _isLoading = false; // Stop loader
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        doctors = data['data'];
        // Clear selections for the newly fetched doctors
        selectedDoctorsMap.putIfAbsent(
          DateFormat('dd-MM-yyyy').format(_selectedDay),
              () => [], // Initialize list if it doesn't exist
        );
      });
    } else {
      // Handle API error
      print('Failed to fetch doctors');
    }
  }

  // Function to toggle selection of doctors
  void toggleDoctorSelection(int index) {
    String selectedDate = DateFormat('dd-MM-yyyy').format(_selectedDay);

    setState(() {
      if (selectedDoctorsMap[selectedDate]!.contains(index)) {
        selectedDoctorsMap[selectedDate]!.remove(index); // Deselect if already selected
      } else {
        selectedDoctorsMap[selectedDate]!.add(index); // Select the doctor
      }
    });
  }

  // Function to build the request body
  Map<String, dynamic> buildRequestBody(int userId) {
    List<Map<String, dynamic>> plans = [];
    selectedDoctorsMap.forEach((date, doctorIndices) {
      if (doctorIndices.isNotEmpty) {
        plans.add({
          "date": date,
          "doctors": doctorIndices,
        });
      }
    });

    return {
      "user_id": userId,
      "plan": plans,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Day'),
        actions: [
          IconButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            icon: Text(
              'Generate',
              style: TextStyle(color: AppColors.whiteColor),
            ),
            onPressed: () async {
              SharedPreferences preferences = await SharedPreferences.getInstance();
              int? userId = int.tryParse(preferences.getString('uniqueID') ?? '');

              if (userId != null) {
                Map<String, dynamic> requestBody = buildRequestBody(userId);

                // You can send this requestBody to your API
                print(jsonEncode(requestBody));

                // Example API call (implement your own logic)
                final response = await http.post(
                  Uri.parse(AppUrl.confirmTP), // Your API URL
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(requestBody),
                );

                if (response.statusCode == 200) {
                  // Handle successful response
                  print('Successfully sent data!');
                } else {
                  // Handle error
                  print('Failed to send data: ${response.statusCode}');
                }
              }
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          isCalendarVisible
              ? TableCalendar(
            firstDay: DateTime.now(), // Disable past dates by setting firstDay to today
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isPastDate(selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  // Initialize selections for the new day
                  String selectedDate = DateFormat('dd-MM-yyyy').format(selectedDay);
                  selectedDoctorsMap.putIfAbsent(selectedDate, () => []); // Ensure the date exists in map
                });
                fetchDoctors(getDayName(selectedDay));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot select a past date!')),
                );
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            headerStyle: HeaderStyle(
              titleTextFormatter: (date, locale) {
                // Center the month name in letters
                return DateFormat('MMMM yyyy', locale).format(date);
              },
              titleCentered: true, // Center the month title
              formatButtonVisible: false, // Hide the format button
            ),
          )
              : Container(),
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              setState(() {
                isCalendarVisible = !isCalendarVisible;
              });
            },
            child: Container(
              decoration: BoxDecoration(color: AppColors.primaryColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDay),
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        isCalendarVisible
                            ? Icon(Icons.keyboard_arrow_up, color: AppColors.whiteColor)
                            : Icon(Icons.keyboard_arrow_down, color: AppColors.whiteColor)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(), // Show loader
            )
                : doctors.isEmpty
                ? Center(
              child: Text(
                'No doctors available for this day.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                var doctor = doctors[index]['doctor'];
                String selectedDate = DateFormat('dd-MM-yyyy').format(_selectedDay);
                bool isSelected = selectedDoctorsMap[selectedDate]!.contains(index); // Check if this doctor is selected

                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    onTap: () {
                      toggleDoctorSelection(index); // Toggle selection
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          width: 1,
                          color: doctor['visitType'] == 'core'
                              ? AppColors.tilecolor2
                              : doctor['visitType'] == 'supercore'
                              ? AppColors.tilecolor1
                              : AppColors.tilecolor3,
                        ),
                        // Remove the background color to not fill it
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: doctor['visitType'] == 'core'
                              ? AppColors.tilecolor2
                              : doctor['visitType'] == 'supercore'
                              ? AppColors.tilecolor1
                              : AppColors.tilecolor3,
                          child: Text('${doctor['firstName'][0]}'), // Show first letter of the first name
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('${doctor['firstName']} ${doctor['lastName']}'),
                            ),
                            if (isSelected) // Show checkmark if selected
                              Icon(
                                Icons.check,
                                color: Colors.green, // Color of the checkmark
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${doctor['schedule'][0]['schedule']['start_time']} - ${doctor['schedule'][0]['schedule']['end_time']}',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to get the day name
  String getDayName(DateTime date) {
    switch (date.weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "Unknown";
    }
  }

  // Function to check if the selected day is in the past
  bool isPastDate(DateTime date) {
    final now = DateTime.now();
    return date.year < now.year ||
        (date.year == now.year && date.month < now.month) ||
        (date.year == now.year && date.month == now.month && date.day < now.day);
  }
}
