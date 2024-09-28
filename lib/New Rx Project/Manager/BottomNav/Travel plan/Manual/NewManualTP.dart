import 'package:flutter/material.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Newmanualtp extends StatefulWidget {
  const Newmanualtp({super.key});

  @override
  State<Newmanualtp> createState() => _NewmanualtpState();
}

class _NewmanualtpState extends State<Newmanualtp> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _doctors = [];
  bool _isCalendarVisible = true;


  Future<List<dynamic>> fetchDoctors(String userUniqueId) async {
    final response = await http.post(
      Uri.parse(AppUrl.getAddedDoctors), // Replace with your API endpoint
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'userUniqueId': userUniqueId}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        print('aaaaaaaa:${responseData['data']}');
        return responseData['data'];
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception('Failed to load doctors');
    }
  }


  // Function to fetch doctors from the API
  Future<void> _fetchDoctors() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = await preferences.getString('uniqueID');
    try {
      final doctors = await fetchDoctors('$uniqueID'); // Use the required userUniqueId
      setState(() {
        _doctors = doctors; // Update the doctors list
      });
    } catch (e) {
      print(e); // Handle error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Page'),
      ),
      body: Column(
        children: [
          Visibility(
            visible: _isCalendarVisible,
            child:TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _fetchDoctors(); // Fetch doctors when a date is selected
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (day.weekday == DateTime.sunday) {
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.red), // Red text for Sundays
                      ),
                    );
                  }
                  return null; // Default for non-Sundays
                },
                todayBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
              // Enable and customize the header with month and year
              headerVisible: true, // Make header visible
              headerStyle: HeaderStyle(
                formatButtonVisible: false, // Hide the format button
                titleCentered: true, // Center the month name
                titleTextStyle: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ), // Customize month name text style
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
              ),
              calendarFormat: CalendarFormat.month,
            )
            ,
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              setState(() {
                _isCalendarVisible = !_isCalendarVisible; // Toggle visibility
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: Text(
                _selectedDay != null
                    ? 'Selected Date: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                    : 'Pick a Date from Calendar',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          // Display available doctors for the selected day
          if (_selectedDay != null) ...[
            const SizedBox(height: 20),
            Text(
              'Available Doctors:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              children: _doctors.map<Widget>((doctor) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ChoiceChip(
                    label: Text('${doctor['firstName']} ${doctor['lastName']}'),
                    selected: false,
                    onSelected: (isSelected) {
                      // Handle selection of the doctor here
                      // You can filter based on headquarters or other criteria
                      // Example: filterDoctorsByHeadquarters(doctor['headquaters']);
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
