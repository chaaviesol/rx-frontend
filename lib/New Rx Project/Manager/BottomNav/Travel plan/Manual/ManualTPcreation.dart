import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../../app_colors.dart';
import '../../../../../constants/styles.dart';
import '../../../../../res/app_url.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  List<DateTime> _selectedDays = []; // Stores multiple selected days
  List<dynamic> doctors = []; // List of all fetched doctors
  List<dynamic> filteredDoctors = []; // Doctors filtered by subHeadquarters
  Set<String> subHeadquarters = {}; // Unique subHeadquarters
  Map<String, int> doctorCountPerSubHQ = {}; // Doctor count by subHeadquarters
  String? selectedSubHeadquarter; // Selected subHeadquarters
  bool _isLoading = false; // Loading state
  bool isCalendarVisible = false; // To toggle calendar visibility

  // Map to store doctor IDs for each selected day
  Map<DateTime, List<int>> selectedDoctorsByDate = {};

  // Fetch doctors for the selected day
  Future<void> fetchDoctors(String day) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    if (uniqueID == null) {
      print('Error: uniqueID is null');
      return;
    }

    setState(() {
      _isLoading = true;
      subHeadquarters.clear();
      doctorCountPerSubHQ.clear();
      selectedSubHeadquarter = null;
    });

    final response = await http.post(
      Uri.parse(AppUrl.listDoctors),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "areas": [""],
        "userId": uniqueID,
        "day": day,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && !data['error']) {
        setState(() {
          doctors = data['data'].map((doc) => doc['doctor']).toList();
          filteredDoctors = doctors;

          for (var doctor in doctors) {
            String subHQ = doctor['findDrAddress']['address']['subHeadQuarter'] as String? ?? 'Unknown';
            subHeadquarters.add(subHQ);
            doctorCountPerSubHQ[subHQ] = (doctorCountPerSubHQ[subHQ] ?? 0) + 1;
          }
        });
      } else {
        print('Error fetching doctors: ${data['message']}');
      }
    } else {
      print('Failed to fetch doctors, status code: ${response.statusCode}');
    }
  }

  // Filter doctors by selected subHeadquarter
  void filterDoctorsBySubHeadquarter(String? subHeadquarterName) {
    if (subHeadquarterName == null || subHeadquarterName == "All") {
      setState(() {
        filteredDoctors = doctors;
      });
    } else {
      setState(() {
        filteredDoctors = doctors.where((doctor) {
          return doctor['findDrAddress']['address']['subHeadQuarter'] == subHeadquarterName;
        }).toList();
      });
    }
  }

  // Toggle doctor selection for a specific day
  void toggleDoctorSelection(DateTime selectedDay, int doctorId) {
    setState(() {
      selectedDoctorsByDate[selectedDay] ??= [];

      // Toggle the doctor's selection for that day
      if (selectedDoctorsByDate[selectedDay]!.contains(doctorId)) {
        selectedDoctorsByDate[selectedDay]!.remove(doctorId);
      } else {
        selectedDoctorsByDate[selectedDay]!.add(doctorId);
      }
    });
  }

  // Send selected doctors for each date to the API
  Future<void> sendSelectedDoctorsWithDates() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    if (uniqueID == null) {
      print('Error: uniqueID is null');
      return;
    }

    // Create a plan with each date and its selected doctors
    List<Map<String, dynamic>> plan = selectedDoctorsByDate.entries.map((entry) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(entry.key);
      List<int> doctorIds = entry.value;

      return {
        "date": formattedDate,
        "doctors": doctorIds,
      };
    }).toList();

    final response = await http.post(
      Uri.parse(AppUrl.generateManulTP),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "user_id": uniqueID,
        "plan": plan,
      }),
    );

    print('Response status: ${response.statusCode}, body: ${response.body}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Days'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await sendSelectedDoctorsWithDates(); // Send doctors for selected days
            },
            child: Text('Generate'),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            selectedDayPredicate: (day) {
              return _selectedDays.contains(day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                if (_selectedDays.contains(selectedDay)) {
                  _selectedDays.remove(selectedDay);
                } else {
                  _selectedDays.add(selectedDay);
                }
                _focusedDay = focusedDay;
              });
              fetchDoctors(getDayName(selectedDay)); // Fetch doctors for the selected day
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
          if (_isLoading) CircularProgressIndicator(),
          SizedBox(height: 20),
          if (subHeadquarters.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: subHeadquarters.map((subHQ) {
                  int doctorCount = doctorCountPerSubHQ[subHQ] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text('$subHQ ($doctorCount)'),
                      selected: selectedSubHeadquarter == subHQ,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedSubHeadquarter = selected ? subHQ : null;
                          filterDoctorsBySubHeadquarter(selectedSubHeadquarter);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                var doctor = filteredDoctors[index];
                int doctorId = doctor['id'];
                bool isSelected = selectedDoctorsByDate[_focusedDay]?.contains(doctorId) ?? false;

                return GestureDetector(
                  onTap: () {
                    toggleDoctorSelection(_focusedDay, doctorId); // Toggle doctor selection for the current day
                  },
                  child: ListTile(
                    title: Text('${doctor['firstName']} ${doctor['lastName']}'),
                    subtitle: Text('Visit Type: ${doctor['visitType']}'),
                    tileColor: isSelected ? Colors.blue.withOpacity(0.2) : null,
                  ),
                );
              },
            ),
          ),
          if (filteredDoctors.isEmpty && !_isLoading)
            Center(child: Text('No doctors available for the selected subHeadquarter or day.')),
        ],
      ),
    );
  }

  String getDayName(DateTime day) {
    return DateFormat('EEEE').format(day);
  }
}
