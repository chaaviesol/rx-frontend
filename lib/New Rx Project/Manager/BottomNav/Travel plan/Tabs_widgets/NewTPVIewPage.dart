import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../app_colors.dart';

class NewTPViewPage extends StatefulWidget {
  @override
  _NewTPViewPageState createState() => _NewTPViewPageState();
}

class _NewTPViewPageState extends State<NewTPViewPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  bool isLoading = true;
  Map<DateTime, List<DoctorVisit>> events = {};

  @override
  void initState() {
    super.initState();
    fetchTravelPlans();
  }

  // Function to fetch travel plans from API
  Future<void> fetchTravelPlans() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int userId = int.parse(preferences.getString('userID').toString());
    String url = AppUrl.getTravelPlans;
    var data = {
      'userId': userId,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      // Parse the response
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Assuming data is in the "data" key
      List<dynamic> travelPlans = responseData['data'];

      // Process the API response into events
      Map<DateTime, List<DoctorVisit>> loadedEvents = {};
      for (var plan in travelPlans) {
        DateTime visitDate = DateFormat('dd-MM-yyyy').parse(plan['date']);
        var drDetails = plan['drDetails'][0];

        // Create DoctorVisit objects from the API response
        DoctorVisit doctorVisit = DoctorVisit(
          id: drDetails['id'],
          firstName: drDetails['firstName'],
          lastName: drDetails['lastName'],
          visitType: drDetails['visit_type'],
          noOfVisits: drDetails['no_of_visits'],
          addresses: (drDetails['addresses'] as List)
              .map((addressData) => DoctorAddress(
            address: addressData['address']['address'],
            latitude: addressData['address']['latitude'],
            longitude: addressData['address']['longitude'],
            schedule: (addressData['address']['schedule'] as List)
                .map((scheduleData) => DoctorSchedule(
              day: scheduleData['day'],
              startTime: scheduleData['start_time'],
              endTime: scheduleData['end_time'],
            ))
                .toList(),
            subHeadQuarter: addressData['address']['subHeadQuarter'],
          ))
              .toList(),
        );

        // Add the visit to the events map
        if (loadedEvents[visitDate] == null) {
          loadedEvents[visitDate] = [doctorVisit];
        } else {
          loadedEvents[visitDate]!.add(doctorVisit);
        }
      }

      setState(() {
        events = loadedEvents;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load travel plans');
    }
  }

  List<DoctorVisit> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Manual Travel Plan'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2023),
            lastDay: DateTime(2050),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
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
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    final selectedEvents = _getEventsForDay(_selectedDay);
    if (selectedEvents.isEmpty) {
      return Center(
        child: Text('No events for this day.'),
      );
    }
    return ListView.builder(
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        return Card(
          child: ListTile(
            title: Text('${event.firstName} ${event.lastName}'),
            subtitle: Text('Visit Type: ${event.visitType}'),
            onTap: () {
              // Show more details or navigate to a detailed page
            },
          ),
        );
      },
    );
  }
}

// Models to hold Doctor Visit data
class DoctorVisit {
  final int id;
  final String firstName;
  final String lastName;
  final String visitType;
  final int noOfVisits;
  final List<DoctorAddress> addresses;

  DoctorVisit({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.visitType,
    required this.noOfVisits,
    required this.addresses,
  });
}

class DoctorAddress {
  final String address;
  final String latitude;
  final String longitude;
  final List<DoctorSchedule> schedule;
  final String subHeadQuarter;

  DoctorAddress({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.schedule,
    required this.subHeadQuarter,
  });
}

class DoctorSchedule {
  final String day;
  final String startTime;
  final String endTime;

  DoctorSchedule({
    required this.day,
    required this.startTime,
    required this.endTime,
  });
}
