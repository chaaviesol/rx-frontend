import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../app_colors.dart';
import 'package:http/http.dart' as http;
class ManualTPPage extends StatefulWidget {
  @override
  _ManualTPPageState createState() => _ManualTPPageState();
}

class _ManualTPPageState extends State<ManualTPPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final Map<DateTime, List> _holidays = {
    DateTime(2024, 1, 1): ['New Year\'s Day'],
    DateTime(2024, 12, 25): ['Christmas Day'],
  };

  String? selectedArea; // To hold the currently selected area
  Map<String, List<Doctor>> doctorsByArea = {}; // To hold doctors mapped by area

  Set<String> selectedItems = {}; // Holds selected areas
  bool isCalendarVisible = true;

  // Future<List<Doctor>> getDoctorsForDay(String selectedDay,var area)async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   String? uniqueId = preferences.getString('uniqueID');
  //   print('area is that :${area}');
  //   final url = Uri.parse(AppUrl.listDoctors);
  //   var data = {
  //     "areas" : area,
  //     "userId":uniqueId,
  //     "day":selectedDay.toLowerCase()
  //   };
  //   final  response = await http.post(
  //       url,
  //       headers: {
  //         'content-Type':'application/json',
  //       },
  //       body: jsonEncode(data)
  //   );
  //   print('sending:${data}');
  //   print('st code error from herer:${response.statusCode}');
  //   print('response:${jsonDecode(response.body)}');
  //   if(response.statusCode == 200){
  //     final Map<String,dynamic> jsonResponse = jsonDecode(response.body);
  //     if(jsonResponse['success']){
  //       List<Doctor> doctors = (jsonResponse['data'] as List).map((doc) => Doctor.fromJson(doc['doctor'])).toList();
  //       print('doctors in $selectedDay day:$doctors');
  //       return doctors;
  //     }else {
  //       throw Exception('Failed to load doctors');
  //     }
  //   }else{
  //     throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual TP'),
      ),
      body: Column(
        children: [
          // Toggle calendar visibility
          InkWell(
            onTap: () {
              setState(() {
                isCalendarVisible = !isCalendarVisible;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
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
                        Icon(
                          isCalendarVisible
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.whiteColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.0),
          if (isCalendarVisible) ...[
            // Calendar here
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(DateTime.now().year, DateTime.now().month, 1),
              lastDay: DateTime.utc(2050, 3, 14),
              eventLoader: (day) {
                return _holidays[day] ?? [];
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  selectedArea = null; // Reset selected area when day is changed
                  doctorsByArea.clear(); // Clear doctors when date is changed
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
          SizedBox(height: 10.0),
          // Chips for selected areas
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: selectedItems.map((item) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedArea = item; // Set the selected area
                      // Fetch doctors for this area
                      doctorsByArea = fetchDoctorsForArea(item);
                    });
                  },
                  child: Chip(
                    label: Text(item),
                    onDeleted: () {
                      setState(() {
                        selectedItems.remove(item);
                        if (selectedArea == item) {
                          selectedArea = null;
                          doctorsByArea.clear(); // Clear the doctors when the area is removed
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                if (selectedArea != null) ...[
                  // Show doctors for the selected area
                  Expanded(
                    child: ListView.builder(
                      itemCount: doctorsByArea[selectedArea]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final doctor = doctorsByArea[selectedArea]![index];
                        return ListTile(
                          title: Text('${doctor.firstName} ${doctor.lastName}'),
                          onTap: () {
                            // Handle doctor tap
                          },
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Center(
                    child: Text('Select an area to see doctors.'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder for the fetchDoctorsForArea function
  Map<String, List<Doctor>> fetchDoctorsForArea(String area) {
    // Fetch and return doctors mapped by area
    // This is just a placeholder and needs to be implemented based on your data model
    return {
      area: [
        Doctor(id: '1', firstName: 'John', lastName: 'Doe'),
        Doctor(id: '2', firstName: 'Jane', lastName: 'Smith'),
      ],
    };
  }
}

// Example Doctor class, adjust as needed
class Doctor {
  final String id;
  final String firstName;
  final String lastName;

  Doctor({required this.id, required this.firstName, required this.lastName});
}
